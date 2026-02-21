# Migration Guide: Learning `httputil.ReverseProxy`

This guide walks you through migrating from the custom reverse proxy implementation to using Go's standard library `httputil.ReverseProxy`. The goal is to **learn by doing** - this guide explains concepts and points you to the right APIs, but you'll write the code yourself.

## Why Migrate?

You've successfully implemented a reverse proxy from scratch and learned:
- HTTP request/response lifecycle
- Header manipulation (hop-by-hop stripping)
- Request forwarding with `http.Client`
- Body copying with `io.Copy`
- Error handling for proxies

Now you'll learn how Go's stdlib abstracts these patterns and handles edge cases you might not have considered.

## Pre-Migration Reading

Before starting, read the `httputil.ReverseProxy` documentation:
```bash
go doc net/http/httputil.ReverseProxy
```

Key things to understand:
1. **What does ReverseProxy handle automatically?**
2. **What customization points does it expose?** (Rewrite, ModifyResponse, ErrorHandler)
3. **What's the difference between Director (old API) and Rewrite (new API)?**

Also read the source code - it's surprisingly readable:
- Go stdlib: `$GOROOT/src/net/http/httputil/reverseproxy.go`
- Or online: https://pkg.go.dev/net/http/httputil#ReverseProxy

## Architecture Overview

**Current implementation:**
```
Your code does everything:
  Request → matchRoute → create new Request → set headers
  → http.Client.Do() → copy response → return
```

**With ReverseProxy:**
```
You provide configuration:
  Request → your Rewrite func → ReverseProxy handles forwarding
  → your ModifyResponse func → your ErrorHandler → return
```

**Key insight:** ReverseProxy is a framework - you plug in your custom logic at specific points, and it handles the plumbing.

## Migration Steps

### Step 1: Understanding the `Rewrite` Function

The `Rewrite` function is where you customize the outbound request. It receives a `*httputil.ProxyRequest` with two key fields:

- `In`: Original incoming request (read-only)
- `Out`: Outbound request to backend (modify this)

**Your task:** Read the `ProxyRequest` documentation:
```bash
go doc net/http/httputil.ProxyRequest
```

**Questions to consider:**
1. How do you change where the request is sent?
2. How do you modify headers on the outbound request?
3. What happens if you set an invalid URL scheme?

**Hint:** Look at the `SetURL()` and `SetXForwarded()` methods.

**What you need to implement:**
- Route matching logic (you already have `matchRoute()` - reuse it!)
- Setting the backend target URL
- Appending the path remainder
- Setting custom headers (X-Real-IP, X-Forwarded-Proto)
- Preserving the Host header

**Small syntax example** (not complete):
```go
func rewriteRequest(pr *httputil.ProxyRequest) {
    // pr.In = incoming request
    // pr.Out = outbound request

    // Your route matching logic here
    prefix, backend, remainder := matchRoute(pr.In.URL.Path, routes)

    // TODO: Parse backend URL
    // TODO: Set pr.Out.URL to point to backend
    // TODO: Append remainder to path
    // TODO: Set headers
    // TODO: Handle "no route found" case
}
```

**Challenge:** How do you signal "no route found" to the ErrorHandler? (Hint: What if you set an invalid URL?)

### Step 2: Understanding ModifyResponse

`ModifyResponse` is called after ReverseProxy gets the backend response but before sending it to the client. This is where you can inspect or modify the response.

**Questions:**
1. Does ReverseProxy already strip hop-by-hop headers from responses?
2. If not, how do you remove them?
3. What happens if you return an error from ModifyResponse?

**Check the stdlib:** Look at the ReverseProxy source code. Does it call `removeHopByHopHeaders()` on responses? If yes, you might not need to do anything here.

**What you need to implement:**
- Verify whether hop-by-hop stripping is needed
- If needed, implement stripping logic (similar to what you already have)

**Starting point:**
```go
func modifyResponse(res *http.Response) error {
    // res = backend response
    // Modify res.Header if needed
    // Return nil for success, error to trigger ErrorHandler
    return nil
}
```

### Step 3: Understanding ErrorHandler

`ErrorHandler` is called when something goes wrong during proxying. You can return custom status codes based on the error type.

**Questions:**
1. What error types might you receive? (timeout, connection refused, invalid URL, etc.)
2. How do you detect a `http.MaxBytesError`? (Hint: `errors.As`)
3. How do you detect a timeout? (Hint: `errors.Is` with `context.DeadlineExceeded`)

**What you need to implement:**
- 413 for request body too large
- 504 for backend timeout
- 404 for no route found (how did you signal this in Rewrite?)
- 502 for other backend errors

**Starting point:**
```go
func errorHandler(w http.ResponseWriter, r *http.Request, err error) {
    // Inspect err and return appropriate status code
    // Use errors.As, errors.Is, strings.Contains as needed
}
```

### Step 4: Creating the ReverseProxy Instance

Now create the `ReverseProxy` with your custom functions.

**Questions:**
1. What fields does `ReverseProxy` struct have?
2. Do you need a custom `Transport`? (for connection pooling, timeouts)
3. What's the difference between `Transport` and the `http.Client` you used before?

**What you need to implement:**
A constructor function that creates and configures a `ReverseProxy`:

```go
func createReverseProxy() *httputil.ReverseProxy {
    // Create ReverseProxy
    // Set Rewrite, ModifyResponse, ErrorHandler
    // Optionally configure Transport
}
```

**Read:** Go doc for `http.Transport` to understand connection pooling options.

### Step 5: Logging Middleware

Your current implementation logs every request with metrics. With ReverseProxy, you need to wrap it in middleware.

**Current approach:** Logging happens in `proxy.ServeHTTP()` with a defer block.

