# Yomu App - Sistem Literasi Berbasis Gamifikasi (Microservices)

Yomu adalah platform aplikasi pembelajaran (gamifikasi) yang membantu masyarakat Indonesia dalam melatih kebiasaan verifikasi dan membaca saksama. Proyek ini diimplementasikan menggunakan arsitektur **Microservices** dengan pola **Monorepo** (Gradle Multi-project) di sisi Backend, dan arsitektur Features-based menggunakan React (Vite) di sisi Frontend.

## 🏗️ Perubahan Arsitektur & Implementasi Terbaru
1. **Migrasi Penuh ke Microservices**: Aplikasi yang sebelumnya monolitik atau setengah jalan telah dipecah secara rapi menjadi service independen:
   - `api-gateway` (Port 8080): Melakukan routing request dari frontend ke service terkait.
   - `service-auth` (Port 8081): Mengurus registrasi, login, dan validasi JWT.
   - `service-learning` (Port 8082): Menangani CRUD Bacaan dan pengerjaan Kuis.
   - `service-achievements` (Port 8083): Menangani sistem pencapaian (Achievements) dan Misi Harian.
   - `service-forum` (Port 8084): Diskusi publik bersarang (nested comments).
   - `service-clan` (Port 8085): Sistem liga dengan Strategy Pattern untuk scoring yang berbeda tiap Tier (Bronze, Silver, Gold, Diamond).
   - `shared-lib`: Menyimpan DTO, Security configurations (JWT Filters), dan Event objects.

2. **Pola Desain (Design Patterns) & SOLID**:
   - **Single Responsibility Principle (SRP)**: Setiap Service hanya mengurusi domainnya masing-masing.
   - **Open/Closed Principle (OCP) & Strategy Pattern**: Diterapkan secara nyata pada sistem *Scoring Liga* di `service-clan` (`BronzeScoringStrategy`, `SilverScoringStrategy`, dst). Menambah Tier baru tidak akan merusak sistem yang ada.
   - **Event-Driven Communication**: Komunikasi antar microservice menggunakan sistem Event (`LearningCompletedEvent`, dsb).

3. **Peningkatan Frontend (Gamifikasi)**:
   - Mengimplementasikan desain antarmuka bergaya *gamified* (seperti platform populer Duolingo).
   - Menggunakan tombol dengan aksen bayangan tebal, tipografi tegas (Nunito), dan kartu (cards) dengan interaksi dinamis.
   - Halaman **Learning/Modul Belajar** yang interaktif (transisi mode Membaca -> Kuis -> Selesai).
   - Papan Peringkat (**Leaderboard Liga**) yang dapat disaring berdasarkan Divisi/Tier.

## 🚀 Panduan Deployment (Menjalankan Proyek Lokal)

### Persyaratan Sistem
- Java 21 (JDK)
- Node.js (v18 atau lebih tinggi)
- Docker Desktop (Jika ingin menjalankan lewat container)

### Opsi 1: Menjalankan Menggunakan Docker Compose (Direkomendasikan)
Cara termudah untuk mengangkat keseluruhan arsitektur sekaligus.
1. Buka terminal dan arahkan ke direktori backend:
   ```bash
   cd backend
   ```
2. Build dan jalankan menggunakan Docker Compose:
   ```bash
   docker-compose up --build
   ```
   *Proses ini akan mengunduh dependencies, membangun file JAR, dan menjalankan semua service + API Gateway dalam network Docker terisolasi.*

3. Buka terminal baru dan arahkan ke direktori frontend:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
4. Buka browser di `http://localhost:5173`. Frontend sudah otomatis terkoneksi ke API Gateway.

### Opsi 2: Menjalankan Manual (Native Spring Boot)
Jika ingin melakukan debug langsung di IDE:
1. Buka terminal di direktori `backend`.
2. Anda perlu menjalankan setiap service menggunakan command gradle secara terpisah atau melalui IDE (IntelliJ/Eclipse).
   ```bash
   # Jalankan satu per satu di terminal terpisah
   ./gradlew :api-gateway:bootRun
   ./gradlew :service-auth:bootRun
   ./gradlew :service-learning:bootRun
   ./gradlew :service-achievements:bootRun
   ./gradlew :service-forum:bootRun
   ./gradlew :service-clan:bootRun
   ```
3. Database menggunakan H2 (file-based) yang otomatis dibuat di `backend/.localdb/` untuk persistensi data antar run.
4. Jalankan frontend:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

## 🔐 Keamanan
Sistem menggunakan **JSON Web Token (JWT)**. Setiap request dari frontend ke backend (melalui Gateway) akan divalidasi keabsahan tokennya oleh `JwtAuthenticationFilter` yang berada di dalam `shared-lib` dan diimpor oleh setiap service secara terpisah untuk memvalidasi otorisasi.

