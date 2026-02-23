package main

import (
	"log/slog"
	"net"
	"net/http"
	"time"
)

type LogEntry struct {
	Timestamp    time.Time
	Method       string
	Path         string
	Backend      string
	Status       int
	LatencyMs    int64
	ClientIP     string
	RequestSize  int
	ResponseSize int
}

func LogRequest(entry LogEntry) {
	slog.Info("proxy request",
		"timestamp", entry.Timestamp.Format(time.RFC3339),
		"method", entry.Method,
		"path", entry.Path,
		"backend", entry.Backend,
		"status", entry.Status,
		"latency_ms", entry.LatencyMs,
		"client_ip", entry.ClientIP,
		"request_size", entry.RequestSize,
		"response_size", entry.ResponseSize,
	)
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		recorder := &responseRecorder{ResponseWriter: w, statusCode: http.StatusOK}
		w = recorder
		start := time.Now()

		next.ServeHTTP(w, r)

		clientIP, _, _ := net.SplitHostPort(r.RemoteAddr)
		requestSize := int(r.ContentLength)
		if requestSize < 0 {
			requestSize = 0
		}
		_, backend, _ := matchRoute(r.URL.Path, routes)
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
	})
}