**New approach:** Create a middleware function that wraps any `http.Handler`.

**What you need to implement:**
- A function that takes `http.Handler` and returns `http.Handler`
- Apply `http.MaxBytesReader` for body size limit
- Wrap ResponseWriter with `responseRecorder` to capture metrics
- Call route matching to get backend URL for logging
- Call the wrapped handler
- Log after completion

**Pattern to follow:**
```go
func withLogging(handler http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Setup: body limiter, recorder, start time

        // Call the wrapped handler
        handler.ServeHTTP(w, r)

        // Cleanup: logging
    })
}
```

**Note:** This duplicates route matching (once for logging, once in Rewrite). This is acceptable! You can optimize later.

### Step 6: Wiring It Together

Update `main.go` to use your new proxy.

**Current:**
```go
client := &http.Client{Timeout: 60 * time.Second}
http.Handle("/", &proxy{client: client})
```

**New:**
```go
// Create proxy instance
// Wrap with logging middleware
// Register with http.Handle
```

**Question:** Do you still need the `client` variable?

### Step 7: Cleanup

After everything works, delete the old code:
- `stripHopByHopHeaders()` function
- `setProxyHeaders()` function
- `proxy` struct and its `ServeHTTP()` method

**Keep:**
- `matchRoute()` - still needed!
- `responseRecorder` - still needed!
- `hopByHopHeaders` variable - might still need in ModifyResponse

### Step 8: Testing

Update your tests to work with the new implementation.

**Delete:**
- `TestSetProxyHeaders` - function no longer exists

**Update:**
- All tests that create `&proxy{client: client}` should now create your new proxy

**Add:**
- Test for `rewriteRequest` (if you can - might need to make it testable)
- Test for `errorHandler` with different error types

**Run:**
```bash
go test ./... -v
```

All existing tests should pass with minimal changes.

## Learning Checkpoints

As you implement, make sure you understand:

### Checkpoint 1: ReverseProxy API
- [ ] I understand what `ProxyRequest.In` and `ProxyRequest.Out` represent
- [ ] I understand when `Rewrite`, `ModifyResponse`, and `ErrorHandler` are called
- [ ] I understand the difference between `Director` (old) and `Rewrite` (new)

### Checkpoint 2: URL Manipulation
- [ ] I can parse a URL with `url.Parse()`
- [ ] I understand how to use `SetURL()` to change the target
- [ ] I understand how to join paths correctly (watch out for double slashes!)

### Checkpoint 3: Header Handling
- [ ] I understand which headers ReverseProxy sets automatically
- [ ] I understand when to use `SetXForwarded()` vs setting headers manually
- [ ] I understand hop-by-hop vs end-to-end headers

### Checkpoint 4: Error Handling
- [ ] I can detect specific error types with `errors.As` and `errors.Is`
- [ ] I understand the difference between 502, 504, and 413 status codes
- [ ] I understand how ErrorHandler integrates with the proxy

### Checkpoint 5: Middleware Pattern
- [ ] I understand the `func(http.Handler) http.Handler` pattern
- [ ] I understand when middleware runs vs when the handler runs
- [ ] I understand how to chain multiple middleware functions

## Verification

After implementation, verify:

1. **Functionality:**
   - [ ] Health check still works (`curl localhost:8080/health`)
   - [ ] Requests route correctly (`curl localhost:8080/service1/path`)
   - [ ] Headers are set correctly (X-Real-IP, X-Forwarded-For)
   - [ ] Body size limit works (test with >10MB request)
   - [ ] Error codes are correct (404, 413, 502, 504)

2. **Logging:**
   - [ ] All requests logged with correct format
   - [ ] Status codes captured correctly
   - [ ] Latency measured correctly
   - [ ] Request/response sizes captured

3. **Tests:**
   - [ ] All existing tests pass
   - [ ] New tests added for new functions

## Debugging Tips

**If requests don't route correctly:**
- Add logging in `rewriteRequest` to see what URL is being set
- Check if path joining has double slashes
- Verify `SetURL()` sets scheme, host, and path correctly

**If headers are missing:**
- Check if you called `SetXForwarded()`
- Verify headers are set on `pr.Out.Header`, not `pr.In.Header`
- Check if hop-by-hop stripping removed too many headers

**If errors aren't handled correctly:**
- Add logging in `errorHandler` to see what error types you receive
- Try different error conditions (stop backend, timeout, large body)
- Verify error type checking logic (`errors.As`, `errors.Is`)

**If tests fail:**
- Check if error messages changed (ReverseProxy might use different wording)
- Verify test setup creates new proxy correctly
- Check if response headers differ slightly

## Going Further

After completing the migration, explore:

1. **Read the ReverseProxy source code** in detail - you'll learn about:
   - Buffer pooling for efficiency
   - WebSocket upgrade handling
   - Trailer support
   - Connection handling

2. **Performance comparison:**
   - Benchmark old vs new implementation
   - Is ReverseProxy faster? Why or why not?

3. **Edge cases:**
   - What happens with chunked encoding?
   - How does it handle HEAD requests?
   - What about HTTP/2?

4. **Rate limiting (your next feature):**
   - Where would you add rate limiting? (Another middleware!)
   - How would you track request counts?
   - What data structure would you use?

## Getting Help

As you work through this:

- **Read the Go docs:** `go doc net/http/httputil.ReverseProxy`
- **Read the source:** Understanding stdlib code is a valuable skill
- **Add print statements:** See what values are at each step
- **Run tests frequently:** Catch issues early
- **Ask questions:** About concepts, Go syntax, or specific errors

Remember: The goal is to learn how to use `httputil.ReverseProxy` effectively, understand its design patterns, and see how the stdlib abstracts proxy logic. Take your time and make sure you understand each step!
