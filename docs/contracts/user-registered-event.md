# UserRegisteredEvent

- Producer: `auth`
- Intended consumers: `achievements`, `clan`, `forum`, `learning`
- Java type: `id.ac.ui.cs.advprog.yomu.auth.UserRegisteredEvent`

## Purpose

Menandakan akun user baru berhasil dibuat dan sudah aman dipakai modul lain untuk inisialisasi data turunan.

## Fields

- `userId` (`UUID`): identifier unik user.
- `username` (`String`): username publik saat akun dibuat.
- `email` (`String`): email utama user.
- `occurredAt` (`Instant`): waktu event diterbitkan.

## Example

```json
{
  "userId": "91f88e2b-4aa2-4e0b-93fb-31cb0e0c0a2a",
  "username": "indra",
  "email": "indra@example.com",
  "occurredAt": "2026-04-21T08:15:30Z"
}
```
