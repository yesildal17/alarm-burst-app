# Alarm Burst

Android saat uygulaması: alarm, dünya saati, zamanlayıcı ve kronometre.
Alarmın farkı, belirli bir saat aralığında belirli sıklıkta bir **dizi**
alarm kurabilmesi — tek alarmla uyanamayanlar için.

    08:00 ile 08:20 arası 2 dakikada bir  →  11 alarm

    08:00 · 08:02 · 08:04 · … · 08:18 · 08:20

Aralığın iki ucu da dahildir. Flutter ile yazıldı;
paket adı `com.kadircevy.alarmburst`.

## Çalıştırma

    flutter test                 # 67 test, cihaz gerekmez
    flutter analyze
    flutter run -d <cihaz>       # gerçek Android telefon önerilir
    flutter build apk --release

## Mimari

    lib/src/domain/       Saf mantık: kural modeli ve alarm zamanı üretimi
    lib/src/data/         Drift veritabanı ve kural dönüşümleri
    lib/src/scheduler/    İşletim sistemine alarm kuran katman
    lib/src/platform/     Zil sesi seçici ve ana ekran widget köprüsü
    lib/src/features/     Arayüz (alarm, dünya saati, zamanlayıcı, kronometre)

## Widget ve simge

Ana ekran widget'ında saat **`TextClock`** ile gösteriliyor: Android'in kendi
bileşeni, sistem güncelliyor, uygulamanın arka planda çalışması gerekmiyor.
Uygulamadan beslenen tek alan "sıradaki alarm" satırı.

**Uygulama simgesi canlı saat gösteremez.** Android üçüncü parti uygulamalara
dinamik başlatıcı simgesi API'si vermiyor; stok Saat uygulamasındaki akan
simge, başlatıcının o uygulamaya özel muamelesi. Canlı saat isteğinin karşılığı
widget.

### Neden kural ve alarm ayrı tablolarda

`Rules` kullanıcının tanımını tutar, `ScheduledAlarms` ondan üretilmiş tek tek
alarmları. Kullanıcı *kuralı* düzenler, işletim sistemi *alarmları* ister.
İkisini ayırmak, "bitişi 08:30 yap" dendiğinde eski alarmları iptal edip
yenilerini üretmeyi tek bir işleme indirir.

### Neden kayan pencere

iOS'ta AlarmKit'in uygulama başına açıklanmamış bir alarm limiti var; aşılınca
`maximumLimitReached` döner. "Her gün 08:00–08:20 arası 2 dakikada bir" yılda
~4000 alarm demek, hepsi kurulamaz.

Bu yüzden kural başına en fazla 15, tüm kurallar toplamında 50 alarm kurulu
tutulur (`AlarmSyncService`). Alarm çaldıkça pencere ileri kaydırılır.

### Sessiz durmaya karşı iki koruma

Alarm uygulamasında en kötü hata, kullanıcının ancak uyanamadığında fark ettiği
hatadır. İki yerde önlem var:

1. **Uygulama kapalıyken çalan alarmlar.** `AlarmPlus.events` yalnızca uygulama
   çalışırken olay verir. Açılışta geçmişte kalmış `pending` alarmlar tespit
   edilip pencere telafi edilir (`main.dart`, `_reconcile`).
2. **Eksik izinler.** Bildirim veya kesin alarm izni yoksa liste başında uyarı
   çıkar; alarm sessizce kurulmuş sayılmaz.

### Saat hesabı

Saatler gün başından itibaren dakika olarak tutulur ve alarm zamanları
`Duration` eklenerek değil `DateTime` kurucusuyla üretilir. `Duration`
kullanılsaydı yaz saati geçişinde alarmlar bir saat kayardı; kurucu duvar
saatini korur. Gece yarısını aşan pencereler (23:50 → 00:10) desteklenir.

## Bilinen durum

- **iOS henüz yapılandırılmadı.** Android öncelikli ilerlendi. iOS için Xcode,
  CocoaPods ve `Info.plist` içine `NSAlarmKitUsageDescription` gerekiyor.
- **`third_party/alarm_plus`** yamalı bir kopya; gerekçesi
  [third_party/README.md](third_party/README.md).
- Release APK tüm işlemci mimarilerini içerdiği için ~59 MB.
  `--split-per-abi` ile telefona giden paket belirgin şekilde küçülür.

## Yayın imzası

Depoda imza anahtarı **yoktur** ve olmamalıdır. `android/key.properties` ve
`*.jks` dosyaları `.gitignore` ile dışarıda tutulur.

Yayın paketi üretmek için `android/key.properties` dosyasını şu biçimde
oluşturmak gerekir:

    storePassword=...
    keyPassword=...
    keyAlias=...
    storeFile=<anahtar-dosyasi>.jks

Bu dosya yoksa release derlemesi debug anahtarıyla imzalanır; böyle bir paket
Google Play'e yüklenemez ama yerel denemeler için çalışır.

## store/ klasörü

Google Play için hazırlanmış materyaller: mağaza metinleri, simge, öne çıkan
görsel, ekran görüntüleri, gizlilik politikası ve izin beyanı için çekilmiş
tanıtım videosu.
