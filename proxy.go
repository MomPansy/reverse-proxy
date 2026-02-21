package main

import (
	"context"
	"errors"
	"io"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
	"time"
)

// hopByHopHeaders are headers that must be stripped before forwarding
// per RFC 2616 §13.5.1. These apply to both request and response headers.
var hopByHopHeaders = []string{
	"Connection",
	"Keep-Alive",
	"Proxy-Authenticate",
	"Proxy-Authorization",
	"Proxy-Connection",
	"TE",
	"Trailer",
	"Transfer-Encoding",
	"Upgrade",
}

// stripHopByHopHeaders removes hop-by-hop headers from an http.Header,
// including any headers referenced in the Connection header.
func stripHopByHopHeaders(h http.Header) {
	if connection := h.Get("Connection"); connection != "" {
		for _, token := range strings.Split(connection, ",") {
			h.Del(strings.TrimSpace(token))
		}
	}
	for _, hdr := range hopByHopHeaders {
		h.Del(hdr)
	}
}

// matchRoute finds the longest matching route prefix for the given path.
// Returns the matched prefix, target URL, and remaining path suffix.
// If no route matches, all return values are empty strings.
func matchRoute(path string, routes map[string]string) (match, target, suffix string) {
	for prefix, t := range routes {
		s, found := strings.CutPrefix(path, prefix)
		if found && (s == "" || strings.HasPrefix(s, "/")) {
			if len(prefix) > len(match) {
				match = prefix
				target = t
				suffix = s
			}
		}
	}
	return
}

// setProxyHeaders copies headers from the original request and sets
// X-Real-IP, X-Forwarded-Proto, and X-Forwarded-For on the outbound request.
func setProxyHeaders(dst *http.Request, src *http.Request) {
	dst.Header = src.Header.Clone()
	stripHopByHopHeaders(dst.Header)

	clientIP, _, err := net.SplitHostPort(src.RemoteAddr)
	if err != nil {
		clientIP = src.RemoteAddr
	}

	dst.Header.Set("X-Real-IP", clientIP)
	dst.Header.Set("X-Forwarded-Proto", "http")

	if existing := dst.Header.Get("X-Forwarded-For"); existing != "" {
		dst.Header.Set("X-Forwarded-For", existing+", "+clientIP)
	} else {
		dst.Header.Set("X-Forwarded-For", clientIP)
	}

	dst.Host = src.Host
}

type proxy struct {
	client *http.Client
}

func (p *proxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxBodySize)
	recorder := &responseRecorder{ResponseWriter: w, statusCode: http.StatusOK}
	w = recorder
	start := time.Now()

	prefix, backend, remainder := matchRoute(r.URL.Path, routes)
	defer func() {
		clientIP, _, _ := net.SplitHostPort(r.RemoteAddr)
		requestSize := int(r.ContentLength)
		if requestSize < 0 {
			requestSize = 0
		}
		LogRequest(LogEntry{
			Timestamp:    start,
			Method:       r.Method,
			Path:         r.URL.Path,
			Backend:      backend,
			Status:       recorder.statusCode,
			LatencyMs:    time.Since(start).Milliseconds(),
			ClientIP:     clientIP,
			RequestSize:  requestSize,
			ResponseSize: recorder.bytesWritten,
		})
	}()

	if prefix != "" {
		targetURL := backend + remainder
		// Create a new request to the target service
		req, err := http.NewRequest(r.Method, targetURL, r.Body)
		if err != nil {
			http.Error(w, "Failed to create request", http.StatusInternalServerError)
			return
		}

		setProxyHeaders(req, r)

		// Perform the request
		res, err := p.client.Do(req)
		if err != nil {
			var maxBytesErr *http.MaxBytesError
			if errors.As(err, &maxBytesErr) {
				http.Error(w, "Request body too large", http.StatusRequestEntityTooLarge)
			} else if os.IsTimeout(err) || errors.Is(err, context.DeadlineExceeded) {
				http.Error(w, "backend timeout", http.StatusGatewayTimeout)
			} else {
				http.Error(w, "Failed to reach target service", http.StatusBadGateway)
			}
			return
		}

		defer res.Body.Close()
		// Strip hop-by-hop headers from response before copying
		stripHopByHopHeaders(res.Header)
		// Copy remaining headers to response
		for k, v := range res.Header {
			w.Header()[k] = v
		}
		// Copy status code from res to w
		w.WriteHeader(res.StatusCode)
		// Copy body from res to w
		io.Copy(w, res.Body)

		return
	}
	// no route matched, return 404
	http.NotFound(w, r)
}

type proxyError struct {
	message string
	status  int
}

func rewriteRequest(pr *httputil.ProxyRequest) {
	prefix, backend, remainder := matchRoute(pr.In.URL.Path, routes)

	if prefix != "" {
		targetURL := backend + remainder
		backendURL, err := url.Parse(targetURL)
		if err != nil {
			// handle the error
			ctx := context.WithValue(pr.Out.Context(), ContextErrorKey, proxyError{message: "Internal proxy configuration error", status: http.StatusBadGateway})
			pr.Out = pr.Out.WithContext(ctx)
			return
		}
		pr.SetURL(backendURL)
	} else {
		ctx := context.WithValue(pr.Out.Context(), ContextErrorKey, proxyError{message: "Route not found", status: http.StatusNotFound})
		pr.Out = pr.Out.WithContext(ctx)
	}
}

func errorHandler(w http.ResponseWriter, r *http.Request, err error) {
	if val := r.Context().Value(ContextErrorKey); val != nil {
		if pe, ok := val.(proxyError); ok {
			http.Error(w, pe.message, pe.status)
			return
		}
	}
	if err != nil {
		var maxBytesErr *http.MaxBytesError
		if errors.As(err, &maxBytesErr) {
			http.Error(w, "Request body too large", http.StatusRequestEntityTooLarge)
		} else if os.IsTimeout(err) || errors.Is(err, context.DeadlineExceeded) {
			http.Error(w, "backend timeout", http.StatusGatewayTimeout)
		} else {
			http.Error(w, "Failed to reach target service", http.StatusBadGateway)
		}
		return
	}
}
