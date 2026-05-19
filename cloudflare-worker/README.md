# Cloudflare Worker — R2 Storage Proxy

Worker ini menjadi proxy antara app dan Cloudflare R2, memberikan URL dengan SSL valid tanpa perlu custom domain.

## Cara Deploy

### 1. Install dependencies
```bash
cd cloudflare-worker
npm install
```

### 2. Login ke Cloudflare
```bash
npx wrangler login
```
Browser akan terbuka untuk authorize. Login dengan akun Cloudflare yang sama dengan R2 bucket.

### 3. Deploy Worker
```bash
npm run deploy
```

Output akan menampilkan URL Worker:
```
✅ Deployed to: https://marketing-jagaddhita-r2.<your-subdomain>.workers.dev
```

### 4. Update `assets/env` di Flutter app
Ganti `R2_PUBLIC_URL_PREFIX` dengan URL Worker yang baru:
```
R2_PUBLIC_URL_PREFIX=https://marketing-jagaddhita-r2.<your-subdomain>.workers.dev
```

### 5. Hot restart Flutter app
```
R  ← tekan R di terminal flutter run
```

---

## Cara Kerja

```
Flutter App
    │
    │  UPLOAD: langsung ke R2 via minio SDK (S3 API)
    ▼
Cloudflare R2 Bucket
    │
    │  AKSES/TAMPIL: via Worker proxy
    ▼
marketing-jagaddhita-r2.xxx.workers.dev
    │
    │  SSL valid, CORS terkonfigurasi
    ▼
Flutter App (Image.network)
```

## Development / Test lokal
```bash
npm run dev
# Worker berjalan di http://localhost:8787
# Test: http://localhost:8787/test/r2_connection_test.txt
```

## Monitor logs production
```bash
npm run tail
```
