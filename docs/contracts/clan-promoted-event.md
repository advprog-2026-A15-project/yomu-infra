# ClanPromotedEvent

- Producer: `service-clan`
- Intended consumers: `service-achievements`
- Exchange: `yomu.events`
- Routing key: `yomu.clan.promoted`
- Java type: `id.ac.ui.cs.advprog.yomu.shared.event.ClanPromotedEvent`

## Purpose

Menandakan sebuah clan naik tier pada proses end-of-season. Event diterbitkan per anggota accepted agar modul achievement dapat memberi progres tanpa membaca database clan.

## Fields

- `seasonId` (`UUID`): identifier siklus end-of-season.
- `clanId` (`UUID`): identifier clan.
- `userId` (`UUID`): identifier anggota clan penerima efek promosi.
- `clanName` (`String`): nama clan saat event diterbitkan.
- `previousTier` (`String`): tier sebelum promosi.
- `newTier` (`String`): tier setelah promosi.
- `occurredAt` (`Instant`): waktu event diterbitkan.
