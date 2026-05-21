# ClanDemotedEvent

- Producer: `service-clan`
- Intended consumers: future analytics/moderation modules
- Exchange: `yomu.events`
- Routing key: `yomu.clan.demoted`
- Java type: `id.ac.ui.cs.advprog.yomu.shared.event.ClanDemotedEvent`

## Purpose

Menandakan sebuah clan turun tier pada proses end-of-season. Event diterbitkan per anggota accepted untuk menjaga kontrak end-of-season tetap event-driven.

## Fields

- `seasonId` (`UUID`): identifier siklus end-of-season.
- `clanId` (`UUID`): identifier clan.
- `userId` (`UUID`): identifier anggota clan penerima efek degradasi.
- `clanName` (`String`): nama clan saat event diterbitkan.
- `previousTier` (`String`): tier sebelum degradasi.
- `newTier` (`String`): tier setelah degradasi.
- `occurredAt` (`Instant`): waktu event diterbitkan.
