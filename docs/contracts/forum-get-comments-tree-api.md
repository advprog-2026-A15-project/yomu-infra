# GET /api/forum/comments/tree

- Provider: `forum`
- Intended consumers: `frontend`, `achievements`, `clan`, `learning`
- Controller method: `id.ac.ui.cs.advprog.yomu.forum.internal.controller.CommentController#getCommentsTree`

## Purpose

Menyediakan komentar dalam struktur tree (nested) berdasarkan relasi `parentComment`, sehingga consumer tidak perlu menyusun hierarchy sendiri dari data flat.

## Request

- Method: `GET`
- Path: `/api/forum/comments/tree`
- Query params:
  - `bacaanId` (`String`, optional): jika diisi, hanya tree komentar untuk bacaan tersebut yang dikembalikan.

## Response

- Status: `200 OK`
- Body type: `CommentTreeResponse[]`
- JSON fields per item:
  - `commentId` (`String`): identifier unik komentar.
  - `userId` (`String`): identifier user pembuat komentar.
  - `bacaanId` (`String`): identifier bacaan yang dikomentari.
  - `parentComment` (`String`): identifier komentar induk; bernilai `root` untuk komentar top-level.
  - `commentContent` (`String`): isi komentar.
  - `timestamp` (`Instant`): waktu komentar dibuat dalam format ISO-8601 UTC.
  - `children` (`CommentTreeResponse[]`): daftar reply langsung terhadap komentar tersebut.

## Notes

- Komentar dengan `parentComment = root` menjadi node root.
- Jika parent tidak ditemukan (orphan), komentar dipromosikan sebagai node root agar data tetap bisa dikonsumsi.

## Example

### Request

```http
GET /api/forum/comments/tree?bacaanId=299bc3b7-3bb7-4dae-8d9a-621fd072594f
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
    "timestamp": "2026-04-23T10:00:00Z",
    "children": [
      {
        "commentId": "8a818005-826f-4b1f-b2e5-5032b0f6b8f8",
        "userId": "d5cb9b15-ff0a-4987-a1b6-f4903830b5b7",
        "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
        "parentComment": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
        "commentContent": "Setuju, penjelasannya jelas.",
        "timestamp": "2026-04-23T10:01:00Z",
        "children": []
      }
    ]
  }
]
```

