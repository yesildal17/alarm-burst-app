# alarm_plus eklentisi yansıma (reflection) ile bildirim eylemlerini çözüyor;
# küçültme sırasında sınıfların korunması gerekiyor.
-keep class com.psb.alarm_plus.** { *; }

# Flutter'ın kendi kuralları zaten uygulanıyor; widget sağlayıcısı manifestten
# referanslandığı için korunmalı.
-keep class com.kadircevy.interval_alarm.** { *; }
