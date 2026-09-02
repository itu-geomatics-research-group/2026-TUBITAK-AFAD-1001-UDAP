# TÜBİTAK-AFAD 1001-UDAP Ortak Çağrısı — Analiz Notları

## Çağrı Kimliği

- **Program:** 1001-UDAP Ulusal Deprem Araştırmaları Programı Ortak Çağrısı (TÜBİTAK-AFAD)
- **Destek programı:** 1001-Bilimsel ve Teknolojik Araştırma Projelerini Destekleme Programı
- **Hedeflenen alt madde:** 2.3 — Deprem Erken Hasar Tahminine Yönelik Modelleme Çalışmaları

## Takvim

| Aşama | Tarih |
|---|---|
| Başvuru sisteminin açılışı | 31.07.2026 |
| Çevrimiçi başvurunun tamamlanma son tarihi | 21.09.2026 |
| E-imza sürecinin tamamlanma son tarihi | 24.09.2026 |

## Destek Koşulları

- Azami proje süresi: **24 ay**
- Destek üst limiti: **3.000.000 TL**
- Proje Teşvik İkramiyesi (PTİ) ve kurum hissesi ödeneği **mevcut**
- Bütçenin tek bir kalemde yoğunlaşmaması, kalemler arası dengeli dağılım şartı var

## Görev Alma Sınırları

- En fazla **1 projede yürütücü**, **2 projede araştırmacı**
- Toplamda en fazla **3 projede danışman**
- Özel sektör çalışanları yalnızca **araştırmacı** olabilir (yürütücü/danışman olamaz)
- Doktora öğrencisi statüsü nedeniyle bu çağrıda muhtemel rol: **araştırmacı** (yürütücülük için doktora şartı ARDEB ile teyit edilmeli)

## Kritik Kısıtlar

- Önerilen çalışma, daha önce TÜBİTAK veya AFAD-UDAP tarafından desteklenmiş projelerde üretilen verilerin **tekrarı niteliğinde olamaz** — benzer içerikli öneriler değerlendirmeye alınmadan iade edilir
- Çağrının iki ana önceliği (Deprem Kaynak Süreçleri / Deprem Tehlike ve Risk Analizleri) ile **ilişkili olmayan** öneriler de aynı şekilde iade edilir
- Üretken Yapay Zekâ (ÜYZ) kullanımı, TÜBİTAK'ın yayınladığı rehbere tabidir — başvuru hazırlığında dikkate alınmalı
- Etik Kurul Onay Belgesi ve Yasal/Özel İzin Belgesi başvuruda istenmiyor, yalnızca destek kararı sonrası sözleşme aşamasında talep ediliyor

## Seçilen Odak: Madde 2.3

> "Yerel yönetimler ve merkezi kurumlar arasında veri paylaşımını kolaylaştıracak sistemler, mekânsal veri servisleri (WMS tabanlı çıktılar), afet senaryosu üretimi ve çok paydaşlı veri entegrasyonu" + "Yapı envanteri, nüfus dağılımı, mekânsal adres kayıt sistemi verileri ve yer hareketi ölçümlerinin deprem modelleme çalışmalarına entegre edilmesi"

Bu madde, proje sahibinin profiliyle (jeomatik doktora öğrencisi, PostgreSQL DBA, EO coder, sistem yöneticisi) doğrudan örtüşüyor: mekânsal veritabanı tasarımı, coğrafi veri servisi (WMS/WFS) kurulumu ve çok kaynaklı veri entegrasyonu bileşenleri.

## PoC Veri Stratejisi

Türkiye'ye özgü veri kaynaklarının (MAKS, AFAD deprem kataloğu, il bazlı bina envanteri) temini başvuru öncesi zor olduğundan, PoC aşamasında mimarinin doğrulanması amacıyla aşağıdaki açık/uluslararası veri kaynakları kullanılacaktır. Sistem, veri şeması düzeyinde Türkiye'nin mekânsal veri standartlarına uyarlanabilir şekilde tasarlanacaktır.

| İhtiyaç | PoC Kaynağı | Türkiye Karşılığı (gelecek faz) |
|---|---|---|
| Bina envanteri | OpenStreetMap | MAKS, il bazlı bina envanteri |
| Nüfus dağılımı | WorldPop | TÜİK nüfus verisi |
| Deprem kataloğu / yer hareketi | USGS (katalog, ShakeMap) | AFAD deprem kataloğu |
| Kırılganlık fonksiyonu / hasar modeli | GEM / OpenQuake | AFAD/Türkiye'ye özgü taksonomi (varsa) |

## İlgili Belgeler

- `docs/poc_mimari_referans.html` — beş katmanlı PoC mimarisinin öğe bazlı referans dokümanı (görsel)
- `docs/poc_mimari_referans.json` — aynı hiyerarşinin taşınabilir/programatik formatı
- `scripts/overpass_to_postgis.sh` — OpenStreetMap bina verisini Overpass API üzerinden çekip GDAL/OGR ile PostGIS'e aktaran betik

## Danışman İletişimi — Sonraki Adım

Danışmana pilot uygulama ve konu özeti iletildi; literatür taraması ve daha önce bu alanda çalışma üretilip üretilmediğinin kontrolü danışman tarafından yapılacak.
