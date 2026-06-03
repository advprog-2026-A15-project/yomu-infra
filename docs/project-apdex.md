# Project Apdex Score

## Summary

The project-wide Apdex score from the available profiling evidence is
**0.9996** (`99.96%`), or **1.000** when rounded to three decimals.

This score uses `T = 500 ms` as the satisfied threshold. Requests at or below
`500 ms` are classified as satisfied, requests above `500 ms` and at or below
`2 s` are classified as tolerating, and requests above `2 s` are classified as
frustrated.

```text
Apdex = (satisfied + (tolerating / 2)) / total
```

## Calculation

| Service | Evidence source | Total samples | Satisfied `<= 500 ms` | Tolerating `> 500 ms and <= 2 s` | Frustrated `> 2 s` | Apdex |
| :-- | :-- | --: | --: | --: | --: | --: |
| `service-auth` | Profiling doc endpoint averages | 350 | 350 | 0 | 0 | 1.0000 |
| `service-learning` | HTTP metrics snapshot | 32 | 31 | 1 | 0 | 0.9844 |
| `service-clan` | HTTP metrics snapshot | 277 | 277 | 0 | 0 | 1.0000 |
| `service-achievements` | Action timer snapshot | 454 | 454 | 0 | 0 | 1.0000 |
| **Overall profiled backend** | Combined available evidence | **1113** | **1112** | **1** | **0** | **0.9996** |

Project calculation:

```text
Apdex = (1112 + (1 / 2)) / 1113
      = 1112.5 / 1113
      = 0.9996
```

## Service Notes

- `service-auth`: the profiling document records `100` login requests at
  `450 ms` average, `50` register requests at `480 ms` average, and `200`
  refresh requests at `15 ms` average. The Prometheus snapshot file is marked as
  mock data, so this service score is derived from the profiling document's
  endpoint averages rather than histogram buckets.
- `service-learning`: the HTTP metrics snapshot records `32` API requests.
  `POST /api/learning/bacaan` took `539.6235 ms` for one request, so that single
  request is classified as tolerating. The other recorded Learning HTTP
  endpoints are below `500 ms` by the available endpoint timing evidence.
- `service-clan`: the HTTP metrics snapshot records `277` API requests, and the
  slowest recorded API request max is `198.402959 ms`, so all samples are
  satisfied.
- `service-achievements`: the action timer snapshot records `454` API action
  samples, and all recorded action durations are below `500 ms`, so all samples
  are satisfied.

## Scope And Limits

This is the Apdex score for the backend services that currently have profiling
evidence in the repository: `service-auth`, `service-learning`, `service-clan`,
and `service-achievements`.

The score does not include `frontend`, `api-gateway`, `service-forum`, or
`service-notification`, because this repository does not currently include
comparable profiling latency snapshots for those components. A true production
or staging project Apdex should be calculated from gateway-level request
histograms across all user-facing routes.
