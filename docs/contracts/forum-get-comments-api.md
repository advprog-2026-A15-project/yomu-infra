# GET /api/forum/comments

- Provider: `forum`
- Intended consumers: `achievements`, `clan`, `learning`, `frontend`
- Controller method: `id.ac.ui.cs.advprog.yomu.forum.internal.controller.CommentController#getComments`

## Purpose

Menyediakan daftar komentar forum agar modul lain bisa membaca komentar tanpa mengakses database forum secara langsung.

## Request

- Method: `GET`
- Path: `/api/forum/comments`
- Query params:
  - `bacaanId` (`String`, optional): jika diisi, hanya komentar untuk bacaan tersebut yang dikembalikan.

## Response

- Status: `200 OK`
- Body type: `CommentResponse[]`
- JSON fields per item:
  - `commentId` (`String`): identifier unik komentar.
  - `userId` (`String`): identifier user pembuat komentar.
  - `bacaanId` (`String`): identifier bacaan yang dikomentari.
  - `parentComment` (`String`): identifier komentar induk; bernilai `root` untuk komentar top-level.
  - `commentContent` (`String`): isi komentar.
  - `timestamp` (`Instant`): waktu komentar dibuat dalam format ISO-8601 UTC.

## Examples

### Request (all comments)

```http
GET /api/forum/comments
```

### Request (filtered by bacaan)

```http
GET /api/forum/comments?bacaanId=299bc3b7-3bb7-4dae-8d9a-621fd072594f
```

### Response (`200 OK`)

```json
[
  {
    "commentId": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
    "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
    "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
    "parentComment": "root",
    "commentContent": "Materinya sangat membantu.",
    "timestamp": "2026-04-23T10:00:00Z"
  }
]
```

