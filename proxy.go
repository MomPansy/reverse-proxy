package main

import (
	"context"
	"errors"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
	"time"
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

func rewriteRequest(pr *httputil.ProxyRequest) {
	ctx, _ := context.WithTimeout(pr.Out.Context(), 60*time.Second)
	pr.Out = pr.Out.WithContext(ctx)

	prefix, backend, remainder := matchRoute(pr.In.URL.Path, routes)
	if prefix == "" {
		return
	}

	backendURL, err := url.Parse(backend + remainder)
	if err != nil {
		return
	}

	pr.SetURL(backendURL)
	pr.SetXForwarded()
}

func errorHandler(w http.ResponseWriter, r *http.Request, err error) {
	prefix, _, _ := matchRoute(r.URL.Path, routes)
	if prefix == "" {
		http.Error(w, "Route not found", http.StatusNotFound)
		return
	}

	var maxBytesErr *http.MaxBytesError
	if errors.As(err, &maxBytesErr) {
		http.Error(w, "Request body too large", http.StatusRequestEntityTooLarge)
	} else if os.IsTimeout(err) || errors.Is(err, context.DeadlineExceeded) {
		http.Error(w, "backend timeout", http.StatusGatewayTimeout)
	} else {
		http.Error(w, "Failed to reach target service", http.StatusBadGateway)
	}
}
