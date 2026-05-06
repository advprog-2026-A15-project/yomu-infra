# Contracts

Dokumen di folder ini mendefinisikan kontrak antar modul pada modular monolith `yomu`.

Aturan umum:

- Event publik ditempatkan di package modul yang tidak memakai `internal`.
- Kontrak dianggap stabil dan versioning dilakukan secara additive.
- Consumer antar modul hanya boleh bergantung pada field yang terdokumentasi di sini.
- Perubahan breaking harus disertai version baru atau strategi migrasi yang jelas.

## Event Contracts

- `auth.UserRegisteredEvent`
- `learning.LearningCompletedEvent`
- `learning.QuizCompletedEvent`
- `clan.LeagueActivityEvent`
- `achievements.AchievementUnlockedEvent`
- `forum.CommentCreatedEvent`
- `forum.CommentUpdatedEvent`
- `forum.CommentDeletedEvent`

## HTTP API Contracts

- `POST /api/forum/comments` (mendukung `parentComment` untuk reply)
- `GET /api/forum/comments` (mendukung `parentComment` pada response dan reply nested lewat `POST` komentar)
- `GET /api/forum/comments/tree` (mengembalikan komentar dalam struktur nested)
- `PUT /api/forum/comments/{commentId}` (memperbarui isi komentar)
- `DELETE /api/forum/comments/{commentId}` (menghapus komentar)

