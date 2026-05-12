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
    - **Open/Closed Principle (OCP) & Strategy Pattern**: Diterapkan secara nyata pada sistem _Scoring Liga_ di `service-clan` (`BronzeScoringStrategy`, `SilverScoringStrategy`, dst). Menambah Tier baru tidak akan merusak sistem yang ada.
    - **Event-Driven Communication**: Komunikasi antar microservice menggunakan sistem Event (`LearningCompletedEvent`, dsb).

3. **Peningkatan Frontend (Gamifikasi)**:
    - Mengimplementasikan desain antarmuka bergaya _gamified_ (seperti platform populer Duolingo).
    - Menggunakan tombol dengan aksen bayangan tebal, tipografi tegas (Nunito), dan kartu (cards) dengan interaksi dinamis.
    - Halaman **Learning/Modul Belajar** yang interaktif (transisi mode Membaca -> Kuis -> Selesai).
    - Papan Peringkat (**Leaderboard Liga**) yang dapat disaring berdasarkan Divisi/Tier.

## 🚀 Panduan Deployment (Menjalankan Proyek Lokal)

### Persyaratan Sistem

- Java 21 (JDK)
- Node.js (v18 atau lebih tinggi)
- Git

### Mengunduh Semua Repositori

Proyek ini sekarang terdiri dari beberapa repository terpisah. Untuk mempermudah pengunduhan semua repositori, tersedia skrip otomasi di root proyek:

- `clone-repositories.bat` — skrip untuk Windows (CMD/PowerShell).
- `clone-repositories.sh` — skrip untuk macOS / Linux (bash).

Contoh penggunaan (dry-run, hanya menampilkan tindakan):

```bash
./clone-repositories.sh --dry-run
```

Contoh penggunaan penuh dan menarik perubahan untuk repositori yang sudah ada:

```bash
./clone-repositories.sh /path/to/target --pull
clone-repositories.bat C:\path\to\target --pull
```

Skrip akan mengkloning repositori berikut ke folder dengan nama yang sama:

- `api-gateway`
- `frontend`
- `service-achievements`
- `service-auth`
- `service-clan`
- `service-forum`
- `service-learning`
- `shared-lib`

Jika Anda sudah berada di folder root proyek (`yomu-infra`), cukup jalankan skrip tanpa argumen.

### Opsi: Menjalankan Menggunakan Docker Compose (Recommended untuk Isolasi & Kemudahan)

Jika Anda ingin menjalankan seluruh arsitektur secara terisolasi dengan container, tersedia file `docker-compose.yml` di root proyek.

- Persyaratan: `Docker` + `Docker Compose` (atau Docker Desktop yang sudah include compose plugin).
- Pastikan semua repositori service sudah ada di folder root (lihat skrip `clone-repositories.*`) atau sesuaikan `docker-compose.yml` jika Anda menaruh source di lokasi lain.

Langkah singkat:

```bash
# Dari folder root repository (yomu-infra)
docker compose up --build
# atau jika menggunakan docker-compose lama:
docker-compose up --build
```

- Untuk frontend:

```bash
cd frontend
npm install
npm run dev
```

- Akses aplikasi di `http://localhost:5173` (Vite default port) dan API Gateway di `http://localhost:8080`.

Penjelasan singkat:

- Perintah ini akan membangun image untuk setiap service menggunakan masing-masing `Dockerfile` dan menjalankan container dalam satu network.
- Pastikan `gradlew` memiliki permission executable (sudah di-set dalam repo: `git update-index --chmod=+x gradlew`).
- Folder `docs/` tetap utuh dan tidak diubah oleh skrip-kloning atau proses ini.

### Menjalankan Layanan Secara Manual (Native Spring Boot)

Untuk debugging atau pengembangan lokal tiap service, jalankan setiap service dari foldernya masing-masing.

Contoh menjalankan `service-auth` dari PowerShell / bash:

```bash
cd service-auth
./gradlew bootRun   # Windows: gradlew.bat bootRun
```

Jalankan setiap service di terminal terpisah:

