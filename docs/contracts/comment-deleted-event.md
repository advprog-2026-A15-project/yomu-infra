# CommentDeletedEvent

- Producer: `forum`
- Intended consumers: `achievements`, `clan`, `learning`
- Java type: `id.ac.ui.cs.advprog.yomu.forum.CommentDeletedEvent`

## Purpose

Menandakan komentar berhasil dihapus sehingga modul lain bisa memperbarui state turunannya tanpa mengakses database forum.

## Fields

- `userId` (`String`): identifier user pemilik komentar.
- `bacaanId` (`String`): identifier bacaan yang dikomentari.
- `parentComment` (`String`): identifier komentar induk; `root` jika komentar top-level.
- `commentId` (`String`): identifier komentar yang dihapus.
- `commentContent` (`String`): isi komentar saat dihapus.
- `timestamp` (`Instant`): waktu penghapusan komentar.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "parentComment": "root",
  "commentId": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
  "commentContent": "Komentar lama yang dihapus.",
  "timestamp": "2026-04-23T10:12:00Z"
}
```

