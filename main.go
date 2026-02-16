package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
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
	fmt.Println("Starting server...")

	client := &http.Client{
		Timeout: 60 * time.Second,
	}

	server := &http.Server{
		Addr:              ":8080",
		Handler:           nil,               // Use default m ux
		ReadTimeout:       10 * time.Second,  // Max time to read request (headers + body)
		WriteTimeout:      60 * time.Second,  // Max time to write response
		IdleTimeout:       120 * time.Second, // Max time for keep-alive connections
		ReadHeaderTimeout: 5 * time.Second,   // Max time to read just request headers
	}

	http.HandleFunc("/health", healthCheckHandler)

	http.Handle("/", &proxy{client: client})

	sigChan := make(chan os.Signal, 1)
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			fmt.Printf("Failed to start server: %v\n", err)
		}
	}()

	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM) // Listen for interrupt signals (e.g., Ctrl+C)

	<-sigChan //Block until a signal is received

	fmt.Println("Shutting down...")

	// create 30 second timeout context for graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// attempt graceful shutdown
	if err := server.Shutdown(ctx); err != nil {
		fmt.Printf("Forced shutdown: %v\n", err)
	}
	fmt.Println("Server stopped")
}
