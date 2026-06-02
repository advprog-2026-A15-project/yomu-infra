#!/usr/bin/env bash
set -euo pipefail

# seed-bacaan.sh - Inject sample bacaan data into service-learning
# Run: bash seed-bacaan.sh

BASE_URL="${BASE_URL:-http://localhost:8082/api/learning/bacaan}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

find_python() {
    is_python3() {
        "$1" -c 'import sys; raise SystemExit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1
    }

    if [[ -n "${PYTHON_BIN:-}" ]]; then
        if ! command -v "$PYTHON_BIN" >/dev/null 2>&1 || ! is_python3 "$PYTHON_BIN"; then
            echo "PYTHON_BIN must point to a Python 3 executable" >&2
            exit 1
        fi
        return
    fi

    for candidate in python3 python; do
        if command -v "$candidate" >/dev/null 2>&1 && is_python3 "$candidate"; then
            PYTHON_BIN="$candidate"
            return
        fi
    done

    echo "Missing required command: python3, or python pointing to Python 3" >&2
    exit 1
}

json_field() {
    local field="$1"
    "$PYTHON_BIN" -c 'import json, sys; value = json.load(sys.stdin).get(sys.argv[1]); print("" if value is None else value)' "$field"
}

require_command curl
find_python

payloads_file="$(mktemp)"
trap 'rm -f "$payloads_file" "${response_file:-}"' EXIT

"$PYTHON_BIN" <<'PY' > "$payloads_file"
import json

