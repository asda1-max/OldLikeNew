# LelangKu Admin Panel

Admin web panel untuk platform lelang barang bekas **LelangKu**. Dibangun dengan Express.js + EJS, terintegrasi dengan backend FastAPI.

## Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.x
- **Template Engine**: EJS (Server-side Rendering)
- **HTTP Client**: Axios
- **Session**: express-session
- **Charts**: Chart.js
- **Icons**: Lucide Icons (CDN)
- **Font**: Inter (Google Fonts)
- **Dev**: nodemon (auto-reload)

## Fitur

### 📊 Dashboard
- Summary cards (Total Users, Active Auctions, Transactions, Revenue)
- Chart: Payment Status (Doughnut)
- Chart: Top Categories (Bar)
- Chart: User Roles (Doughnut)
- Recent Transactions table

### 👥 User Management
- List semua user dengan filter role & search
- Detail user + Verify/Unverify

### 📦 Item Management
- List semua items (card grid dengan gambar)
- Filter by category & condition
- Detail item + image gallery
- Info seller terkait

### 📢 Auction Management
- List auctions dengan tab status (active/closed/cancelled/draft)
- Countdown timer untuk auction aktif
- Detail auction + bid history (timeline)
- Cancel auction

### 💰 Transaction Management
- List transaksi dengan filter payment & shipping status
- Detail transaksi (buyer, seller, auction info)
- Update payment & shipping status

## Instalasi

```bash
cd admin-panel
npm install
```

## Konfigurasi

Copy `.env.example` ke `.env` dan sesuaikan:

```bash
cp .env.example .env
```

```env
API_BASE_URL=https://lelangku-backend-487072029768.asia-southeast2.run.app
SESSION_SECRET=your-secret-key-here
PORT=3000
NODE_ENV=development
```

## Menjalankan

```bash
# Development (auto-reload)
npm run dev

# Production
npm start
```

Akses di: `http://localhost:3000`

## Login

Gunakan akun dengan role `admin` dari backend LelangKu.

## Struktur Folder

```
admin-panel/
├── app.js                    # Express entry point
├── config/
│   └── index.js              # Environment config
├── middleware/
│   ├── auth.js               # JWT session checker
│   └── errorHandler.js       # Global error handler
├── services/
│   └── api.js                # Axios API client
├── routes/
│   ├── auth.js               # Login/logout
│   ├── dashboard.js          # Dashboard analytics
│   ├── users.js              # User management
│   ├── items.js              # Item management
│   ├── auctions.js           # Auction monitoring
│   └── transactions.js       # Transaction management
├── public/
│   ├── css/style.css          # Design system
│   └── js/main.js             # Client-side JS
├── views/
│   ├── partials/              # Head, sidebar, header, footer
│   ├── layouts/               # Main & auth layouts
│   ├── auth/                  # Login page
│   ├── dashboard/             # Dashboard page
│   ├── users/                 # User list & detail
│   ├── items/                 # Item list & detail
│   ├── auctions/              # Auction list & detail
│   └── transactions/          # Transaction list & detail
└── README.md
```