```bash
cd api-gateway && ./gradlew bootRun &
cd service-auth && ./gradlew bootRun &
cd service-learning && ./gradlew bootRun &
cd service-achievements && ./gradlew bootRun &
cd service-forum && ./gradlew bootRun &
cd service-clan && ./gradlew bootRun &
```

Keterangan:

- Gunakan `gradlew.bat` di Windows jika `./gradlew` tidak berjalan.
- Database default adalah H2 (file-based) yang disimpan di folder per-service jika dikonfigurasi — periksa `application.properties`/`application.yml` di masing-masing service untuk lokasi file H2.
- Untuk frontend:

```bash
cd frontend
npm install
npm run dev
```

- Akses aplikasi di `http://localhost:5173` (Vite default port) dan API Gateway di `http://localhost:8080`.

## 🔐 Keamanan

Sistem menggunakan **JSON Web Token (JWT)**. Setiap request dari frontend ke backend (melalui Gateway) akan divalidasi keabsahan tokennya oleh `JwtAuthenticationFilter` yang berada di dalam `shared-lib` dan diimpor oleh setiap service secara terpisah untuk memvalidasi otorisasi.



## MODULE 9 - GROUP DISCUSSION
## 🏗️ Arsitektur Sistem Saat Ini

Yomu mengadopsi arsitektur **Microservices Polyrepo** dengan komunikasi sinkron (REST via API Gateway) dan asinkron (Event-Driven via RabbitMQ). Berikut visualisasi arsitektur menggunakan **C4 Model** (ref: Module 09 — *Visualizing Software Architecture*).

---

### 📐 Context Diagram (C4 Level 1)

> **Scope**: Seluruh sistem Yomu.
> **Primary elements**: Yomu Platform sebagai satu kesatuan.
> **Supporting elements**: Aktor (Pelajar, Admin) dan sistem eksternal (Google OAuth, RabbitMQ).
> **Intended audience**: Semua orang, baik teknis maupun non-teknis.
>
> *(Ref: C4 Model — System Context Diagram, Module 09 hal. 115-116)*

Context Diagram menunjukkan **Yomu** sebagai satu kotak di tengah, dikelilingi oleh pengguna dan sistem eksternal yang berinteraksi dengannya. Detail teknis tidak penting di level ini — fokus pada *siapa* yang menggunakan sistem dan *apa* yang terhubung.

```mermaid
flowchart TD
    PELAJAR["Pelajar\n[Person]\n\nPengguna utama yang membaca,\nmengerjakan kuis, berdiskusi,\ndan bergabung clan"]

    ADMIN["Admin\n[Person]\n\nMengelola konten bacaan, kuis,\nachievement, dan moderasi forum"]

    YOMU["Yomu Platform\n[Software System]\n\nPlatform pembelajaran literasi\nberbasis gamifikasi dengan\narsitektur microservices"]

    GOOGLE["Google OAuth 2.0\n[External System]\n\nIdentity Provider untuk\nSingle Sign-On"]

    PELAJAR -->|"Mengakses fitur pembelajaran\ndan sosial via browser\n[HTTPS]"| YOMU
    ADMIN -->|"Mengelola konten\ndan konfigurasi\n[HTTPS]"| YOMU
    YOMU -->|"Autentikasi SSO\n[OAuth 2.0]"| GOOGLE

    style YOMU fill:#1168BD,stroke:#0B4884,color:#FFFFFF
    style PELAJAR fill:#08427B,stroke:#052E56,color:#FFFFFF
    style ADMIN fill:#08427B,stroke:#052E56,color:#FFFFFF
    style GOOGLE fill:#999999,stroke:#6B6B6B,color:#FFFFFF
```

---

### 📐 Container Diagram (C4 Level 2)

> **Scope**: Sistem Yomu secara internal.
> **Primary elements**: Container (aplikasi, data store, message broker) di dalam Yomu.
> **Supporting elements**: Aktor dan sistem eksternal yang terhubung.
> **Intended audience**: Tim teknis — software architect, developer, ops.
>
> *(Ref: C4 Model — Container Diagram, Module 09 hal. 117-118)*
> *Catatan: "Container" di C4 bukan Docker container, melainkan unit yang berjalan terpisah (aplikasi, database, message broker, dsb.)*

