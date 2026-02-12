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