bacaan_list = [
    {
        "title": "Sang Pemimpi di Negeri Awan",
        "content": """Di sebuah desa kecil di kaki Gunung Merapi, hiduplah seorang anak bernama Aditya. Setiap malam, ia bermimpi terbang melintasi awan-awan putih yang berkilauan di bawah cahaya bulan. Mimpi-mimpi itu begitu nyata sehingga ia bisa merasakan hembusan angin di wajahnya.

Suatu hari, Aditya menemukan sebuah buku tua di perpustakaan desa. Buku itu menceritakan tentang seorang navigator kuno yang bisa berlayar di atas awan menggunakan perahu terbang. Terinspirasi oleh cerita tersebut, Aditya mulai menggambar desain pesawat sederhana di buku catatannya.

Dengan bantuan Pak Harto, guru fisika di sekolahnya, Aditya belajar tentang aerodinamika dan prinsip Bernoulli. Ia memahami bahwa mimpi-mimpinya bisa diwujudkan melalui ilmu pengetahuan. Berbulan-bulan ia bekerja keras, membangun model pesawat dari bambu dan kertas minyak.

Akhirnya, pada hari ulang tahun desa, Aditya menerbangkan pesawat modelnya di hadapan seluruh penduduk desa. Pesawat itu terbang dengan anggun, berputar-putar di udara selama hampir dua menit sebelum mendarat dengan mulus. Tepuk tangan meriah membahana, dan Aditya tahu bahwa mimpi pertamanya telah terwujud.

Sejak saat itu, Aditya tidak pernah berhenti bermimpi — tetapi kini ia tahu bahwa setiap mimpi membutuhkan kerja keras dan pengetahuan untuk menjadi kenyataan.""",
        "category": "FIKSI",
    },
    {
        "title": "Rahasia Perpustakaan Tua",
        "content": """Perpustakaan Kota Surabaya yang dibangun pada tahun 1920 menyimpan ribuan buku dari berbagai era. Namun, di balik rak-rak berdebu di lantai tiga, tersembunyi sebuah ruangan yang tidak pernah dikunjungi siapa pun selama puluhan tahun.

Maya, seorang mahasiswi sastra, menemukan ruangan itu secara tidak sengaja ketika ia mencari referensi untuk skripsinya. Pintu kayu berukir itu berderit ketika ia mendorongnya, mengungkapkan deretan manuskrip kuno yang ditulis dalam berbagai bahasa — Jawa Kuno, Melayu Klasik, Sansekerta, dan beberapa bahasa yang tidak ia kenali.

Salah satu manuskrip menarik perhatiannya: sebuah puisi panjang yang menceritakan perjalanan seorang pelaut Nusantara ke tanah yang jauh di selatan. Puisi itu menggambarkan hewan-hewan aneh, tanaman yang belum pernah dilihat, dan peradaban yang maju dalam bidang astronomi.

Maya membawa temuannya kepada Prof. Suharto, dosen sejarah maritimnya. Sang profesor terkejut — manuskrip itu mungkin merupakan bukti pertama bahwa pelaut Nusantara telah mencapai benua Australia jauh sebelum kedatangan bangsa Eropa.

Penemuan ini mengubah hidup Maya selamanya. Ia kini memimpin tim peneliti yang bekerja menerjemahkan seluruh koleksi manuskrip tersebut, membuka jendela baru ke dalam sejarah maritim Nusantara yang selama ini tersembunyi.""",
        "category": "FIKSI",
    },
    {
        "title": "Manfaat Membaca Bagi Otak: Perspektif Neurosains",
        "content": """Membaca bukan sekadar aktivitas menyerap informasi — ia adalah latihan kompleks bagi otak yang melibatkan berbagai jaringan saraf secara simultan. Penelitian neurosains modern telah mengungkapkan bahwa membaca memiliki dampak transformatif pada struktur dan fungsi otak.

Ketika kita membaca, area Broca dan Wernicke di hemisfer kiri otak bekerja sama untuk memproses bahasa. Namun, aktivitas tidak berhenti di situ. Korteks visual memproses bentuk huruf, hippocampus mengaitkan informasi baru dengan memori yang sudah ada, dan amigdala merespons konten emosional dari teks.

Studi longitudinal oleh Rush University Medical Center menunjukkan bahwa orang dewasa yang rutin membaca mengalami penurunan kognitif 32% lebih lambat dibandingkan mereka yang jarang membaca. Membaca secara konsisten juga dikaitkan dengan peningkatan konektivitas dalam jaringan default mode otak, yang berperan penting dalam kreativitas dan pemikiran reflektif.

Yang lebih menarik, membaca fiksi secara khusus meningkatkan kemampuan teori pikiran (theory of mind) — kemampuan untuk memahami perspektif dan emosi orang lain. Penelitian dari New School for Social Research menemukan bahwa membaca sastra meningkatkan empati secara terukur.

Bagi anak-anak, paparan membaca sejak dini membentuk fondasi neural yang kuat untuk kemampuan literasi seumur hidup. Anak-anak yang dibacakan cerita sebelum tidur menunjukkan aktivasi yang lebih kuat di area otak terkait pemahaman naratif dan imagery visual.""",
        "category": "NON_FIKSI",
    },
    {
        "title": "Produktivitas dengan Metode Pomodoro",
        "content": """Metode Pomodoro dikembangkan oleh Francesco Cirillo pada akhir tahun 1980-an saat ia masih menjadi mahasiswa yang kesulitan berkonsentrasi. Nama metode ini diambil dari timer dapur berbentuk tomat (pomodoro dalam bahasa Italia) yang ia gunakan.

Konsep dasarnya sederhana: bekerja dengan fokus penuh selama 25 menit, lalu istirahat 5 menit. Setelah empat sesi (atau empat 'pomodoro'), ambil istirahat panjang 15-30 menit. Kesederhanaan inilah yang menjadi kekuatan utamanya.

Mengapa metode ini efektif? Pertama, 25 menit adalah durasi yang cukup singkat sehingga otak tidak merasa overwhelmed, namun cukup panjang untuk menyelesaikan kerja bermakna. Kedua, jeda istirahat reguler mencegah kelelahan mental (mental fatigue) yang menurunkan kualitas kerja.

Langkah-langkah penerapan:
1. Pilih satu tugas yang ingin diselesaikan
2. Set timer 25 menit
3. Kerjakan tugas tersebut tanpa gangguan — matikan notifikasi, tutup tab yang tidak relevan
4. Ketika timer berbunyi, beri tanda centang pada kertas dan istirahat 5 menit
5. Setiap 4 pomodoro, ambil istirahat panjang 15-30 menit

Tips penting: jika sebuah gangguan muncul saat sesi berjalan, catat di kertas dan tangani saat istirahat. Ini melatih otak untuk menunda gratifikasi dan mempertahankan fokus.

Penelitian menunjukkan bahwa pengguna konsisten metode Pomodoro melaporkan peningkatan produktivitas hingga 40% dan penurunan tingkat prokrastinasi secara signifikan.""",
        "category": "NON_FIKSI",
    },
    {
        "title": "Misteri Lubang Hitam: Pintu Gerbang Alam Semesta",
        "content": """Lubang hitam (black hole) adalah salah satu objek paling misterius dan menakjubkan di alam semesta. Mereka terbentuk ketika bintang raksasa — dengan massa minimal 20 kali massa Matahari — kehabisan bahan bakar nuklir dan runtuh ke dalam dirinya sendiri akibat gravitasi yang sangat kuat.

Teori Relativitas Umum Einstein memprediksi keberadaan lubang hitam pada tahun 1915, namun baru pada April 2019, tim Event Horizon Telescope (EHT) berhasil mengambil foto pertama lubang hitam — lubang hitam supermasif di pusat galaksi M87, dengan massa 6,5 miliar kali massa Matahari.

Di pusat setiap lubang hitam terdapat singularitas — titik di mana densitas materi menjadi tak terhingga dan hukum fisika yang kita kenal berhenti berlaku. Mengelilingi singularitas adalah cakrawala peristiwa (event horizon), batas tak kasat mata di mana kecepatan lepas melebihi kecepatan cahaya.

Efek menarik dari lubang hitam:
- Dilatasi waktu: Waktu berjalan lebih lambat di dekat lubang hitam. Satu jam di dekat cakrawala peristiwa bisa setara dengan bertahun-tahun di tempat yang jauh.
- Spaghettification: Objek yang mendekati lubang hitam akan ditarik memanjang oleh gaya pasang surut gravitasi yang ekstrem.
- Radiasi Hawking: Stephen Hawking memprediksi bahwa lubang hitam sebenarnya memancarkan radiasi dan perlahan-lahan menguap dalam skala waktu yang sangat panjang.

Galaksi kita sendiri, Bima Sakti, memiliki lubang hitam supermasif bernama Sagittarius A* di pusatnya, dengan massa sekitar 4 juta kali massa Matahari.""",
        "category": "SAINS",
    },
    {
        "title": "Fotosintesis: Mesin Kehidupan di Bumi",
        "content": """Fotosintesis adalah proses biokimia fundamental yang mengubah energi cahaya matahari menjadi energi kimia, menjadi dasar dari hampir seluruh rantai makanan di Bumi. Tanpa fotosintesis, kehidupan seperti yang kita kenal tidak akan mungkin ada.

Persamaan sederhana fotosintesis: 6CO2 + 6H2O + cahaya -> C6H12O6 + 6O2

Proses ini terjadi di kloroplas — organel sel tumbuhan yang mengandung pigmen klorofil. Klorofil menyerap cahaya merah dan biru, namun memantulkan cahaya hijau — itulah mengapa daun tampak berwarna hijau.

Fotosintesis terdiri dari dua tahap utama:

1. Reaksi Terang (di membran tilakoid):
   Cahaya matahari memecah molekul air, melepaskan oksigen sebagai produk sampingan. Energi cahaya dikonversi menjadi ATP dan NADPH — molekul pembawa energi kimia.

2. Siklus Calvin (di stroma):
   ATP dan NADPH digunakan untuk mengfiksasi karbon dioksida dari udara menjadi glukosa. Proses ini tidak memerlukan cahaya secara langsung, sehingga disebut juga reaksi gelap.

Fakta menakjubkan tentang fotosintesis:
- Tumbuhan di seluruh dunia menghasilkan sekitar 130 terawatt energi melalui fotosintesis — enam kali lipat konsumsi energi seluruh peradaban manusia.
- Fitoplankton di lautan bertanggung jawab atas lebih dari 50% produksi oksigen global.
- Beberapa bakteri melakukan fotosintesis tanpa menghasilkan oksigen, menggunakan hidrogen sulfida sebagai pengganti air.

Para ilmuwan kini berusaha meniru fotosintesis secara artifisial untuk menghasilkan bahan bakar bersih dari sinar matahari dan air — sebuah bidang yang dikenal sebagai fotosintesis artifisial.""",
        "category": "SAINS",
    },
    {
        "title": "Kerajaan Majapahit: Puncak Peradaban Nusantara",
        "content": """Kerajaan Majapahit (1293-1527 M) merupakan kerajaan Hindu-Buddha terbesar yang pernah berdiri di Nusantara. Didirikan oleh Raden Wijaya setelah jatuhnya Kerajaan Singhasari, Majapahit tumbuh menjadi kekuatan maritim yang menguasai sebagian besar kepulauan Asia Tenggara.

Puncak kejayaan Majapahit terjadi pada masa pemerintahan Hayam Wuruk (1350-1389) dengan Mahapatih Gajah Mada sebagai perdana menteri. Gajah Mada terkenal dengan Sumpah Palapa — sumpah untuk tidak menikmati 'palapa' (bumbu/kenikmatan) sampai seluruh Nusantara bersatu di bawah Majapahit.

Kitab Nagarakretagama, yang ditulis oleh Mpu Prapanca pada tahun 1365, memberikan gambaran rinci tentang kehidupan di ibu kota Majapahit. Kota ini digambarkan sebagai pusat perdagangan internasional yang ramai, dengan pedagang dari Tiongkok, India, Arab, dan Persia.

Pencapaian utama Majapahit:
- Sistem pemerintahan terstruktur dengan pembagian wilayah yang jelas (mandala system)
- Jaringan perdagangan maritim yang membentang dari Sumatra hingga Papua
- Kehidupan sastra yang kaya, melahirkan karya-karya agung seperti Kakawin Sutasoma oleh Mpu Tantular, yang mengandung semboyan 'Bhinneka Tunggal Ika'
- Sistem irigasi canggih yang mendukung pertanian padi intensif
- Toleransi beragama, dengan Hindu, Buddha, dan kepercayaan lokal hidup berdampingan

Warisan terpenting Majapahit adalah konsep Nusantara sebagai kesatuan geografis dan kultural — sebuah visi yang kemudian menginspirasi para pendiri bangsa Indonesia dalam memperjuangkan kemerdekaan.""",
        "category": "SEJARAH",
    },
    {
        "title": "Soekarno dan Proklamasi Kemerdekaan Indonesia",
        "content": """Tanggal 17 Agustus 1945 menandai titik balik dalam sejarah bangsa Indonesia — hari ketika Soekarno dan Mohammad Hatta memproklamasikan kemerdekaan Indonesia, mengakhiri lebih dari tiga abad penjajahan.

Jalan menuju proklamasi tidak mudah. Setelah Jepang menyerah kepada Sekutu pada 15 Agustus 1945, kelompok pemuda revolusioner mendesak Soekarno dan Hatta untuk segera memproklamasikan kemerdekaan. Terjadilah peristiwa Rengasdengklok pada 16 Agustus, di mana kelompok pemuda — termasuk Sutan Sjahrir, Wikana, dan Chaerul Saleh — membawa Soekarno dan Hatta ke Rengasdengklok untuk menjauhkan mereka dari pengaruh Jepang.

Setelah negosiasi intens, disepakati bahwa proklamasi akan dibacakan keesokan harinya. Teks proklamasi disusun di rumah Laksamana Muda Tadashi Maeda di Jalan Imam Bonjol No. 1, Jakarta. Soekarno menuliskan draf dengan tulisan tangan, yang kemudian diketik oleh Sayuti Melik.

Pada pagi hari 17 Agustus 1945, di halaman rumahnya di Jalan Pegangsaan Timur No. 56, Jakarta, Soekarno membacakan teks proklamasi yang singkat namun bersejarah:

'Kami bangsa Indonesia dengan ini menjatakan kemerdekaan Indonesia. Hal-hal jang mengenai pemindahan kekuasaan d.l.l., diselenggarakan dengan tjara saksama dan dalam tempo jang sesingkat-singkatnja.'

Setelah proklamasi, bendera Merah Putih yang dijahit oleh Fatmawati dikibarkan, diiringi lagu Indonesia Raya. Peristiwa ini menandai lahirnya Republik Indonesia sebagai negara merdeka dan berdaulat.

Namun, perjuangan belum selesai. Indonesia masih harus mempertahankan kemerdekaannya melalui revolusi fisik (1945-1949) melawan upaya Belanda untuk kembali menjajah, sebelum akhirnya kedaulatan Indonesia diakui secara internasional pada 27 Desember 1949.""",
        "category": "SEJARAH",
    },
    {
        "title": "Kecerdasan Buatan: Revolusi Digital Abad ke-21",
        "content": """Kecerdasan Buatan (Artificial Intelligence/AI) telah berkembang dari konsep fiksi ilmiah menjadi teknologi yang mengubah hampir setiap aspek kehidupan modern. Dari asisten virtual di ponsel hingga diagnosa medis, AI hadir di mana-mana.

Sejarah singkat AI:
- 1950: Alan Turing mengusulkan 'Turing Test' sebagai ukuran kecerdasan mesin
- 1956: Konferensi Dartmouth — istilah 'Artificial Intelligence' pertama kali digunakan
- 1997: Deep Blue (IBM) mengalahkan juara catur dunia Garry Kasparov
- 2011: Watson (IBM) memenangkan kuis Jeopardy!
- 2016: AlphaGo (DeepMind) mengalahkan juara dunia Go, Lee Sedol
- 2022-2024: Era Large Language Model (LLM) — ChatGPT dan sejenisnya mengubah cara manusia berinteraksi dengan komputer

Jenis-jenis AI:
1. Narrow AI (AI Sempit): Dirancang untuk tugas spesifik — pengenalan wajah, rekomendasi konten, penerjemahan bahasa. Ini adalah jenis AI yang paling umum saat ini.
2. General AI (AGI): AI yang mampu berpikir dan belajar seperti manusia di berbagai domain. Masih dalam tahap penelitian.
3. Super AI: AI yang melampaui kecerdasan manusia di semua bidang. Masih bersifat teoretis.

Teknologi kunci di balik AI modern:
- Machine Learning: Algoritma yang belajar dari data tanpa diprogram secara eksplisit
- Deep Learning: Jaringan saraf tiruan berlapis-lapis yang meniru cara otak memproses informasi
- Natural Language Processing (NLP): Kemampuan mesin untuk memahami dan menghasilkan bahasa manusia
- Computer Vision: Kemampuan mesin untuk 'melihat' dan menginterpretasikan gambar

Tantangan etis AI meliputi bias algoritmik, privasi data, dampak terhadap lapangan kerja, dan pertanyaan tentang akuntabilitas ketika AI membuat keputusan yang salah.""",
        "category": "TEKNOLOGI",
    },
    {
        "title": "Blockchain: Teknologi di Balik Revolusi Digital",
        "content": """Blockchain adalah teknologi buku besar terdistribusi (distributed ledger) yang memungkinkan pencatatan transaksi secara transparan, aman, dan tidak dapat diubah. Pertama kali diperkenalkan pada tahun 2008 oleh sosok misterius bernama Satoshi Nakamoto sebagai fondasi Bitcoin.

Cara kerja blockchain:
1. Setiap transaksi dicatat dalam sebuah 'blok' data
2. Setiap blok memiliki hash kriptografis unik dan hash dari blok sebelumnya, membentuk rantai (chain)
3. Blok baru divalidasi oleh jaringan node melalui mekanisme konsensus
4. Setelah divalidasi, blok ditambahkan ke rantai dan tidak dapat diubah

Keunggulan blockchain:
- Desentralisasi: Tidak ada otoritas tunggal yang mengontrol jaringan
- Transparansi: Semua transaksi dapat diverifikasi oleh siapa pun
- Immutability: Data yang sudah dicatat tidak dapat diubah atau dihapus
- Keamanan: Enkripsi kriptografis melindungi integritas data

Mekanisme konsensus utama:
- Proof of Work (PoW): Node harus memecahkan puzzle matematika kompleks (digunakan Bitcoin). Aman tapi boros energi.
- Proof of Stake (PoS): Validator dipilih berdasarkan jumlah koin yang mereka 'pertaruhkan'. Lebih hemat energi.

Aplikasi blockchain di luar cryptocurrency:
- Supply chain management: Melacak perjalanan produk dari produsen ke konsumen
- Smart contracts: Program yang otomatis dieksekusi ketika kondisi tertentu terpenuhi
- Identitas digital: Sistem verifikasi identitas yang aman dan portable
- Voting elektronik: Sistem pemilihan yang transparan dan tahan manipulasi
- NFT (Non-Fungible Token): Kepemilikan digital untuk seni, musik, dan aset virtual

Meskipun potensial, blockchain menghadapi tantangan skalabilitas, regulasi, dan adopsi massal yang masih perlu diatasi.""",
        "category": "TEKNOLOGI",
    },
    {
        "title": "Batik: Warisan Budaya Dunia dari Indonesia",
        "content": """Batik adalah seni pewarnaan kain menggunakan teknik perintang warna (wax-resist dyeing) yang telah dipraktikkan di Indonesia selama berabad-abad. Pada tanggal 2 Oktober 2009, UNESCO mengakui batik Indonesia sebagai Warisan Kemanusiaan untuk Budaya Lisan dan Nonbendawi (Intangible Cultural Heritage of Humanity).

Proses pembuatan batik tulis tradisional:
1. Nyungging: Membuat pola/desain di atas kertas
2. Njaplak: Memindahkan pola ke kain
3. Nglowong: Menorehkan malam (lilin) mengikuti pola menggunakan canting
4. Ngiseni: Memberi isian pada ornamen utama
5. Nyolet: Mewarnai bagian-bagian tertentu dengan kuas
6. Mopok: Menutup bagian yang sudah diwarnai dengan malam
7. Ngelir: Mencelupkan kain ke dalam larutan pewarna
8. Nglorod: Menghilangkan malam dengan air panas

Motif batik tradisional memiliki makna filosofis yang mendalam:
- Parang: Melambangkan kekuatan dan keteguhan hati, dahulu hanya boleh dipakai oleh keluarga keraton
- Kawung: Melambangkan harapan agar pemakainya menjadi pemimpin yang adil
- Mega Mendung: Khas Cirebon, melambangkan kesabaran — seperti awan yang menahan hujan
- Sekar Jagad: Melambangkan keindahan dan keberagaman dunia
- Truntum: Melambangkan cinta yang tumbuh kembali, biasa dipakai orang tua mempelai

Setiap daerah di Indonesia memiliki ciri khas batik masing-masing:
- Solo dan Yogyakarta: Warna sogan (coklat), motif geometris keraton
- Pekalongan: Warna cerah, pengaruh Tionghoa dan Belanda
- Cirebon: Motif mega mendung dengan gradasi warna biru
- Madura: Warna merah cerah dengan motif naturalis
- Papua: Motif kontemporer dengan simbol-simbol budaya lokal

Hari Batik Nasional diperingati setiap tanggal 2 Oktober sebagai bentuk penghargaan terhadap warisan budaya ini.""",
        "category": "BUDAYA",
    },
    {
        "title": "Gamelan: Orkestra Tradisional Nusantara",
        "content": """Gamelan adalah ansambel musik tradisional Indonesia yang terdiri dari berbagai instrumen perkusi, terutama metalofon, gong, dan drum. Kata 'gamelan' berasal dari bahasa Jawa 'gamel' yang berarti memukul atau menabuh.

Gamelan telah ada setidaknya sejak abad ke-8 Masehi, sebagaimana terukir pada relief Candi Borobudur. Setiap set gamelan dianggap sebagai satu kesatuan yang utuh — instrumen dari set yang berbeda tidak boleh dicampur karena setiap set memiliki tuning (laras) yang unik.

Dua sistem laras utama gamelan:
1. Slendro: Tangga nada pentatonis (5 nada) dengan interval yang relatif sama. Menghasilkan suasana yang riang dan cerah.
2. Pelog: Tangga nada heptatonis (7 nada, tapi biasanya hanya 5 yang digunakan) dengan interval yang tidak sama. Menghasilkan suasana yang lebih lembut dan khidmat.

Instrumen utama dalam gamelan Jawa:
- Saron: Metalofon dengan bilah logam di atas resonator kayu
- Bonang: Kumpulan gong kecil yang diletakkan horizontal
- Gender: Metalofon dengan resonator tabung bambu di bawah setiap bilah
- Gambang: Xilofon dengan bilah kayu
- Kendang: Drum dua sisi yang berfungsi sebagai pemimpin tempo
- Gong: Gong besar yang menandai akhir frasa musikal
- Rebab: Alat gesek berdawai dua
- Suling: Seruling bambu
- Siter: Alat petik berdawai

Filosofi gamelan mencerminkan nilai-nilai Jawa:
- Gotong royong: Setiap pemain harus mendengarkan dan menyesuaikan dengan pemain lain
- Keselarasan: Tidak ada instrumen yang mendominasi — semua saling melengkapi
- Kesabaran: Belajar gamelan membutuhkan waktu bertahun-tahun

Pada tahun 2023, UNESCO menambahkan gamelan ke dalam daftar Warisan Budaya Takbenda Kemanusiaan. Gamelan kini diajarkan di berbagai universitas di seluruh dunia, dari Amerika Serikat hingga Jepang.""",
        "category": "BUDAYA",
    },
]

