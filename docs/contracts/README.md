# Contracts

Dokumen di folder ini mendefinisikan kontrak antar service pada arsitektur microservice `yomu`.

Aturan umum:

- Event publik ditempatkan di `shared-lib` package `id.ac.ui.cs.advprog.yomu.shared.event`.
- Kontrak dianggap stabil dan versioning dilakukan secara additive.
- Consumer antar service hanya boleh bergantung pada field yang terdokumentasi di sini.
- Perubahan breaking harus disertai version baru atau strategi migrasi yang jelas.
- Event AMQP dikirim melalui topic exchange `yomu.events`.

## Event Contracts

- `UserRegisteredEvent`
- `LearningCompletedEvent`
- `QuizCompletedEvent`
- `LeagueActivityEvent`
- `AchievementUnlockedEvent`
- `DailyMissionCompletedEvent`
- `ClanPromotedEvent`
- `ClanDemotedEvent`
- `CommentCreatedEvent`
- `CommentUpdatedEvent`
- `CommentDeletedEvent`

## HTTP API Contracts

- `POST /api/forum/comments` (mendukung `parentComment` untuk reply)
- `GET /api/forum/comments` (mendukung `parentComment` pada response dan reply nested lewat `POST` komentar)
- `GET /api/forum/comments/tree` (mengembalikan komentar dalam struktur nested)
- `PUT /api/forum/comments/{commentId}` (memperbarui isi komentar)
- `DELETE /api/forum/comments/{commentId}` (menghapus komentar)

