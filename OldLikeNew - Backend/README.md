# LelangKu Backend (FastAPI + SQLite)

Backend production-ready untuk aplikasi lelang barang bekas **LelangKu**.

## Fitur Utama
- FastAPI + SQLAlchemy ORM (SQLite)
- JWT Auth (Bearer) dengan role-based access (admin/seller/buyer)
- Password hashing bcrypt
- Upload foto barang ke folder lokal `uploads/`
- Auto-close auction via background task
- CORS enabled untuk semua origin
- Konfigurasi via `.env`

## Struktur Folder
Sesuai requirement di prompt.

## Instalasi
```bash
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

## Menjalankan Server
```bash
uvicorn app.main:app --reload
```

## Seed Data (Opsional)
```bash
python seed_data.py
```

## Dokumentasi API

### Base URL
- Local: `http://127.0.0.1:8000`

### Auth & Roles
- Gunakan header: `Authorization: Bearer TOKEN`
- Role:
  - `admin` bisa semua
  - `seller` bisa membuat item, membuat lelang, melihat transaksi miliknya
  - `buyer` bisa bid, melihat lelang, melihat transaksi miliknya

### Validasi & Business Rules
- Bid baru harus > current_price + Rp 1.000
- Seller tidak bisa bid di lelang sendiri
- Lelang hanya bisa dicancel jika belum ada bid
- Buyout: jika bid >= buyout_price, lelang langsung closed dan winner ditetapkan
- Auto-close: lelang otomatis closed saat end_time terlewat dan transaksi dibuat

### Status & Enum
- Auction status: `draft | active | closed | cancelled`
- Payment status: `pending | paid | cancelled`
- Shipping status: `pending | shipped | delivered`
- Item condition: `new | used`

### Endpoint Ringkas
#### Auth
- POST `/auth/register`
- POST `/auth/login`
- GET `/auth/me`

#### Users
- GET `/users/` (admin only)
- GET `/users/{user_id}`
- PUT `/users/{user_id}`

#### Items
- POST `/items/` (seller/admin, multipart upload)
- GET `/items/` (seller/admin)
- GET `/items/{item_id}`

#### Auctions
- POST `/auctions/`
- GET `/auctions/` (filter: `status`, `category`)
- GET `/auctions/{auction_id}`
- PUT `/auctions/{auction_id}` (update/cancel)
- GET `/auctions/my`

#### Bids
- POST `/bids/{auction_id}`
- GET `/bids/{auction_id}`
- GET `/bids/my`

#### Transactions
- GET `/transactions/`
- PUT `/transactions/{transaction_id}/status`

## Contoh Request (curl)
> Ganti `TOKEN` dengan JWT dari endpoint login.

### Auth
**POST /auth/register**
```bash
curl -X POST http://127.0.0.1:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Budi","email":"budi@mail.com","password":"secret123","role":"buyer"}'
```

**POST /auth/login**
```bash
curl -X POST http://127.0.0.1:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=budi@mail.com&password=secret123"
```

**GET /auth/me**
```bash
curl -X GET http://127.0.0.1:8000/auth/me \
  -H "Authorization: Bearer TOKEN"
```

### Users
**GET /users/** (admin only)
```bash
curl -X GET http://127.0.0.1:8000/users/ \
  -H "Authorization: Bearer TOKEN"
```

**GET /users/{user_id}**
```bash
curl -X GET http://127.0.0.1:8000/users/1 \
  -H "Authorization: Bearer TOKEN"
```

**PUT /users/{user_id}**
```bash
curl -X PUT http://127.0.0.1:8000/users/1 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Budi Update","phone":"08123456789"}'
```

### Items
**POST /items/** (seller/admin)
```bash
curl -X POST http://127.0.0.1:8000/items/ \
  -H "Authorization: Bearer TOKEN" \
  -F "title=Jam Tangan" \
  -F "description=Jam second" \
  -F "category=fashion" \
  -F "condition=used" \
  -F "images=@C:/path/to/image1.jpg"
```

**GET /items/** (seller/admin)
```bash
curl -X GET http://127.0.0.1:8000/items/ \
  -H "Authorization: Bearer TOKEN"
```

**GET /items/{item_id}**
```bash
curl -X GET http://127.0.0.1:8000/items/1
```

### Auctions
**POST /auctions/**
```bash
curl -X POST http://127.0.0.1:8000/auctions/ \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"item_id":1,"start_price":100000,"buyout_price":300000,"end_time":"2030-12-31T23:59:59"}'
```

**GET /auctions/**
```bash
curl -X GET "http://127.0.0.1:8000/auctions/?status=active&category=electronics"
```

**GET /auctions/{auction_id}**
```bash
curl -X GET http://127.0.0.1:8000/auctions/1
```

**PUT /auctions/{auction_id}** (update/cancel)
```bash
curl -X PUT http://127.0.0.1:8000/auctions/1 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"cancelled"}'
```

**GET /auctions/my**
```bash
curl -X GET http://127.0.0.1:8000/auctions/my \
  -H "Authorization: Bearer TOKEN"
```

### Bids
**POST /bids/{auction_id}**
```bash
curl -X POST http://127.0.0.1:8000/bids/1 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount":101000}'
```

**GET /bids/{auction_id}**
```bash
curl -X GET http://127.0.0.1:8000/bids/1
```

**GET /bids/my**
```bash
curl -X GET http://127.0.0.1:8000/bids/my \
  -H "Authorization: Bearer TOKEN"
```

### Transactions
**GET /transactions/**
```bash
curl -X GET http://127.0.0.1:8000/transactions/ \
  -H "Authorization: Bearer TOKEN"
```

**PUT /transactions/{transaction_id}/status**
```bash
curl -X PUT http://127.0.0.1:8000/transactions/1/status \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"payment_status":"paid"}'
```

## Catatan
- Upload file tersimpan di folder `uploads/` dan dapat diakses melalui `/uploads/{filename}`
- Auto-close auction berjalan setiap 30 detik
