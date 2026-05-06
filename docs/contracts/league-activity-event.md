# LeagueActivityEvent

- Producer: `clan`
- Intended consumers: `achievements`
- Java type: `id.ac.ui.cs.advprog.yomu.clan.LeagueActivityEvent`

## Purpose

Menandakan aktivitas user yang relevan untuk progres liga sehingga modul lain dapat memberi achievement atau reward tanpa mengakses database clan/liga secara langsung.

## Fields

- `userId` (`UUID`): identifier user pemilik aktivitas.
- `leagueId` (`UUID`): identifier liga.
- `activityId` (`UUID`): identifier unik aktivitas liga.
- `activityType` (`String`): jenis aktivitas liga.
- `occurredAt` (`Instant`): waktu aktivitas dicatat.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "leagueId": "4d8109f4-d9e4-44fb-9ba0-5358c7a9e835",
  "activityId": "fe5a2834-94ad-48b6-b02a-a8f2d486fcd7",
  "activityType": "WEEKLY_POINT_GAINED",
  "occurredAt": "2026-04-21T10:00:00Z"
}
```
