package main

import (
	"context"
	"errors"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
)

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
	headersToStrip := []string{
		"Connection",
		"Keep-Alive",
		"Proxy-Authenticate",
		"Proxy-Authorization",
		"TE",
		"Trailers",
		"Transfer-Encoding",
		"Upgrade",
	}

	dstHeader := src.Header.Clone()

	// hop-by-hop headers are defined in the Connection header and should be removed
	if connectionHeader := dstHeader.Get("Connection"); connectionHeader != "" {
		for _, h := range strings.Split(connectionHeader, ",") {
			headersToStrip = append(headersToStrip, strings.TrimSpace(h))
		}
	}

	// Strip headers that are not allowed to be forwarded
	for _, h := range headersToStrip {
		dstHeader.Del(h)
	}

	dst.Header = dstHeader

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
}

type proxy struct {
	client *http.Client
}

func (p *proxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxBodySize)

	prefix, backend, remainder := matchRoute(r.URL.Path, routes)

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
		// Copy header from res to w
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
