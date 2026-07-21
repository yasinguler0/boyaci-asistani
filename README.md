# Boyacı Asistanı — Telegram Tabanlı Stok ve Fiyat Yönetim Botu

Serbest çalışan bir boyacının günlük operasyonlarını (fiyat teklifi, stok takibi, iş kaydı, malzeme yönetimi) Telegram üzerinden yöneten, kendi kendine barındırılan (self-hosted) bir otomasyon sistemi.

## Mimari Felsefe

Bu projenin temel tasarım kararı şudur: **Yapay zeka yalnızca anlama ve çıkarım yapar; tüm iş mantığı ve hesaplamalar deterministiktir.**

Gemini'nin görevi gelen mesajı sınıflandırmak (intent) ve içinden yapısal veri çıkarmaktır (metrekare, tarih, tutar vb.). Fiyat hesaplama, stok düşme ve rezervasyon gibi kritik işlemler asla LLM'e bırakılmaz — bunlar SQL ve deterministik kod ile yürütülür. Bu sayede bot asla yanlış fiyat veya hatalı stok bilgisi üretmez.

## Teknoloji Yığını

- **Otomasyon:** n8n (self-hosted, Docker)
- **Veritabanı:** PostgreSQL (transaction desteği stok tutarlılığı için kritik)
- **LLM:** Google Gemini 2.0 Flash (intent sınıflandırma + veri çıkarımı + fiş OCR)
- **Arayüz:** Telegram Bot API
- **Ağ:** Cloudflare Tunnel (kendi domain üzerinden HTTPS erişimi)

## Özellikler

- **Fiyat teklifi:** "120 m2 tavan dahil kaç para" → m² tabanlı otomatik hesap
- **Stok sorgusu:** Depodaki + rezerve edilmiş + serbest miktar ayrımı
- **İş kaydı + rezervasyon:** İş alındığında malzeme raftan düşmez, rezerve edilir
- **İş bitti / iptal:** Durum bazlı stok yönetimi (silme değil, durum değişimi)
- **Malzeme alımı:** Metin ("20 litre boya aldım") veya **fiş fotoğrafı** ile
- **Fiş OCR:** Fotoğraftan çok kalemli malzeme okuma, tanınmayan kalemleri atlama
-
cat > README.md << 'EOF'
# Boyacı Asistanı — Telegram Tabanlı Stok ve Fiyat Yönetim Botu

Serbest çalışan bir boyacının günlük operasyonlarını (fiyat teklifi, stok takibi, iş kaydı, malzeme yönetimi) Telegram üzerinden yöneten, kendi kendine barındırılan (self-hosted) bir otomasyon sistemi.

## Mimari Felsefe

Bu projenin temel tasarım kararı şudur: **Yapay zeka yalnızca anlama ve çıkarım yapar; tüm iş mantığı ve hesaplamalar deterministiktir.**

Gemini'nin görevi gelen mesajı sınıflandırmak (intent) ve içinden yapısal veri çıkarmaktır (metrekare, tarih, tutar vb.). Fiyat hesaplama, stok düşme ve rezervasyon gibi kritik işlemler asla LLM'e bırakılmaz — bunlar SQL ve deterministik kod ile yürütülür. Bu sayede bot asla yanlış fiyat veya hatalı stok bilgisi üretmez.

## Teknoloji Yığını

- **Otomasyon:** n8n (self-hosted, Docker)
- **Veritabanı:** PostgreSQL (transaction desteği stok tutarlılığı için kritik)
- **LLM:** Google Gemini 2.0 Flash (intent sınıflandırma + veri çıkarımı + fiş OCR)
- **Arayüz:** Telegram Bot API
- **Ağ:** Cloudflare Tunnel (kendi domain üzerinden HTTPS erişimi)

## Özellikler

- **Fiyat teklifi:** "120 m2 tavan dahil kaç para" → m² tabanlı otomatik hesap
- **Stok sorgusu:** Depodaki + rezerve edilmiş + serbest miktar ayrımı
- **İş kaydı + rezervasyon:** İş alındığında malzeme raftan düşmez, rezerve edilir
- **İş bitti / iptal:** Durum bazlı stok yönetimi (silme değil, durum değişimi)
- **Malzeme alımı:** Metin ("20 litre boya aldım") veya **fiş fotoğrafı** ile
- **Fiş OCR:** Fotoğraftan çok kalemli malzeme okuma, tanınmayan kalemleri atlama
- **Fiyat güncelleme:** Verilen son teklifi hatırlama ve güncelleme

## Mimari Kararlar ve Bilinen Sınırlar

- Rezervasyonlar silinmez; işin durumu değiştiğinde (tamamlandı/iptal) hesaptan otomatik düşer. Bu, geçmişin izlenebilir kalmasını sağlar (audit trail).
- Fiyat güncelleme hafızası kişi başına tek kayıt tutar; tek boyacı-tek oturum senaryosu için tasarlanmıştır.
- Bot geliştirici makinesinde çalışır; production için 7/24 açık bir sunucuya (VPS) taşınması gerekir.

## Kurulum

1. `.env.example` dosyasını `.env` olarak kopyalayın ve değerleri doldurun
2. `docker compose up -d`
3. `docker compose exec -T postgres psql -U boyaci -d boyaci_db < schema.sql`
4. n8n arayüzünde Telegram, Postgres ve Gemini credential'larını girin
5. Workflow'u import edip Active yapın

## Versiyon Notu

Bu, projenin V2 (deterministik) mimarisidir. V1 (agentic, AI Agent tabanlı) prototipi ayrı bir repoda yer alır ve neden deterministik mimariye geçildiğini gösteren bir karşılaştırma sunar.
