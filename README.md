# FitCore — Kurulum Rehberi

## 1. Supabase Kurulumu

1. https://supabase.com → Hesap aç / Giriş yap
2. "New Project" → İsim ver → Şifre belirle → Oluştur
3. Sol menü → **Settings** → **API** sayfasına git
4. **Project URL** ve **anon public key**'i kopyala

## 2. Key'leri Uygulamaya Gir

`src/lib/supabase.js` dosyasını aç:

```js
const SUPABASE_URL = 'https://BURAYA_PROJECT_URL_GEL'
const SUPABASE_ANON_KEY = 'BURAYA_ANON_KEY_GEL'
```

Bu iki satırı kendi değerlerinle değiştir.

## 3. Veritabanını Kur

1. Supabase → Sol menü → **SQL Editor**
2. `supabase_schema.sql` dosyasının tamamını kopyala
3. SQL Editor'e yapıştır → **Run** butonuna tıkla

## 4. Uygulamayı Çalıştır

Terminal açıp proje klasörüne git:

```bash
npm install
npm run dev
```

Tarayıcıda http://localhost:3000 aç.

## 5. Deploy (Opsiyonel — Vercel ile ücretsiz)

```bash
npm install -g vercel
vercel
```

Adımları takip et → canlı linkin hazır!
