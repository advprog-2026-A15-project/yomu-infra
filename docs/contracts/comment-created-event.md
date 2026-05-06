# CommentCreatedEvent

- Producer: `forum`
- Intended consumers: `achievements`, `clan`, `learning`
- Java type: `id.ac.ui.cs.advprog.yomu.forum.CommentCreatedEvent`

## Purpose

Menandakan komentar baru berhasil dibuat sehingga modul lain bisa memproses feed aktivitas, metrik, atau reward tanpa mengakses database forum secara langsung.

## Fields

- `userId` (`String`): identifier user pembuat komentar.
- `bacaanId` (`String`): identifier bacaan yang dikomentari.
- `parentComment` (`String`): identifier komentar induk; bernilai `root` untuk komentar top-level.
- `commentId` (`String`): identifier unik komentar yang baru dibuat.
- `commentContent` (`String`): isi komentar pada saat event diterbitkan.
- `timestamp` (`Instant`): waktu komentar dibuat.

## Example

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

