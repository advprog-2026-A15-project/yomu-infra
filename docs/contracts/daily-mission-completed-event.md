# DailyMissionCompletedEvent

- Producer: `service-achievements`
- Intended consumers: `service-clan`
- Exchange: `yomu.events`
- Routing key: `yomu.daily.mission.completed`
- Java type: `id.ac.ui.cs.advprog.yomu.shared.event.DailyMissionCompletedEvent`

## Purpose

Menandakan user menyelesaikan Daily Mission sehingga modul Liga dapat mengaktifkan buff clan secara asinkron.

## Fields

- `userId` (`UUID`): identifier user.
- `missionId` (`UUID`): identifier Daily Mission.
- `missionName` (`String`): nama Daily Mission saat event diterbitkan.
- `occurredAt` (`Instant`): waktu event diterbitkan.
