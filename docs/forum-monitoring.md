# Forum Monitoring

This workspace now exposes forum-specific Prometheus metrics from `service-forum` and provisions a Grafana dashboard automatically.

## Run It

1. Start the stack with Docker Compose.
2. Open Prometheus at `http://localhost:9090`.
3. Open Grafana at `http://localhost:3000` with `admin` / `admin`.
4. The dashboard is named `Yomu Forum Monitoring`.

## What Triggers the Graphs

The dashboard is fed by forum actions in `service-forum`:

- `POST /api/forum/comments` creates a comment or reply and drives the `create` graph.
- `PUT /api/forum/comments/{commentId}` updates a comment and drives the `update` graph.
- `DELETE /api/forum/comments/{commentId}` deletes a comment and drives the `delete` graph.
- `POST /api/forum/comments/{commentId}/reactions` adds a reaction and drives both the `react` graph and the reaction-type breakdown.
- `GET /api/forum/comments` drives the `list` graph.
- `GET /api/forum/comments/tree` drives the `tree` graph.

## Metrics Exposed

- `yomu_forum_comment_actions_total{action,outcome}` for request volume.
- `yomu_forum_comment_action_duration_seconds_bucket` and related timer series for latency.
- `yomu_forum_comment_reactions_total{reaction_type,outcome}` for reaction mix.

The graphs show successful actions by default and split failures into a separate panel so you can see both traffic and error spikes.