```mermaid
flowchart TD
    PELAJAR["Pelajar\n[Person]"]
    ADMIN["Admin\n[Person]"]

    subgraph boundary["Yomu Platform [Software System]"]
        direction TB

        FE["Frontend\n[Container: React 19 + Vite]\n\nSingle Page Application\nyang diakses pengguna\nmelalui web browser\n\nPort: 5173"]

        GW["API Gateway\n[Container: Spring Cloud Gateway]\n\nSingle entry point,\nrouting request ke service,\nvalidasi JWT\n\nPort: 8090"]

        AUTH["Auth Service\n[Container: Spring Boot 3.x]\n\nRegistrasi, Login, JWT,\nGoogle SSO, Rate Limiting, RBAC\n\nPort: 8081"]

        LEARN["Learning Service\n[Container: Spring Boot 3.x]\n\nManajemen Modul Bacaan\ndan Kuis Interaktif\n\nPort: 8082"]

        ACHIEV["Achievements Service\n[Container: Spring Boot 3.x]\n\nTracking Badges, Medals,\ndan Daily Missions\n\nPort: 8083"]

        FORUM["Forum Service\n[Container: Spring Boot 3.x]\n\nThread Discussions dan\nNested Comments\n\nPort: 8084"]

        CLAN["Clan Service\n[Container: Spring Boot 3.x]\n\nClan Management,\nLeaderboard, Scoring\n(Strategy Pattern per Tier)\n\nPort: 8085"]

        MQ["RabbitMQ\n[Container: Message Broker]\n\nTopic Exchange 'yomu.events'\nuntuk komunikasi asinkron\nantar service\n\nPort: 5672 / 15672"]

        DB_A[("Auth DB\n[Container: H2 Database]\nPostgreSQL Mode")]
        DB_L[("Learning DB\n[Container: H2 Database]\nPostgreSQL Mode")]
        DB_AC[("Achievements DB\n[Container: H2 Database]\nPostgreSQL Mode")]
        DB_F[("Forum DB\n[Container: H2 Database]\nPostgreSQL Mode")]
        DB_C[("Clan DB\n[Container: H2 Database]\nPostgreSQL Mode")]

        SHARED["Shared Library\n[Library: Java]\n\nJWT Service & Filters,\nEvent POJOs,\nGlobal Exception Handler"]
    end

    GOOGLE["Google OAuth 2.0\n[External System]"]

    %% User → Frontend
    PELAJAR -->|"Mengakses via browser\n[HTTPS]"| FE
    ADMIN -->|"Mengakses via browser\n[HTTPS]"| FE

    %% Frontend → Gateway
    FE -->|"API calls\n[HTTP/REST, JSON]"| GW

    %% Gateway → Services (Synchronous REST)
    GW -->|"/api/auth/**\n[HTTP]"| AUTH
    GW -->|"/api/learning/**\n[HTTP]"| LEARN
    GW -->|"/api/achievements/**\n[HTTP]"| ACHIEV
    GW -->|"/api/forum/**\n[HTTP]"| FORUM
    GW -->|"/api/clan/**\n[HTTP]"| CLAN

    %% Asynchronous Events via RabbitMQ
    LEARN -.->|"Publishes:\nyomu.quiz.completed\n[AMQP]"| MQ
    ACHIEV -.->|"Publishes:\nyomu.achievement.unlocked\nyomu.daily.mission.completed\n[AMQP]"| MQ
    MQ -.->|"Subscribes: updates\nskor & ranking clan\n[AMQP]"| CLAN

    %% Database per Service
    AUTH --- DB_A
    LEARN --- DB_L
    ACHIEV --- DB_AC
    FORUM --- DB_F
    CLAN --- DB_C

    %% External System
    AUTH -->|"SSO\n[OAuth 2.0]"| GOOGLE

    %% Shared Library (compile-time dependency)
    SHARED -.->|"compile dependency"| AUTH
    SHARED -.->|"compile dependency"| LEARN
    SHARED -.->|"compile dependency"| ACHIEV
    SHARED -.->|"compile dependency"| FORUM
    SHARED -.->|"compile dependency"| CLAN

    %% Styling
    style FE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style GW fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style AUTH fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style LEARN fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style ACHIEV fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style FORUM fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style CLAN fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style MQ fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
    style SHARED fill:#85BBF0,stroke:#5D95C4,color:#000000
    style GOOGLE fill:#999999,stroke:#6B6B6B,color:#FFFFFF
    style PELAJAR fill:#08427B,stroke:#052E56,color:#FFFFFF
    style ADMIN fill:#08427B,stroke:#052E56,color:#FFFFFF
```

