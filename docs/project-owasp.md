# Project OWASP Top 10 Coverage

## Summary

This document maps Yomu's current security controls to OWASP Top 10 2021 and
records the project-level hardening applied at the API edge.

Implemented in this pass:

- Explicit API Gateway CORS request headers instead of wildcard request headers.
- Nginx security headers for clickjacking, MIME sniffing, referrer leakage,
  browser feature permissions, and baseline CSP.
- Nginx edge rate limiting for `/api/auth/**` before requests reach
  `service-auth`.

## OWASP Top 10 Mapping

| OWASP area | Current project control | Status |
| :-- | :-- | :-- |
| A01 Broken Access Control | API Gateway validates JWT for non-public routes; services use stateless JWT filters and method/security rules for admin or owner-only actions. | Implemented, needs production bypass audit |
| A02 Cryptographic Failures | Passwords use BCrypt; JWT signing is centralized in `shared-lib`; secrets are configured through environment variables for deployment. | Implemented, rotate defaults before production |
| A03 Injection | Repository code uses JDBC/JPA parameter binding patterns; React renders user content as text; no `dangerouslySetInnerHTML` usage was found. | Implemented |
| A04 Insecure Design | RBAC, public-route boundaries, rate limiting, monitoring, and event idempotency are documented as design controls. | Partially implemented |
| A05 Security Misconfiguration | Nginx now emits security headers and hides version tokens; CORS has explicit allowed origins and request headers. | Implemented |
| A06 Vulnerable and Outdated Components | Gradle/npm dependencies are pinned by lockfiles where present. | Needs routine dependency scanning |
| A07 Identification and Authentication Failures | Auth endpoints use rate limiting, BCrypt, JWT access/refresh tokens, and Google SSO validation. | Implemented |
| A08 Software and Data Integrity Failures | Event contracts are documented; RabbitMQ events are typed in `shared-lib`. | Partially implemented |
| A09 Security Logging and Monitoring Failures | Request logging, auth metrics, rate-limit metrics, Prometheus, and Grafana dashboards are present. | Implemented |
| A10 Server-Side Request Forgery | No user-controlled outbound URL fetch path was found in the current codebase. | Not currently applicable |

## Applied Edge Controls

### Security Headers

The Nginx reverse proxy and frontend Nginx config now set:

- `Content-Security-Policy`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- `Cross-Origin-Opener-Policy: same-origin-allow-popups`

The CSP allows the React app itself, Google OAuth, Google Fonts, known API
origins, and SSE/API calls to same-origin routes. It blocks object embedding,
limits frame ancestors, restricts form submission to same origin, and keeps the
Google popup flow usable.

### Rate Limiting

The Nginx reverse proxy now limits `/api/auth/**` by client IP:

```nginx
limit_req_zone $binary_remote_addr zone=api_auth_limit:10m rate=5r/s;
limit_req zone=api_auth_limit burst=20 nodelay;
limit_req_status 429;
```

This complements the existing `AuthRateLimitFilter`, which applies an
application-level limit to sensitive auth endpoints.

### CORS

The API Gateway keeps the existing allowlist of local, staging, and deployment
origins, but request headers are now explicit:

```text
Accept, Authorization, Content-Type, Origin, X-Requested-With
```

This avoids combining credentialed CORS with wildcard request headers.

## Remaining Risks

- Several local `docker-compose.yml` services use `YOMU_SECURITY_BYPASS=true`.
  That is acceptable for local development only and must stay disabled in
  staging/production.
- The shared JWT service has a fallback secret for local use. Production should
  always inject a strong secret through environment variables.
- RabbitMQ and Grafana development credentials are defaults in local compose.
  Production deployment must override them.
- Frontend tokens are stored in `localStorage`, which is exposed if XSS occurs.
  Long-term hardening should move refresh tokens to secure HttpOnly cookies or
  use a backend-for-frontend session pattern.
- Dependency scanning is not automated in this repo. Add Dependabot or a CI
  step for Gradle and npm vulnerability checks.
