# Setup & Design Baseline

Dokumen ini mencatat baseline setup proyek agar tim bisa mengisi modul secara paralel dengan aturan yang konsisten.

## Repository baseline

- Default branch aktif: `main`
- Integration branch aktif: `staging`
- Workflow GitHub Actions ada di `.github/workflows/`
- Frontend dan backend sudah dipisah menjadi aplikasi terpisah

## Branching strategy

- `main`: branch produksi, hanya menerima merge dari pull request yang sudah lolos review dan CI.
- `staging`: branch integrasi, dipakai untuk menggabungkan pekerjaan lintas modul sebelum dinaikkan ke `main`.
- `feat/<module-or-scope>`: branch kerja tim per fitur atau per modul.

## Recommended branch protection

Aturan berikut perlu diaktifkan di GitHub repository settings:

- Protect branch `main`
- Protect branch `staging`
- Require pull request before merging
- Require status checks to pass before merging
- Required checks:
  - `Frontend Quality / quality`
  - `Backend Quality / quality`
- Restrict direct pushes

## Backend design

- Backend memakai modular packages:
  - `achievements`
  - `auth`
  - `clan`
  - `forum`
  - `learning`
- Kontrak event publik antar modul ada di `docs/contracts/`
- Setiap modul diarahkan memiliki datasource sendiri melalui `ModuleDatabaseConfiguration`, tetapi semuanya mengarah ke satu database shared dengan schema masing-masing modul

## Local/dev security profile

- Konfigurasi keamanan lokal berada di `backend/src/main/java/id/ac/ui/cs/advprog/yomu/config/LocalDevelopmentSecurityConfig.java`
- Konfigurasi ini hanya aktif jika property `yomu.security.bypass=true` diset
- Tujuan utamanya mempermudah pengujian lokal (misalnya Postman) lintas modul tanpa hambatan security default
- Saat aktif, CSRF protection dan authentication requirement dinonaktifkan untuk mempercepat iterasi development

## Usage guidance

- Development lokal default: aktifkan `spring.profiles.active=local`
- Untuk pengujian manual endpoint `POST/PUT/DELETE`, tetap gunakan profile `local`, lalu aktifkan `yomu.security.bypass=true` hanya bila ingin mematikan security sementara
- Local profile memakai `spring.datasource.url` tunggal yang disiapkan di `backend/src/main/resources/application-local.properties`
- Untuk production/staging, profile harus menggunakan `prod` dan jangan set `yomu.security.bypass=true`

## Production safety

- Konfigurasi `LocalDevelopmentSecurityConfig` tidak boleh digunakan di production
- Pastikan konfigurasi security production (auth/authorization/CSRF) dipisahkan dan hanya aktif di profile production

## Frontend design

- Frontend memakai React + Vite
- Basic quality gate:
  - lint
  - test
  - build
