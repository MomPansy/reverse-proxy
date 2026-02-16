# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Go HTTP reverse proxy server that routes requests to backend services. Uses only the Go standard library (`net/http`). The route map is intended to eventually be backed by etcd for dynamic configuration.

## Build & Run Commands

- **Build**: `go build`
- **Run**: `go run main.go`
- **Test**: `go test ./...` (test file exists but no tests written yet)

## Architecture

Single-file Go application (`main.go`). The server listens on port `:8080`.

- **Route map** (`routes`): maps URL paths to backend service URLs (e.g., `/service1` → `localhost:8081`). Currently defined but not yet wired into request handling.
- **Health check**: `/health` endpoint returns `200 OK`.
- Core reverse proxy routing logic is not yet implemented — only the health check handler is registered.

## Learning Project Rules

This is a learning project. The user wants to implement features themselves to learn Go and networking concepts. **Do NOT write complete implementations.** Instead:

- Help with Go syntax questions when asked
- Explain concepts (io.Copy, context propagation, goroutine lifecycle, etc.)
- Point out bugs or issues in the user's code when asked to review
- Suggest the right standard library functions/types to use, but let the user write the code
- Give small code snippets (a few lines) to illustrate syntax, not full solutions

## Go Best Practices

When reviewing or suggesting code, ensure it follows idiomatic Go conventions:

- **Naming**: Use `camelCase` for unexported names, `PascalCase` for exported names. Keep names short but clear.
- **Error handling**: Always check errors. Return errors up the stack rather than using panic. Use `errors.New()` or `fmt.Errorf()` for error messages.
- **Interfaces**: Keep interfaces small. Accept interfaces, return concrete types.
- **Goroutines**: Ensure goroutines have clear lifecycle management. Avoid leaking goroutines.
- **Context**: Use `context.Context` for cancellation and timeouts in long-running operations.
- **Defer**: Use `defer` for cleanup (closing files, connections, etc.) to ensure resources are freed.
- **Package organization**: Group related functionality. Avoid circular dependencies.
- **Comments**: Document exported functions, types, and packages. Use complete sentences starting with the name.
- **Formatting**: Code should be `gofmt`'d (this happens automatically with most editors).

### Extensibility Patterns

When writing maintainable and extensible code, choose the right pattern for the situation:

**Struct literals** - Best for functions that need multiple related values:
```go
type LogEntry struct {
    Timestamp time.Time
    Method    string
    Path      string
    Status    int
}
func logRequest(entry LogEntry) { /* ... */ }
```
Use when: All or most fields are required, data is being passed around.

**Functional options pattern** - Best for configuring objects with optional parameters:
```go
type Server struct {
    timeout time.Duration
    maxConns int
}
type Option func(*Server)

func WithTimeout(t time.Duration) Option {
    return func(s *Server) { s.timeout = t }
}

func NewServer(opts ...Option) *Server {
    s := &Server{timeout: 30 * time.Second} // defaults
    for _, opt := range opts {
        opt(s)
    }
    return s
}
// Usage: NewServer(WithTimeout(60*time.Second), WithMaxConns(100))
```
Use when: Creating objects with many optional settings, want to provide good defaults, API will evolve over time.

**When reviewing code:** If a function has 4+ parameters or keeps needing new parameters added, suggest using a struct or functional options pattern. Prefer struct literals for data passing, functional options for configuration.

When the user asks for code review, check for these practices and suggest improvements where appropriate. Reference the [Effective Go](https://go.dev/doc/effective_go) guide and [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) when explaining best practices.

## Dependencies

Go 1.24.5. No external dependencies — standard library only.
