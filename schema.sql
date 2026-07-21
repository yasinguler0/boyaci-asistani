-- ============ FİYAT TARİFESİ ============
-- Boyacının fiyatları burada yaşar. Fiyat değişince SADECE bu tablo güncellenir,
-- ne koda ne yapay zekaya dokunulur.
CREATE TABLE fiyat_tarifesi (
    id SERIAL PRIMARY KEY,
    kalem VARCHAR(50) UNIQUE NOT NULL,
    deger NUMERIC(10,2) NOT NULL,
    aciklama TEXT
);

INSERT INTO fiyat_tarifesi (kalem, deger, aciklama) VALUES
('duvar_m2',            90,   'Ic cephe duvar boyama, TL/m2 (iscilik+boya)'),
('tavan_m2',            70,   'Tavan boyama TL/m2'),
('min_is_tutari',       4000, 'Bu tutarin altina is alinmaz'),
('duvar_alan_carpani',  2.6,  'Ev m2 -> boyanacak duvar alani tahmini carpani'),
('boya_kapsama',        11,   'Bir litre boya kac m2 boyar (tek kat)'),
('kat_sayisi',          2,    'Standart kac kat boya atilir');

-- ============ STOK ============
-- Depodaki malzemeler. kritik_seviye: bu rakamin altina dusunce uyari verecegiz.
CREATE TABLE stok (
    id SERIAL PRIMARY KEY,
    malzeme VARCHAR(100) UNIQUE NOT NULL,
    birim VARCHAR(20) NOT NULL,
    miktar NUMERIC(10,2) NOT NULL DEFAULT 0,
    kritik_seviye NUMERIC(10,2) DEFAULT 0
);

INSERT INTO stok (malzeme, birim, miktar, kritik_seviye) VALUES
('ic_cephe_boyasi', 'litre', 35, 10),
('tavan_boyasi',        'litre', 15, 5),
('macun',               'kg',    20, 5),
('bant_ortu_seti',      'adet',  6,  2);

-- ============ İŞLER ============
-- Onaylanan isler buraya kaydedilir. Musteri bilgisi + tarih + tutar.
CREATE TABLE isler (
    id SERIAL PRIMARY KEY,
    musteri_adi VARCHAR(100),
    telefon VARCHAR(20),
    adres TEXT,
    is_tarihi DATE,
    metrekare NUMERIC(8,2),
    tavan_dahil BOOLEAN DEFAULT true,
    tutar NUMERIC(12,2),
    statu VARCHAR(30) DEFAULT 'onaylandi',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============ STOK HAREKETLERİ ============
-- Her stok degisiminin kaydi. "Bu boya nereye gitti?" sorusunun cevabi.
CREATE TABLE stok_hareketleri (
    id SERIAL PRIMARY KEY,
    is_id INT REFERENCES isler(id),
    malzeme VARCHAR(100) NOT NULL,
    miktar NUMERIC(10,2) NOT NULL,
    yon VARCHAR(10) NOT NULL CHECK (yon IN ('giris','cikis','rezerv')),
    tarih TIMESTAMPTZ DEFAULT now()
);

-- ============ YARIM KALAN KONUŞMALAR ============
-- Bot soru sordugunda, konusmanin neresinde kaldigini burada tutar.
CREATE TABLE pending_conversations (
    chat_id BIGINT PRIMARY KEY,
    intent VARCHAR(30) NOT NULL,
    toplanan_veri JSONB NOT NULL DEFAULT '{}',
    eksik_alanlar TEXT[] NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);
