# içerik akışı 🌊

Hesap açıp gönderi paylaşacağın, oy vereceğin ve yorum yazacağın çok kullanıcılı
eğlence/içerik paylaşım sitesi. Arka uç olarak **Supabase (ücretsiz plan)**
kullanır.

## Kurulum (10 dakika)

### 1) Ücretsiz Supabase projesi aç
1. [supabase.com](https://supabase.com) → **Sign up** → **New project**
2. İsim ver (örn. `icerik-akisi`), şifre belirle, bölge **Frankfurt** → **Create**

### 2) Veritabanını kur
1. Sol menüden **SQL Editor** → **New query**
2. Bu klasördeki `schema.sql` dosyasının **tümünü** yapıştır → **Run**
3. "Success" görmelisin. Bu, `posts`, `votes`, `comments`, `profiles` tablolarını
   ve puPuanlı akış görünümünü (`akis`) oluşturur.

### 3) Anahtarı siteye bağla
1. **Project Settings → API** (veya **Data API**) sayfasını aç
2. **Project URL** değerini kopyala → `config.js` içindeki `SUPABASE_URL` tırnaklarına yapıştır
3. **anon public** anahtarını kopyala → `SUPABASE_ANON_KEY` tırnaklarına yapıştır

### 4) Aç ve dene
`index.html`'i tarayıcıda aç. Kayıt ol (e-posta doğrulaması gelirse linki onayla),
giriş yap, ilk gönderiyi paylaş. 🎉

## Neler var?

- 📝 **Gönderi paylaşma** — başlık + metin + görsel URL
- 👍 **Oylama** — skor SQL tarafında hesaplanır (`akis` görünümü)
- 💬 **Yorumlar** — herkes okur, üyeler yazar
- 🔐 **Kayıt / giriş / çıkış** — e-posta doğrulamalı, Supabase Auth
- 🗑 **Kendi içeriğini silme**
- 🛡 **Güvenlik** — tüm tablolarda RLS (satır düzeyi güvenlik) açık; kimse
  başkasının içeriğini değiştiremez

## Herkese açma (barındırma)

`icerik-akisi` klasörünü bir GitHub deposuna push et → depo ayarlarından
**Pages**'i aç → site herkese açık olur (`githubkullanıcı.github.io/depo-adı`).
Supabase anahtarın "anon" — yani public tasarlanmış; veriler tablo yetkileriyle korunur.

## Dosyalar

| Dosya        | Görev                                      |
|--------------|--------------------------------------------|
| `index.html` | Tüm arayüz + logic (tek dosya)             |
| `config.js`  | Supabase URL + anon key (senin yerin)      |
| `schema.sql` | Supabase SQL Editor'a yapıştırılacak şema  |
