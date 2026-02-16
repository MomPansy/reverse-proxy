package main

import (
	"fmt"
	"net/http"
	"time"
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

func main() {
	client := &http.Client{
		Timeout: 60 * time.Second,
	}

	server := &http.Server{
		Addr:              ":8080",
		Handler:           nil,               // Use default mux
		ReadTimeout:       10 * time.Second,  // Max time to read request (headers + body)
		WriteTimeout:      60 * time.Second,  // Max time to write response
		IdleTimeout:       120 * time.Second, // Max time for keep-alive connections
		ReadHeaderTimeout: 5 * time.Second,   // Max time to read just request headers
	}

	http.HandleFunc("/health", healthCheckHandler)

	http.Handle("/", &proxy{client: client})

	if err := server.ListenAndServe(); err != nil {
		fmt.Printf("Failed to start server: %v\n", err)
	}

}
