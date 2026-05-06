# CommentUpdatedEvent

- Producer: `forum`
- Intended consumers: `achievements`, `clan`, `learning`
- Java type: `id.ac.ui.cs.advprog.yomu.forum.CommentUpdatedEvent`

## Purpose

Menandakan isi komentar berhasil diperbarui sehingga modul lain bisa menyinkronkan feed atau metrik tanpa membaca database forum secara langsung.

## Fields

- `userId` (`String`): identifier user pemilik komentar.
- `bacaanId` (`String`): identifier bacaan yang dikomentari.
- `parentComment` (`String`): identifier komentar induk; `root` jika komentar top-level.
- `commentId` (`String`): identifier komentar yang diubah.
- `commentContent` (`String`): isi komentar setelah diubah.
- `timestamp` (`Instant`): waktu perubahan komentar.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "parentComment": "root",
  "commentId": "f8d0f6df-3c31-4a4c-8b5d-9481d36d57ce",
  "commentContent": "Kontennya saya revisi.",
  "timestamp": "2026-04-23T10:10:00Z"
}
```

