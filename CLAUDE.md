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

## Dependencies

Go 1.24.5. No external dependencies — standard library only.
