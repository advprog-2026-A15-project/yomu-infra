# LearningCompletedEvent

- Producer: `learning`
- Intended consumers: `achievements`
- Java type: `id.ac.ui.cs.advprog.yomu.learning.LearningCompletedEvent`

## Purpose

Menandakan seorang user menyelesaikan satu item bacaan sehingga modul lain dapat memberi reward, statistik, atau notifikasi.

## Fields

- `userId` (`UUID`): identifier user yang menyelesaikan bacaan.
- `bacaanId` (`UUID`): identifier internal konten yang selesai.
- `bacaanSlug` (`String`): identifier yang aman dipakai untuk logging atau analytics.
- `occurredAt` (`Instant`): waktu penyelesaian dicatat.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "bacaanId": "299bc3b7-3bb7-4dae-8d9a-621fd072594f",
  "bacaanSlug": "spring-modulith-intro",
  "occurredAt": "2026-04-21T09:00:00Z"
}
```
