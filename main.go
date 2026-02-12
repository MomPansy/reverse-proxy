package main

import (
	"fmt"
	"io"
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

func reverseProxyHandler(w http.ResponseWriter, r *http.Request) {
	// Parse route
	path := r.URL.Path
	for prefix, target := range routes {
		suffix, found := strings.CutPrefix(path, prefix)
		if found {
			targetURL := target + suffix
			// Create a new request to the target service
			req, err := http.NewRequest(r.Method, targetURL, r.Body)

			if err != nil {
				http.Error(w, "Failed to create request", http.StatusInternalServerError)
				return
			}

			req.Header = r.Header

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
