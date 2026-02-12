package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthCheck(t *testing.T) {
	// Create a request to /health
	req := httptest.NewRequest("GET", "/health", nil)
	// Create a response recorder
	rr := httptest.NewRecorder()
	// Call the healthCheckHandler
	healthCheckHandler(rr, req)
	// Check if the status code is 200
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
	// Check if the response body is "OK"
	expected := "OK"
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}

func TestMatchRoute(t *testing.T) {
	testRoutes := map[string]string{
		"/service1":        "http://localhost:8081",
		"/service2":        "http://localhost:8082",
		"/service1/nested": "http://localhost:8083",
	}

	tests := []struct {
		name       string
		path       string
		wantMatch  string
		wantTarget string
		wantSuffix string
	}{
		{
			name:       "exact match",
			path:       "/service1",
			wantMatch:  "/service1",
			wantTarget: "http://localhost:8081",
			wantSuffix: "",
		},
		{
			name:       "match with subpath",
			path:       "/service1/foo/bar",
			wantMatch:  "/service1",
			wantTarget: "http://localhost:8081",
			wantSuffix: "/foo/bar",
		},
		{
			name:       "longest prefix wins",
			path:       "/service1/nested/deep",
			wantMatch:  "/service1/nested",
			wantTarget: "http://localhost:8083",
			wantSuffix: "/deep",
		},
		{
			name:       "no match",
			path:       "/unknown",
			wantMatch:  "",
			wantTarget: "",
			wantSuffix: "",
		},
		{
			name:       "partial prefix not matched",
			path:       "/service1extra",
			wantMatch:  "",
			wantTarget: "",
			wantSuffix: "",
		},
		{
			name:       "root path no match",
			path:       "/",
			wantMatch:  "",
			wantTarget: "",
			wantSuffix: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			match, target, suffix := matchRoute(tt.path, testRoutes)
			if match != tt.wantMatch {
				t.Errorf("match = %q, want %q", match, tt.wantMatch)
			}
			if target != tt.wantTarget {
				t.Errorf("target = %q, want %q", target, tt.wantTarget)
			}
			if suffix != tt.wantSuffix {
				t.Errorf("suffix = %q, want %q", suffix, tt.wantSuffix)
			}
		})
	}
}

func TestSetProxyHeaders(t *testing.T) {
	tests := []struct {
		name              string
		remoteAddr        string
		existingForwarded string
		wantRealIP        string
		wantProto         string
		wantForwardedFor  string
	}{
		{
			name:             "standard host:port",
			remoteAddr:       "192.168.1.1:12345",
			wantRealIP:       "192.168.1.1",
			wantProto:        "http",
			wantForwardedFor: "192.168.1.1",
		},
		{
			name:             "bare IP without port",
			remoteAddr:       "10.0.0.1",
			wantRealIP:       "10.0.0.1",
			wantProto:        "http",
			wantForwardedFor: "10.0.0.1",
		},
		{
			name:              "appends to existing X-Forwarded-For",
			remoteAddr:        "192.168.1.1:12345",
			existingForwarded: "10.0.0.1",
			wantRealIP:        "192.168.1.1",
			wantProto:         "http",
			wantForwardedFor:  "10.0.0.1, 192.168.1.1",
		},
		{
			name:             "IPv6 with port",
			remoteAddr:       "[::1]:8080",
			wantRealIP:       "::1",
			wantProto:        "http",
			wantForwardedFor: "::1",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			src := httptest.NewRequest("GET", "/test", nil)
			src.RemoteAddr = tt.remoteAddr
			if tt.existingForwarded != "" {
				src.Header.Set("X-Forwarded-For", tt.existingForwarded)
			}

			dst, _ := http.NewRequest("GET", "http://backend/test", nil)
			setProxyHeaders(dst, src)

			if got := dst.Header.Get("X-Real-IP"); got != tt.wantRealIP {
				t.Errorf("X-Real-IP = %q, want %q", got, tt.wantRealIP)
			}
			if got := dst.Header.Get("X-Forwarded-Proto"); got != tt.wantProto {
				t.Errorf("X-Forwarded-Proto = %q, want %q", got, tt.wantProto)
			}
			if got := dst.Header.Get("X-Forwarded-For"); got != tt.wantForwardedFor {
				t.Errorf("X-Forwarded-For = %q, want %q", got, tt.wantForwardedFor)
			}
		})
	}
}

func TestSetProxyHeaders_CopiesOriginalHeaders(t *testing.T) {
	src := httptest.NewRequest("GET", "/test", nil)
	src.RemoteAddr = "1.2.3.4:5678"
	src.Header.Set("Authorization", "Bearer token123")
	src.Header.Set("Content-Type", "application/json")

	dst, _ := http.NewRequest("GET", "http://backend/test", nil)
	setProxyHeaders(dst, src)

	if got := dst.Header.Get("Authorization"); got != "Bearer token123" {
		t.Errorf("Authorization = %q, want %q", got, "Bearer token123")
	}
	if got := dst.Header.Get("Content-Type"); got != "application/json" {
		t.Errorf("Content-Type = %q, want %q", got, "application/json")
	}
}

func TestReverseProxy_NoRoute(t *testing.T) {
	// Create a request to an unknown route
	req := httptest.NewRequest("GET", "/unknown", nil)
	rr := httptest.NewRecorder()
	// Call the reverseProxyHandler
	reverseProxyHandler(rr, req)
	// Check if the status code is 404
	if status := rr.Code; status != http.StatusNotFound {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusNotFound)
	}
}

func TestReverseProxy(t *testing.T) {
	// Create a fake backend
	backend := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Backend Response"))
	}))
	defer backend.Close()

	// Update routes to point to the fake backend
	routes["/service1"] = backend.URL

	// Create a request to the known route
	req := httptest.NewRequest("GET", "/service1/test", nil)
	rr := httptest.NewRecorder()
	// Call the reverseProxyHandler
	reverseProxyHandler(rr, req)

	// Check if the status code is 200
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
	// Check if the response body is from the backend
	expected := "Backend Response"
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}
