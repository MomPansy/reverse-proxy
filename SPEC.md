# Reverse Proxy — Technical Specification

## 1. Overview

An HTTP reverse proxy server written in Go using only the standard library. The proxy accepts incoming HTTP requests, matches them against a route table, and forwards them to the appropriate backend service. Responses are streamed back to the client.

This is a learning project focused on understanding Go and networking fundamentals.

## 2. Core Behavior

### 2.1 Request Flow

```
Client → Proxy (:8080) → Backend (e.g., :8081)
                ↓
         Route lookup
         Strip prefix
         Set proxy headers
         Forward request (streaming)
         Stream response back
```

1. Client sends HTTP request to proxy on port `8080`
2. Proxy matches the request path against the route table using exact prefix matching with `/` boundary
3. If no route matches, return `404 Not Found`
4. Strip the matched prefix from the path (e.g., `/service1/foo/bar` → `/foo/bar`)
5. Set standard proxy headers (`X-Forwarded-For`, `X-Forwarded-Proto`, `X-Real-IP`)
6. Strip hop-by-hop headers
7. Forward the request to the matched backend
8. Stream the backend response back to the client

### 2.2 Route Matching

- Routes are defined as path prefixes: `/service1` → `http://localhost:8081`
- Matching uses exact prefix with `/` boundary:
  - `/service1` matches `/service1` and `/service1/anything`
  - `/service1` does **NOT** match `/service1extra` or `/service1-other`
- If multiple routes could match, the longest prefix wins
- Path stripping: the matched prefix is removed before forwarding
  - `/service1/api/users` → backend receives `/api/users`
  - `/service1` → backend receives `/`

### 2.3 HTTP Method Handling

- The proxy is method-agnostic: all HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, etc.) are forwarded as-is
- The backend decides which methods are valid for its endpoints

## 3. Headers

### 3.1 Proxy Headers (added to forwarded requests)

| Header | Value |
|---|---|
| `X-Forwarded-For` | Client's IP address (appended if already present) |
| `X-Forwarded-Proto` | `http` (the scheme the client used to reach the proxy) |
| `X-Real-IP` | Client's IP address (original client, not appended) |

### 3.2 Host Header

- Preserve the original `Host` header from the client request
- Do NOT replace it with the backend's host

### 3.3 Hop-by-Hop Header Stripping (RFC 2616 §13.5.1)

The following headers MUST be stripped before forwarding to the backend:

- `Connection`
- `Keep-Alive`
- `Proxy-Authenticate`
- `Proxy-Authorization`
- `TE`
- `Trailers`
- `Transfer-Encoding`
- `Upgrade`

Additionally, any headers listed in the `Connection` header value must also be stripped.

### 3.4 CORS

- The proxy does NOT handle CORS
- CORS is the responsibility of each backend service

## 4. Response Handling

### 4.1 Streaming

- Responses are streamed from the backend to the client as bytes arrive
- The proxy does NOT buffer the full response in memory
- Use `io.Copy` (or equivalent) to pipe the response body
- Flush data to the client as it arrives (support `http.Flusher` for SSE-like use cases)

### 4.2 Response Headers

- Forward all response headers from the backend to the client
- Strip hop-by-hop headers from the response as well
- Preserve the backend's status code

## 5. Error Handling

### 5.1 No Route Match

- Return `404 Not Found` with plain text body: `no route matched for path: <path>`

### 5.2 Backend Unreachable

- Return `502 Bad Gateway` immediately (no retries)
- Log the error with backend address and original request details
- Plain text body: `backend unavailable`

### 5.3 Backend Timeout

- Return `504 Gateway Timeout` if the backend does not respond within the timeout
- Plain text body: `backend timeout`

## 6. Timeouts and Limits

### 6.1 Backend Response Timeout

- **Global timeout: 60 seconds** per request
- Applied using `http.Client.Timeout` or `context.WithTimeout`
- If the backend does not send a complete response within 60s, the proxy returns `504 Gateway Timeout`

### 6.2 Client Connection Timeouts (Slowloris Protection)

- `ReadTimeout`: 10 seconds — maximum time to read the full request (headers + body)
- `WriteTimeout`: 60 seconds — maximum time to write the full response
- `IdleTimeout`: 120 seconds — maximum time to keep idle keep-alive connections open
- `ReadHeaderTimeout`: 5 seconds — maximum time to read just the request headers

These are set on the `http.Server` struct.

### 6.3 Request Body Size Limit

- **Maximum body size: 10 MB** (10 * 1024 * 1024 bytes)
- Enforced using `http.MaxBytesReader` wrapping the request body
- If exceeded, return `413 Request Entity Too Large`
- Applied to all routes uniformly

## 7. Health Check

- `GET /health` returns `200 OK` with body `OK`
- This endpoint is handled directly by the proxy, NOT forwarded to any backend
- Health check is excluded from access logging

## 8. Logging

### 8.1 Access Log Format

Structured log output to stdout for every proxied request:

