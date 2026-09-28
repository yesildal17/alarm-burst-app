# third_party

## alarm_plus (yamalı kopya, 0.2.0)

`alarm_plus` 0.2.0 yayınlanmış hâliyle Android'de **derlenmiyor**:
`android/src/main/kotlin/com/psb/alarm_plus/AlarmPlusPlugin.kt` içinde üç yerde
`_root_ide_package_.` öneki var. Bu, IntelliJ/Android Studio'nun otomatik import
tamamlarken eklediği bir IDE artefaktı; geçerli Kotlin değil ve şu hatayı verir:

    e: AlarmPlusPlugin.kt:53:22 Unresolved reference '_root_ide_package_'

Aynı hata bu paketin GitHub'daki `main` dalında da duruyor (kontrol: 2026-09-26),
yani git bağımlılığına geçmek de çözmüyor.

### Yama

Tek işlem: `_root_ide_package_.` önekinin silinmesi. Arkasındaki tam nitelikli
isimler (`com.psb.alarm_plus.data.AlarmRepository` vb.) zaten doğru.

    sed -i '' 's/_root_ide_package_\.//g' \
      android/src/main/kotlin/com/psb/alarm_plus/AlarmPlusPlugin.kt

### İkinci yama: sistem zil sesi desteği

`AlarmRingingService.kt` ses kaynağını yalnızca Flutter varlığı olarak
açabiliyordu (`flutterLoader.getLookupKeyForAsset`). Kullanıcının kendi zil
seslerinden seçebilmesi için `content://` ve `file://` URI'leri de kabul
edecek şekilde genişletildi; varlık yolu davranışı değişmedi.

Bu yama bir hata düzeltmesi değil, özellik eklemesi. Yukarı akış URI desteği
eklerse kaldırılabilir.

### Neden 0.1.3'e düşmedik

AlarmKit entegrasyonu (iOS 26+ gerçek sistem alarmı) 0.2.0'da geldi. iOS aşamasına
geçtiğimizde buna ihtiyacımız olacak, o yüzden 0.2.0'da kalıp yamalıyoruz.

### Ne zaman kaldırılır

Yukarı akış 0.2.1+ yayınlayıp hatayı düzelttiğinde: `pubspec.yaml` içindeki
`dependency_overrides` bloğu ve bu dizin silinir, `alarm_plus` sürümü yükseltilir.
