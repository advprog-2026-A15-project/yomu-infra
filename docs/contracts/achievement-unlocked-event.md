# AchievementUnlockedEvent

- Producer: `achievements`
- Intended consumers: `forum`, `clan`, `learning`
- Java type: `id.ac.ui.cs.advprog.yomu.achievements.AchievementUnlockedEvent`

## Purpose

Menandakan user membuka achievement baru sehingga modul lain bisa menampilkan feed, badge, atau side effect lain tanpa membaca database achievements secara langsung.

## Fields

- `userId` (`UUID`): identifier user pemilik achievement.
- `achievementCode` (`String`): kode stabil achievement untuk integrasi antar modul.
- `achievementName` (`String`): nama tampilan achievement saat event diterbitkan.
- `occurredAt` (`Instant`): waktu unlock terjadi.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "achievementCode": "FIRST_READ",
  "achievementName": "First Read",
  "occurredAt": "2026-04-21T09:05:00Z"
}
```
