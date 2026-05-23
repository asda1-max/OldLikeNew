# Tech Stack - LelangKu Backend

Berikut adalah daftar teknologi, framework, dan library utama yang digunakan dalam pengembangan backend aplikasi **LelangKu**:

## 🚀 Core Framework & Server
- **Language:** Python (3.10+)
- **Framework:** [FastAPI](https://fastapi.tiangolo.com/) - Framework web yang sangat cepat dan modern untuk membangun API RESTful.
- **ASGI Server:** [Uvicorn](https://www.uvicorn.org/) - Server web ASGI (Asynchronous Server Gateway Interface) berkinerja tinggi untuk menjalankan aplikasi FastAPI.

## 🗄️ Database & ORM
- **Database:** [SQLite](https://www.sqlite.org/index.html) - Database relasional ringan, data disimpan sebagai file lokal (cocok untuk development/testing ringan).
- **ORM (Object-Relational Mapping):** [SQLAlchemy](https://www.sqlalchemy.org/) - Toolkit SQL Python untuk memetakan objek Python (Models) ke dalam tabel database.

## 🔒 Security & Authentication
- **Authentication:** JWT (JSON Web Tokens) menggunakan library `python-jose` untuk otentikasi berbasis token (Bearer Token).
- **Password Hashing:** `passlib` dengan algoritma hashing `bcrypt` untuk mengenkripsi (hash) kata sandi pengguna secara aman.

## 📦 Data Handling & Validation
- **Validation & Serialization:** [Pydantic](https://docs.pydantic.dev/) - Digunakan terintegrasi dengan FastAPI untuk memvalidasi request (Schema) dan membentuk response API.
- **File Uploads:** `python-multipart` - Digunakan untuk memproses pengiriman *form data* dan upload file (foto barang lelang).
- **Email Validation:** `email-validator` - Library tambahan untuk memvalidasi format alamat email secara ketat.

## 🛠️ Environment & Configuration
- **Environment Management:** `python-dotenv` - Memuat konfigurasi dan *secrets* (seperti `SECRET_KEY`, `DATABASE_URL`) dari file `.env` dengan aman ke dalam sistem variabel *environment*.

## 📡 API Endpoints

### 🔑 Auth
- `POST /auth/register` - Mendaftarkan pengguna baru (Role: buyer/seller/admin)
- `POST /auth/login` - Login dan mendapatkan Token JWT
- `GET /auth/me` - Menampilkan profil pengguna yang sedang login

### 👥 Users
- `GET /users/` - Menampilkan daftar semua pengguna *(Admin only)*
- `GET /users/{user_id}` - Menampilkan detail pengguna tertentu
- `PUT /users/{user_id}` - Memperbarui data profil pengguna

### 📦 Items
- `POST /items/` - Menambahkan barang baru beserta foto *(Seller)*
- `GET /items/` - Menampilkan barang milik seller yang sedang login
- `GET /items/{item_id}` - Menampilkan detail barang tertentu

### 📢 Auctions (Lelang)
- `POST /auctions/` - Membuka sesi lelang baru untuk suatu barang *(Seller)*
- `GET /auctions/` - Menampilkan lelang yang sedang aktif (Bisa di-filter berdasarkan status/kategori)
- `GET /auctions/{auction_id}` - Menampilkan detail lelang beserta riwayat bid
- `PUT /auctions/{auction_id}` - Update lelang atau membatalkan (cancel) lelang yang belum ada bid
- `GET /auctions/my` - Menampilkan daftar lelang yang dibuat oleh seller

### 💰 Bids (Penawaran)
- `POST /bids/{auction_id}` - Melakukan penawaran/bid pada lelang *(Buyer)* 
- `GET /bids/{auction_id}` - Menampilkan seluruh riwayat bid pada suatu lelang
- `GET /bids/my` - Menampilkan riwayat bid dari pengguna yang login

### 🤝 Transactions (Transaksi & Pembayaran)
- `GET /transactions/` - Menampilkan daftar transaksi pengguna (sebagai pembeli atau penjual)
- `PUT /transactions/{transaction_id}/status` - Mengubah status transaksi (payment/shipping status)