**Keterangan:**
- **Garis solid (→)**: Komunikasi sinkron — REST over HTTP
- **Garis putus-putus (-.->)**: Komunikasi asinkron — Event via RabbitMQ (AMQP), atau compile dependency
- Setiap service memiliki **database H2 terpisah** sesuai prinsip *Database-per-Service*
- **Shared Library** adalah *compile-time dependency*, bukan runtime service

---

### 📐 Deployment Diagram

> **Scope**: Lingkungan deployment (development/staging).
> **Primary elements**: Deployment nodes, container instances.
> **Supporting elements**: Infrastructure nodes (Docker network).
> **Intended audience**: Tim teknis — architect, developer, ops.
>
> *(Ref: C4 Model — Deployment Diagram, Module 09 hal. 122)*

```mermaid
flowchart TD
    subgraph DEVICE["User Device"]
        BROWSER["Web Browser"]
    end

    subgraph DOCKER["Docker Host — Docker Compose"]
        subgraph NETWORK["Docker Network: yomu-network"]

            FE_NODE["Container: yomu-frontend\n─────────────────\nReact 19 (Vite Dev Server)\nExposed Port: 5173"]

            GW_NODE["Container: yomu-api-gateway\n─────────────────\nSpring Cloud Gateway\n(Java 21, Gradle)\nExposed Port: 8090"]

            AUTH_NODE["Container: yomu-service-auth\n─────────────────\nSpring Boot 3.x\nInternal Port: 8081\n+ Embedded H2 DB"]

            LEARN_NODE["Container: yomu-service-learning\n─────────────────\nSpring Boot 3.x\nInternal Port: 8082\n+ Embedded H2 DB"]

            ACHIEV_NODE["Container: yomu-service-achievements\n─────────────────\nSpring Boot 3.x\nInternal Port: 8083\n+ Embedded H2 DB"]

            FORUM_NODE["Container: yomu-service-forum\n─────────────────\nSpring Boot 3.x\nInternal Port: 8084\n+ Embedded H2 DB"]

            CLAN_NODE["Container: yomu-service-clan\n─────────────────\nSpring Boot 3.x\nInternal Port: 8085\n+ Embedded H2 DB"]

            MQ_NODE["Container: rabbitmq\n─────────────────\nRabbitMQ 3.x\nAMQP Port: 5672\nManagement: 15672"]
        end
    end

    BROWSER -->|"HTTPS :5173"| FE_NODE
    FE_NODE -->|"HTTP :8090"| GW_NODE
    GW_NODE --> AUTH_NODE
    GW_NODE --> LEARN_NODE
    GW_NODE --> ACHIEV_NODE
    GW_NODE --> FORUM_NODE
    GW_NODE --> CLAN_NODE
    LEARN_NODE -.->|"AMQP"| MQ_NODE
    ACHIEV_NODE -.->|"AMQP"| MQ_NODE
    MQ_NODE -.->|"AMQP"| CLAN_NODE

    style FE_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style GW_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style AUTH_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style LEARN_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style ACHIEV_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style FORUM_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style CLAN_NODE fill:#438DD5,stroke:#2E6295,color:#FFFFFF
    style MQ_NODE fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
```

**Catatan Deployment:**
- Semua service berjalan dalam **satu Docker Compose** pada satu host
- Service backend **tidak di-expose** ke luar — hanya dapat diakses melalui API Gateway
- H2 database berjalan **embedded** di dalam proses setiap service (bukan container terpisah)
- Komunikasi antar container menggunakan **Docker internal network**