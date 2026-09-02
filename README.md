# Deprem Erken Hasar Tahmini PoC

TÜBİTAK-AFAD 1001-UDAP Ortak Çağrısı, madde 2.3 ("Deprem Erken Hasar Tahminine Yönelik Modelleme Çalışmaları") kapsamında hazırlanan proje önerisi için pilot uygulama (PoC) çalışmaları.

Bu depo, çağrı analizinden mimari tasarıma ve veri aktarım betiklerine kadar üretilen tüm ara çıktıları barındırır. Proje ileri bir tarihte hayata geçirilecektir; bu depo o zamana kadar planlı ve izlenebilir ilerlemeyi sağlamak için tutulmaktadır.

## Amaç

Deprem sonrası hızlı durum değerlendirmesi için gerekli heterojen veri kaynaklarının (yapı envanteri, nüfus dağılımı, mekânsal adres kayıt sistemi verileri, gerçek zamanlı yer hareketi ölçümleri) tek bir coğrafi veritabanı mimarisinde birleştirilmesi ve bu verilerin standart bir mekânsal veri servisi (WMS/WFS) aracılığıyla yerel yönetimler ile merkezi kurumlar arasında paylaşılabilir hale getirilmesi.

PoC aşamasında, Türkiye'ye özgü veri temini süreçleri başlatılana kadar açık/uluslararası veri kaynakları (OpenStreetMap, USGS, GEM/OpenQuake, WorldPop) kullanılarak mimarinin uçtan uca doğrulanması hedeflenmektedir.

## Depo Yapısı

```
.
├── docs/
│   ├── cagri_analizi.md            # Çağrının gereksinim ve kısıt analizi
│   ├── poc_mimari_referans.html    # Katman/öğe bazlı mimari referans (görsel)
│   └── poc_mimari_referans.json    # Aynı mimarinin taşınabilir JSON formatı
├── scripts/
│   └── overpass_to_postgis.sh      # OSM bina verisini Overpass + GDAL/OGR ile PostGIS'e aktarır
└── sql/                             # PostGIS şema tanımları (henüz boş — sonraki adım)
```

## Mimari Özet

Beş katman: **dış veri kaynakları → PostGIS mekânsal veritabanı → hasar tahmin motoru → mekânsal veri servisi (WMS/WFS) → paydaşlar**. Her katmandaki öğenin girdisi, çıktısı ve çıktının aktığı hedef `docs/poc_mimari_referans.json` dosyasında hiyerarşik olarak tanımlıdır.

## Durum ve Sonraki Adımlar

- [x] Çağrı metni incelendi, madde 2.3 hedef olarak belirlendi
- [x] PoC mimarisi (5 katman) tasarlandı ve dokümante edildi
- [x] OSM → PostGIS veri aktarım betiği yazıldı
- [x] Danışmana konu özeti ve pilot uygulama fikri iletildi
- [ ] Danışmanın literatür taraması ve önceki çalışma kontrolü sonucu bekleniyor
- [ ] PostGIS şema tanımları (`sql/`) oluşturulacak
- [ ] Hasar tahmin motoru (kırılganlık fonksiyonu + GMM hesaplama) entegrasyonu
- [ ] GeoServer WMS/WFS servis katmanı kurulumu

## Gereksinimler

- PostgreSQL + PostGIS eklentisi
- GDAL/OGR (`ogr2ogr`)
- `curl`, `psql`

## Lisans / Gizlilik

Bu depo özel (private) tutulmalıdır; çağrı metni ve danışman iletişimine ait bilgiler içermektedir.