```
{
  "timestamp": "2024-01-15T10:30:00Z",
  "method": "GET",
  "path": "/service1/api/users",
  "backend": "http://localhost:8081",
  "status": 200,
  "latency_ms": 45,
  "client_ip": "192.168.1.100",
  "request_size": 0,
  "response_size": 1234
}
```

Fields:
- `timestamp`: ISO 8601 / RFC 3339 format
- `method`: HTTP method
- `path`: original request path (before prefix stripping)
- `backend`: the backend URL the request was forwarded to (empty if no route matched)
- `status`: HTTP status code returned to client
- `latency_ms`: total time from request received to response sent, in milliseconds
- `client_ip`: client's remote address
- `request_size`: content-length of the request body (0 if none)
- `response_size`: bytes written in the response body

### 8.2 Error Logging

- Backend connection failures: log with ERROR level, include backend address, error message, and request path
- Timeout errors: log with WARN level
- Use `log/slog` (Go 1.21+ structured logging) or manual JSON marshaling

## 9. Graceful Shutdown

1. Listen for `SIGINT` and `SIGTERM` signals
2. On signal received:
   a. Stop accepting new connections (`http.Server.Shutdown`)
   b. Wait for in-flight requests to complete
   c. Enforce a shutdown deadline of **30 seconds** — after this, force-close remaining connections
3. Log shutdown events: "shutting down...", "shutdown complete" (or "forced shutdown after deadline")

## 10. Route Configuration

### 10.1 Current: Static Map

Routes are defined as a `map[string]string` in Go code:

```go
var routes = map[string]string{
    "/service1": "http://localhost:8081",
    "/service2": "http://localhost:8082",
}
```

### 10.2 Future: etcd-backed (out of scope for now)

The route map interface should be clean enough that swapping in an etcd-backed implementation later is straightforward. Consider defining a simple interface:

```go
type RouteResolver interface {
    Resolve(path string) (backendURL string, matchedPrefix string, found bool)
}
```

## 11. Project Structure

```
reverse-proxy/
├── main.go              # Entry point: wires everything together, starts server, handles signals
├── proxy/
│   └── proxy.go         # Core proxy handler: route matching, request forwarding, header manipulation
├── config/
│   └── config.go        # Route table, timeout values, body size limits
├── logging/
│   └── logging.go       # Structured access logger, error logger
├── go.mod
├── CLAUDE.md
└── SPEC.md
```

### Package Responsibilities

- **main**: creates the `http.Server`, registers the proxy handler and health check, sets up signal handling for graceful shutdown
- **proxy**: implements `http.Handler`, contains route matching logic, request forwarding (including header manipulation, prefix stripping, streaming), and error responses
- **config**: defines the route map and constants (timeouts, body limit). Houses the `RouteResolver` interface and the static map implementation
- **logging**: provides a middleware or helper that wraps the proxy handler to log access information in structured JSON format

## 12. Test Plan

### 12.1 Test Approach

Use `httptest.NewServer` to create fake backends and `httptest.NewRequest` + `httptest.NewRecorder` to drive requests through the proxy handler.

### 12.2 Test Cases

**Route Matching:**
- Request to `/service1/foo` routes to correct backend
- Request to `/service1` (no trailing path) routes correctly, backend receives `/`
- Request to `/unknown` returns 404
- Request to `/service1extra` does NOT match `/service1` (boundary check)
- Longest prefix match: `/service1/api` preferred over `/service1` when both exist

**Prefix Stripping:**
- `/service1/api/users` → backend receives path `/api/users`
- `/service1` → backend receives path `/`

**Header Forwarding:**
- `X-Forwarded-For` is set to client IP
- `X-Forwarded-Proto` is set to `http`
- `X-Real-IP` is set to client IP
- Original `Host` header is preserved
- Hop-by-hop headers (`Connection`, `Keep-Alive`, etc.) are stripped
- Custom client headers are forwarded to backend

**Response Streaming:**
- Backend response body is correctly forwarded to client
- Backend response headers are forwarded
- Backend status code is preserved (test 200, 201, 400, 500)

**Error Handling:**
- Backend is down → proxy returns 502
- Backend times out → proxy returns 504
- Request body exceeds 10MB → proxy returns 413

**HTTP Methods:**
- GET, POST, PUT, DELETE, PATCH all forwarded correctly
- Request body (for POST/PUT) is forwarded intact

**Health Check:**
- `GET /health` returns 200 with body `OK`
- Health check does NOT get forwarded to any backend

**Body Size Limit:**
- Request with body under 10MB succeeds
- Request with body over 10MB returns 413

### 12.3 Test Structure

```
reverse-proxy/
├── proxy/
│   ├── proxy.go
│   └── proxy_test.go    # Route matching, forwarding, header, error tests
├── config/
│   ├── config.go
│   └── config_test.go   # Route resolver tests
└── main_test.go         # Integration: graceful shutdown, health check
```

## 13. What's Explicitly Out of Scope

- WebSocket support
- TLS termination (HTTPS)
- CORS handling at the proxy layer
- Retry logic / circuit breakers
- Per-route timeouts or body limits
- Metrics / stats endpoint
- Rate limiting
- Authentication / authorization
- etcd integration (future work)
- Load balancing across multiple backends for the same route
