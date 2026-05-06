# PUT /api/forum/comments/{commentId}

- Provider: `forum`
- Intended consumers: `frontend`
- Controller method: `id.ac.ui.cs.advprog.yomu.forum.internal.controller.CommentController#updateComment`

## Purpose

Memperbarui isi komentar yang sudah ada dan menerbitkan event pembaruan komentar.

## Request

- Method: `PUT`
- Path: `/api/forum/comments/{commentId}`
- Path params:
  - `commentId` (`String`, required): identifier komentar yang ingin diubah.
- Body fields:
  - `commentContent` (`String`, required): isi komentar terbaru.

## Response

- Status: `200 OK`
- Body type: `CommentUpdatedEvent`

## Error Response

- `404 Not Found`: komentar dengan `commentId` tidak ditemukan.

## Example

### Request

```http
PUT /api/forum/comments/f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce
Content-Type: application/json
```

```json
{
  "commentContent": "Konten komentar setelah diedit."
}
```

### Response (`200 OK`)

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "parentComment": "root",
  "commentId": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
  "commentContent": "Konten komentar setelah diedit.",
  "timestamp": "2026-04-23T10:10:00Z"
}
```

