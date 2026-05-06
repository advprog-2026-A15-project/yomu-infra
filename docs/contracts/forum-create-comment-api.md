# POST /api/forum/comments

- Provider: `forum`
- Intended consumers: `frontend`, `achievements`, `clan`, `learning`
- Controller method: `id.ac.ui.cs.advprog.yomu.forum.internal.controller.CommentController#createComment`

## Purpose

Membuat komentar baru di forum, baik komentar top-level maupun reply ke komentar lain, tanpa consumer perlu menyentuh database forum secara langsung.

## Request

- Method: `POST`
- Path: `/api/forum/comments`
- Body fields:
  - `userId` (`String`, required): identifier user pembuat komentar.
  - `bacaanId` (`String`, required): identifier bacaan yang dikomentari.
  - `commentContent` (`String`, required): isi komentar.
  - `parentComment` (`String`, optional): identifier komentar induk; gunakan `root` untuk komentar top-level.

## Response

- Status: `201 Created`
- Body type: `CommentCreatedEvent`
- JSON fields:
  - `userId` (`String`)
  - `bacaanId` (`String`)
  - `parentComment` (`String`)
  - `commentId` (`String`)
  - `commentContent` (`String`)
  - `timestamp` (`Instant`)

## Examples

### Request (top-level comment)

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "commentContent": "Materinya sangat membantu.",
  "parentComment": "root"
}
```

### Request (reply)

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "commentContent": "Setuju, penjelasannya jelas.",
  "parentComment": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce"
}
```

### Response (`201 Created`)

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "parentComment": "root",
  "commentId": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
  "commentContent": "Materinya sangat membantu.",
  "timestamp": "2026-04-23T10:00:00Z"
}
```

