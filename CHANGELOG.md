## [0.4.0] - 2026-09-15

### Breaking changes

- Endpoints now offer `authenticated?` and `authorized?` hooks for plugging in your own auth handlers. Both default to `false` to prevent endpoints from being exposed accidentally, so every existing endpoint responds with a 401 until it overrides them. Applications upgrading from older versions must override these methods, either to return `true` or with code that handles auth.

### Added

- Responds with `401 Authentication required` when `authenticated?` returns `false`, and with `403 Forbidden` when `authorized?` returns `false`. The endpoint's status, headers, and content are only consulted when both return `true`.
- Adds a `www_authenticate_header` hook to endpoints. When it returns a challenge, such as `Bearer realm="api"`, 401 responses include it as the `WWW-Authenticate` header. It defaults to `nil`, which omits the header.
- Exposes the request's `Authorization` header as `request.headers[:authorization]` so endpoints can read credentials.
- Responds to `HEAD` requests that fail auth with an empty body and a `content-length` header, as the Rack specification requires.

## [0.3.1] - 2026-09-07

### Fixed

- Responds to `HEAD` requests with an empty body, as the Rack specification requires. Status and headers, including `content-length`, still describe what the matching `GET` would return.
- Responds to `HEAD` requests for unknown routes with a 404 and an empty body.
- Builds the 404 response per request instead of reusing a frozen constant, which Rack::Lint rejects.

### Changed

- Adds `qlty` and `flog` tasks to the default Rake task, alongside `spec` and `standard`.

## [0.3.0] - 2026-09-06

### Breaking changes

- Requires Ruby 3.3 or newer (previously 3.1). Ruby 3.1 and 3.2 are past end of life, and the updated dependencies no longer support them.
- Requires Rack 3.1 or newer (previously 2.2). Response headers are now emitted in lowercase (`content-type`, `content-length`), as Rack 3 requires. Applications that read Liberty's response headers by their capitalized names should switch to lowercase.

### Fixed

- Handles requests with no `rack.input`, which Rack 3.1 made optional. Previously a bodiless request raised `NoMethodError`.
- Only rewinds the request body when it supports `rewind`, since Rack 3 no longer guarantees a rewindable input.

### Changed

- Updates mustermann and mustermann-contrib to 4.x.
- Pins runtime dependencies with pessimistic version constraints.
- Moves development dependencies from the gemspec to the Gemfile.
- Enables SimpleCov branch coverage and enforces 100% line and branch coverage in CI.
- Tests against Ruby 3.3, 3.4, and 4.0 in CI.

### Removed

- Removes the Code Climate integration and badges. Code Climate Quality has shut down.

## [0.2.1] - 2022-04-30

- Handles situation where CORS headers are nil

## [0.2.0] - 2022-04-27

- Adds ability to add your own Rack middleware

## [0.1.1] - 2022-04-24

- Ensures use of frozen string literals

## [0.1.0] - 2022-04-22

- Initial release
