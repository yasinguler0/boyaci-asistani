cat > README.md << 'EOF'
# Painter's Assistant — Telegram-Based Stock & Pricing Bot (V2)

> **Version note:** This is the V2 (deterministic) architecture. V1 was an agentic prototype where an AI Agent made every decision via tool-calling. I found the error rate in tool-calling too high to trust, so in V2 I moved all business logic into SQL and deterministic code, leaving the LLM only for understanding. The V1 prototype lives in a separate repo as a comparison.

A self-hosted automation system that lets a freelance painter run daily operations — price quotes, stock tracking, job records, material management — through a Telegram chat.

## Architecture Philosophy

The core design decision: **the AI only understands and extracts; all business logic and calculations are deterministic.**

Gemini's job is to classify the incoming message (intent) and pull structured data out of it (square meters, date, amount, etc.). Critical operations — price calculation, stock deduction, reservations — are never handled by the LLM. They run on SQL and plain code. This keeps pricing and stock numbers consistent, because a language model never touches the math.

## Tech Stack

- **Automation:** n8n (self-hosted, Docker)
- **Database:** PostgreSQL (transactions matter for stock consistency)
- **LLM:** Google Gemini 2.0 Flash (intent classification + data extraction + receipt OCR)
- **Interface:** Telegram Bot API
- **Networking:** Cloudflare Tunnel (HTTPS access over my own domain)

## Features

- **Price quote:** "120 m2 with ceiling, how much" → automatic m²-based calculation
- **Stock query:** separates on-shelf / reserved / free quantities
- **Job record + reservation:** when a job is taken, material is reserved, not deducted from the shelf
- **Job done / cancelled:** state-based stock handling (status change, not deletion)
- **Material intake:** by text ("bought 20 liters of paint") or by **receipt photo**
- **Receipt OCR:** reads multiple items from a photo, skips items not tracked in stock
- **Price update:** remembers the last quote given and updates it

## Design Decisions & Known Limits

- Reservations are never deleted; when a job's status changes (done/cancelled) it drops out of the calculation automatically. This keeps the history auditable.
- The price-update memory holds one record per user; it's built for a single-painter, single-session scenario.
- The bot runs on my development machine; for production it needs to move to an always-on server (VPS).

## Setup

1. Copy `.env.example` to `.env` and fill in the values
2. `docker compose up -d`
3. `docker compose exec -T postgres psql -U boyaci -d boyaci_db < schema.sql`
4. Add Telegram, Postgres, and Gemini credentials in the n8n interface
5. Import the workflow and set it to Active

---

# Boyacı Asistanı — Telegram Tabanlı Stok ve Fiyat Botu (V2)

> **Versiyon notu:** Bu, projenin V2 (deterministik) mimarisidir. V1'de her kararı bir AI Agent tool-calling ile veriyordu. Tool-calling'deki hata oranını güvenilir bulmadığım için V2'de tüm iş mantığını SQL ve deterministik koda taşıdım; LLM'i yalnızca anlama işi için bıraktım. V1 prototipi karşılaştırma olarak ayrı bir repoda yer alıyor.

Serbest çalışan bir boyacının günlük işlerini — fiyat teklifi, stok takibi, iş kaydı, malzeme yönetimi — Telegram üzerinden yürüten, kendi kendine barındırılan bir otomasyon sistemi.

## Mimari Felsefe

Temel tasarım kararı: **yapay zeka yalnızca anlar ve veri çıkarır; tüm iş mantığı ve hesaplamalar deterministiktir.**

Gemini'nin görevi gelen mesajı sınıflandırmak (intent) ve içinden yapısal veri çıkarmaktır (metrekare, tarih, tutar vb.). Fiyat hesaplama, stok düşme, rezervasyon gibi kritik işlemler LLM'e bırakılmaz; SQL ve düz kod ile çalışır. Böylece hesaplamaya bir dil modeli dokunmadığı için fiyat ve stok tutarlı kalır.

## Teknoloji Yığını

- **Otomasyon:** n8n (self-hosted, Docker)
- **Veritabanı:** PostgreSQL (stok tutarlılığı için transaction desteği)
- **LLM:** Google Gemini 2.0 Flash (intent sınıflandırma + veri çıkarımı + fiş OCR)
- **Arayüz:** Telegram Bot API
- **Ağ:** Cloudflare Tunnel (kendi domainim üzerinden HTTPS erişimi)

## Özellikler

- **Fiyat teklifi:** "120 m2 tavan dahil kaç para" → m² tabanlı otomatik hesap
- **Stok sorgusu:** depodaki / rezerve / serbest miktar ayrımı
- **İş kaydı + rezervasyon:** iş alınınca malzeme raftan düşmez, rezerve edilir
- **İş bitti / iptal:** durum bazlı stok yönetimi (silme değil, durum değişimi)
- **Malzeme alımı:** metin ("20 litre boya aldım") veya **fiş fotoğrafı** ile
- **Fiş OCR:** fotoğraftan çok kalemli okuma, takip edilmeyen kalemleri atlama
- **Fiyat güncelleme:** verilen son teklifi hatırlama ve güncelleme

## Mimari Kararlar ve Bilinen Sınırlar

- Rezervasyonlar silinmez; işin durumu değişince (tamamlandı/iptal) hesaptan otomatik düşer. Bu, geçmişi izlenebilir tutar.
- Fiyat güncelleme hafızası kişi başına tek kayıt tutar; tek boyacı-tek oturum senaryosu için tasarlanmıştır.
- Bot geliştirme makinemde çalışır; production için 7/24 açık bir sunucuya (VPS) taşınması gerekir.

## Kurulum

1. `.env.example` dosyasını `.env` olarak kopyalayın ve değerleri doldurun
2. `docker compose up -d`
3. `docker compose exec -T postgres psql -U boyaci -d boyaci_db < schema.sql`
4. n8n arayüzünde Telegram, Postgres ve Gemini credential'larını girin
5. Workflow'u import edip Active yapın
EOF