for bacaan in bacaan_list:
    print(json.dumps(bacaan, ensure_ascii=False))
PY

success=0
failed=0

echo
echo "=== Seeding Bacaan Data ==="
echo "Target: $BASE_URL"
echo

while IFS= read -r payload; do
    title="$(printf '%s' "$payload" | json_field title)"
    category="$(printf '%s' "$payload" | json_field category)"
    response_file="$(mktemp)"

    if status="$(
        curl -sS -X POST "$BASE_URL" \
            -H "Content-Type: application/json; charset=utf-8" \
            --data-binary "$payload" \
            --max-time 15 \
            -o "$response_file" \
            -w "%{http_code}"
    )"; then
        if [[ "$status" == 2* ]]; then
            id="$("$PYTHON_BIN" -c 'import json, sys; print(json.load(sys.stdin).get("id", ""))' < "$response_file" 2>/dev/null || true)"
            echo "[OK] $category - $title (ID: $id)"
            success=$((success + 1))
        else
            body="$(<"$response_file")"
            echo "[FAIL] $category - $title: HTTP $status $body"
            failed=$((failed + 1))
        fi
    else
        echo "[FAIL] $category - $title: curl request failed"
        failed=$((failed + 1))
    fi

    rm -f "$response_file"
done < "$payloads_file"

echo
echo "=== Seeding Complete ==="
echo "Success: $success | Failed: $failed"
