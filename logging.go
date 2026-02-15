package main

import (
	"log/slog"
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
