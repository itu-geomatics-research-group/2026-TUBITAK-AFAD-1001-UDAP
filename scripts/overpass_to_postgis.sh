#!/usr/bin/env bash
# ==============================================================================
# San Francisco bina envanteri: Overpass -> GDAL/OGR -> PostGIS aktarim betigi
# ==============================================================================
# Amac: OpenStreetMap'ten bina poligonlarini (geometri + oznitelik) cekip
#       PostGIS'e "bina_envanteri" tablosu olarak yuklemek.
#
# On kosullar:
#   - GDAL/OGR kurulu olmali (ogr2ogr komutu calisir durumda)
#   - Hedef PostgreSQL veritabaninda PostGIS eklentisi etkin olmali
#   - curl ve psql komutlari erisilebilir olmali
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1) AYARLAR - kendi ortamina gore duzenle
# ------------------------------------------------------------------------------
OVERPASS_URL="https://overpass-api.de/api/interpreter"
OUTPUT_OSM="sf_buildings.osm"           # GDAL'in OSM surucusu .osm (XML) formatini okur, JSON'u okumaz
OSM_CONFIG="osmconf_buildings.ini"      # asagida uretilecek ozel GDAL sema dosyasi

PG_HOST="localhost"
PG_PORT="5432"
PG_DB="deprem_poc"
PG_USER="postgres"
PG_PASSWORD="CHANGE_ME"
TARGET_TABLE="bina_envanteri"
TARGET_SRS="EPSG:4326"

PG_CONN="PG:dbname=${PG_DB} host=${PG_HOST} port=${PG_PORT} user=${PG_USER} password=${PG_PASSWORD}"

# ------------------------------------------------------------------------------
# 2) OVERPASS SORGUSU - geometri uretimi icin duzeltilmis versiyon
# ------------------------------------------------------------------------------
# Orijinal sorgundan farklari ve nedenleri:
#   - [out:json] kaldirildi: GDAL'in OSM surucusu yalnizca standart .osm XML
#     formatini anliyor, Overpass'in ozel JSON ciktisini degil.
#   - "out body; >; out skel qt;" eklendi: secilen way/relation'larin
#     govdesini ("out body") yazdiktan sonra ">" ile bu ogelerin referans
#     verdigi TUM node'lari (koordinatlariyla) sorguya dahil ediyor,
#     "out skel qt;" da bu node'lari hizlica (quiet, terse) yazdiriyor.
#     Bu adim olmadan way'ler sadece node ID listesi icerir, gercek
#     koordinatlar (geometri) dosyada bulunmaz ve GDAL poligon uretemez.
read -r -d '' OVERPASS_QUERY << 'EOF' || true
[timeout:1800];
area
  ["boundary"="administrative"]
  ["name"="San Francisco"]
  ["admin_level"="6"]->.roi;
(
  way["building"](area.roi);
  relation["building"](area.roi);
);
out body;
>;
out skel qt;
EOF

echo "[1/5] Overpass sorgusu gonderiliyor (bu adim biraz surebilir)..."
curl -s --data-urlencode "data=${OVERPASS_QUERY}" "$OVERPASS_URL" -o "$OUTPUT_OSM"

# Overpass hata durumunda da genelde HTTP 200 doner; iceriği kontrol ediyoruz.
if grep -q "<remark>" "$OUTPUT_OSM"; then
  echo "HATA: Overpass sorgu hatasi tespit edildi. Detay icin dosyayi incele: $OUTPUT_OSM" >&2
  exit 1
fi
echo "      Indirilen dosya: $OUTPUT_OSM ($(du -h "$OUTPUT_OSM" | cut -f1))"

# ------------------------------------------------------------------------------
# 3) OZEL GDAL SEMA DOSYASI (osmconf.ini)
# ------------------------------------------------------------------------------
# GDAL'in varsayilan sema dosyasi, building:levels, addr:* gibi "ikincil"
# etiketleri ayri kolon yapmaz; hepsini "other_tags" adli tek bir hstore
# alaninin icine gomer. Ihtiyacimiz olan alanlari dogrudan sorgulanabilir
# kolon olarak cekebilmek icin ozel bir sema dosyasi tanimliyoruz.
#
# [multipolygons] basligi onemli: GDAL'in OSM surucusunde kapali way'lerden
# (binalarin buyuk cogunlugu) ve relation'lardan (coklu parcali binalar)
# turetilen poligon geometrileri bu katmanda toplanir.
cat > "$OSM_CONFIG" << 'EOF'
[multipolygons]
osm_id=yes
osm_way_id=no
attributes=building,name,building:levels,building:use,addr:housenumber,addr:street
other_tags=yes
EOF

# ------------------------------------------------------------------------------
# 4) HEDEF VERITABANINDA POSTGIS EKLENTISINI GARANTI ALTINA AL
# ------------------------------------------------------------------------------
echo "[2/5] PostGIS eklentisi kontrol ediliyor..."
PGPASSWORD="$PG_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# ------------------------------------------------------------------------------
# 5) GDAL/OGR ILE POSTGIS'E AKTARIM
# ------------------------------------------------------------------------------
# ogr2ogr, .osm dosyasini GDAL'in dahili OSM surucusuyle okur.
# -sql parametresiyle "multipolygons" katmanindan sadece building etiketi
# tasiyan kayitlari secip, sema dosyasinda tanimladigimiz kolon adlarini
# daha anlamli isimlere (kat_sayisi, bina_no, sokak) donusturuyoruz.
#
#   -nlt PROMOTE_TO_MULTI : Polygon/MultiPolygon karisikligini engeller,
#                           PostGIS tarafinda tek tip (MULTIPOLYGON) kolon olusur
#   -lco GEOMETRY_NAME=geom : geometri kolonunun adini standart "geom" yapar
#   -t_srs EPSG:4326        : koordinatlari WGS84'e sabitler (PostGIS varsayilani)
#   -overwrite               : ayni isimde tablo varsa uzerine yazar (ilk kurulum icin)
echo "[3/5] PostGIS'e aktariliyor..."
OSM_CONFIG_FILE="$(pwd)/${OSM_CONFIG}" \
ogr2ogr \
  -f "PostgreSQL" "$PG_CONN" \
  "$OUTPUT_OSM" \
  -sql "SELECT osm_id, building, name, \"building:levels\" AS kat_sayisi, \"addr:housenumber\" AS bina_no, \"addr:street\" AS sokak FROM multipolygons WHERE building IS NOT NULL" \
  -nln "$TARGET_TABLE" \
  -nlt PROMOTE_TO_MULTI \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -t_srs "$TARGET_SRS" \
  -overwrite

echo "[4/5] Tablo olusturuldu: $TARGET_TABLE"

# ------------------------------------------------------------------------------
# 6) DOGRULAMA
# ------------------------------------------------------------------------------
echo "[5/5] Kayit sayisi kontrol ediliyor..."
PGPASSWORD="$PG_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" \
  -c "SELECT COUNT(*) AS bina_sayisi, ST_GeometryType(geom) AS geometri_tipi FROM ${TARGET_TABLE} GROUP BY geometri_tipi;"

echo "Tamamlandi. '${TARGET_TABLE}' tablosu '${PG_DB}' veritabaninda hazir."
