package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
)

// routes simulates a constant map (e.g., from etcd)
var routes = map[string]string{
	"/service1": "http://localhost:8081",
	"/service2": "http://localhost:8082",
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
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

func reverseProxyHandler(w http.ResponseWriter, r *http.Request) {
	bestMatch, bestTarget, bestSuffix := matchRoute(r.URL.Path, routes)

	if bestMatch != "" {
		targetURL := bestTarget + bestSuffix
		// Create a new request to the target service
		req, err := http.NewRequest(r.Method, targetURL, r.Body)

		if err != nil {
			http.Error(w, "Failed to create request", http.StatusInternalServerError)
			return
		}

		setProxyHeaders(req, r)

		// Perform the request
		res, err := http.DefaultClient.Do(req)

		if err != nil {
			http.Error(w, "Failed to reach target service", http.StatusBadGateway)
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

func main() {
	http.HandleFunc("/health", healthCheckHandler)

	http.HandleFunc("/", reverseProxyHandler)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Printf("Failed to start server: %v\n", err)
	}

}
