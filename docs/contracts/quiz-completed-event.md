# QuizCompletedEvent

- Producer: `learning`
- Intended consumers: `achievements`
- Java type: `id.ac.ui.cs.advprog.yomu.learning.QuizCompletedEvent`

## Purpose

Menandakan seorang user menyelesaikan kuis sehingga modul lain dapat memberi achievement, reward, atau statistik tanpa membaca database learning secara langsung.

## Fields

- `userId` (`UUID`): identifier user yang menyelesaikan kuis.
- `quizId` (`UUID`): identifier internal kuis yang selesai.
- `quizSlug` (`String`): identifier yang aman dipakai untuk logging atau analytics.
- `score` (`int`): skor kuis saat selesai.
- `occurredAt` (`Instant`): waktu penyelesaian dicatat.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "quizId": "9f017a26-12c4-4f7b-a411-c642d06b6df1",
  "quizSlug": "spring-modulith-intro-quiz",
  "score": 90,
  "occurredAt": "2026-04-21T09:10:00Z"
}
```
