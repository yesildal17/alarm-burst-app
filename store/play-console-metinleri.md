# Play Console — kopyala-yapıştır metinleri

## Mağaza kaydı

**Uygulama adı** (30 karakter sınırı)
```
Alarm Burst
```

**Kısa açıklama** (80 karakter sınırı)
```
Bir saat aralığında arka arkaya alarm kur. Tek alarmla uyanamayanlar için.
```

**Tam açıklama** (4000 karakter sınırı)
```
Alarm Burst, tek bir alarmla uyanamayanlar için tasarlandı.

Bir saat aralığı ve sıklık seç: "08:00 ile 08:20 arası 2 dakikada bir"
dediğinde uygulama senin yerine 11 alarm kurar. Hepsini tek tek ayarlamak
zorunda kalmazsın.

ÖZELLİKLER

• Aralıklı alarm dizisi — bir saat aralığında belirlediğin sıklıkta alarm
• Tek alarm — klasik alarm saati gibi
• Haftanın günlerine göre tekrar
• Kaydetmeden önce canlı önizleme: hangi saatlerde çalacağını görürsün
• Telefonundaki zil seslerinden seçim
• Titreşim ve erteleme süresi ayarları
• Telefon kilitliyken tam ekran alarm
• Dünya saati, zamanlayıcı ve kronometre
• Ana ekran widget'ı — saat ve sıradaki alarm
• Açık ve karanlık mod

GİZLİLİK

Alarm Burst hiçbir veri toplamaz. İnternet erişim izni dahi yoktur.
Alarmların ve ayarların yalnızca telefonunda durur.
```

**Kategori:** Araçlar
**Etiketler:** alarm, saat, zamanlayıcı, kronometre

---

## Uygulama içeriği

**Gizlilik politikası URL'si**
```
https://yesildal17.github.io/alarm-burst/
```

**Uygulama erişimi:** Tüm işlevler kısıtlama olmadan kullanılabilir
**Reklamlar:** Hayır, uygulamam reklam içermiyor
**İçerik derecelendirmesi:** Anketteki tüm sorulara "Hayır" → 3+ çıkar
**Hedef kitle:** 18 ve üzeri (çocuklara yönelik değil)
**Devlet uygulaması:** Hayır

**Veri güvenliği:** "Uygulamam kullanıcı verisi toplamıyor veya paylaşmıyor"
(Release manifestinde INTERNET izni yok — doğrulandı.)

---

## İzin beyanları

`SCHEDULE_EXACT_ALARM` ve `USE_FULL_SCREEN_INTENT` için gerekçe:

```
Uygulamanın çekirdek işlevi alarm saatidir. Kullanıcının belirlediği
dakikada alarmın çalabilmesi için kesin alarm izni, telefon kilitliyken
alarm ekranının açılabilmesi için tam ekran bildirim izni gereklidir.
Bu izinler başka hiçbir amaçla kullanılmaz.
```

---

## Görseller

| Dosya | Nerede kullanılır |
|---|---|
| `store/play_icon_512.png` | Uygulama simgesi (512×512) |
| `store/feature_graphic_1024x500.png` | Öne çıkan görsel |
| — | Telefon ekran görüntüleri (en az 2) — henüz alınmadı |

---

## Varsayılan giriş — İngilizce (en-US)

Uygulama oluşturulurken varsayılan dil en-US seçilmiş ve bu sonradan
değiştirilemiyor. Varsayılan girişi İngilizce doldur, Türkçe'yi
"Çeviriler" bölümünden ekle.

**App name** (30 karakter)
```
Alarm Burst
```

**Short description** (80 karakter)
```
Set a burst of alarms across a time range. For people one alarm never wakes.
```

**Full description** (4000 karakter)
```
Alarm Burst is built for people that a single alarm never wakes up.

Pick a time range and an interval. Say "every 2 minutes between 08:00
and 08:20" and the app sets all 11 alarms for you. No more adding them
one by one.

FEATURES

• Interval alarms — a series of alarms across a time range
• Single alarm — works like a regular alarm clock too
• Repeat on selected weekdays
• Live preview before you save: see exactly which alarms will ring
• Pick any ringtone already on your phone
• Vibration and snooze settings
• Full screen alarm while the phone is locked
• World clock, timer and stopwatch
• Home screen widget with the clock and your next alarm
• Light and dark theme

PRIVACY

Alarm Burst collects no data at all. It does not even request internet
permission. Your alarms and settings stay on your phone.
```

**Category:** Tools
**Tags:** alarm, clock, timer, stopwatch
