# RobotKod

Tablet üzerinde çalışan, kullanıcıların blokları sürükleyip birleştirerek
robot programları oluşturabildiği bir uygulama. Uygulama ESP8266 tabanlı
robot kartlarıyla (robot1, robot2, ...) aynı yerel Wi-Fi ağı üzerinden
doğrudan HTTP ile haberleşir.

## Mimari

```
              [Modem / Router]
         (tek Wi-Fi ağı, ör. "EvWifi")
          /          |            \
     Tablet       ESP "robot1"   ESP "robot2"
   (RobotKod)    192.168.1.48    192.168.1.49
```

- Modem/router komutları yönlendirmez, sadece ortak ağı sağlar.
- Her ESP8266 kartı, kendi erişim noktasını oluşturmak yerine mevcut
  Wi-Fi ağına istemci olarak bağlanır.
- Tablet, "Robotlarım" ekranında kayıtlı robotlardan birini "aktif
  robot" seçer ve onun yerel IP adresine doğrudan HTTP istekleri
  (`GET`/`POST`) atar.

## Depo yapısı

| Yol | Açıklama |
|---|---|
| `tablet_robot/` | Flutter tablet uygulaması (RobotKod) |
| `esp8266_firmware/` | ESP8266 kartları için örnek/başlangıç Arduino firmware'i ve kurulum rehberi |
| `asamalar.txt` | Projenin orijinal teknik tasarım ve geliştirme planı |
| `referansGörsel.png` | Arayüz tasarımı için referans görsel |

## Tablet uygulaması (`tablet_robot/`)

Flutter ile yazılmıştır. Başlıca ekranlar:

- **Programla** — blok tabanlı program editörü (sürükle-bırak, iç içe
  döngü/koşul blokları, kaydet/çalıştır/durdur).
- **Kontrol Et** — robotu blok kullanmadan manuel yön tuşlarıyla
  kontrol etme, LED ve buzzer kontrolleri.
- **Projeler** — oluşturulan blok programlarını cihazda yerel olarak
  kaydetme, açma, silme.
- **Robotlarım** — ESP8266 kartlarını isim + IP adresiyle kaydetme,
  aralarından birini aktif robot olarak seçme, bağlantı testi.
- **Ayarlar** — uygulama ve robot bağlantı bilgileri özeti.

### Gereksinimler

- Flutter SDK (bkz. `tablet_robot/pubspec.yaml` için Dart SDK sürümü)
- Android SDK / Android Studio veya bağlı bir Android tablet

### Çalıştırma

```bash
cd tablet_robot
flutter pub get
flutter run
```

### Release APK oluşturma

```bash
cd tablet_robot
flutter build apk --release
# Çıktı: tablet_robot/build/app/outputs/flutter-apk/app-release.apk
```

### Veri saklama

Projeler ve robot kayıtları (`shared_preferences` ile) cihazda yerel
olarak saklanır; herhangi bir sunucuya gönderilmez.

## ESP8266 firmware (`esp8266_firmware/`)

Her robot kartına ayrı ayrı yüklenecek Arduino kodu ve kurulum
rehberi için `esp8266_firmware/README.md` dosyasına bakın. Özetle:

- Kart, modeme istemci (station) modunda bağlanır.
- HTTP sunucusu üzerinden hareket, LED, buzzer ve mesafe sensörü uç
  noktalarını sunar.
- Tablet uygulaması, çalışma alanındaki blokları bu uç noktalara
  sırayla HTTP isteği göndererek çalıştırır.

> Not: Tablet uygulamasındaki `EspService`, projede kullanılan gerçek
> firmware'in uç nokta adlarıyla (`/manuel/*`, `/led-islem`, `/bekle`,
> `/bip`, `/mesafe` vb.) birebir eşleşecek şekilde yazılmıştır.
> `esp8266_firmware/robot_firmware/robot_firmware.ino` bu depoda
> referans/başlangıç amaçlı bulunan ayrı bir örnektir — kartlarınızda
> çalışan firmware'den farklıysa, `tablet_robot/lib/esp_service.dart`
> dosyasındaki uç nokta adlarını kendi firmware'inize göre güncelleyin.

## Mevcut durum ve sınırlamalar

- Hareket, dur, bekle, LED, buzzer blokları ve "Tekrarla" döngüsü
  (derleme anında açılır/unroll edilir) destekleniyor.
- "Sürekli tekrarla", "Eğer / Değilse" ve sensöre bağlı koşullu
  bloklar henüz çalışma zamanında desteklenmiyor (planlanan sonraki
  aşama — bkz. `asamalar.txt`).
- Robotlar arası iletişim mDNS (`.local`) yerine sabit/yerel ağ IP
  adresiyle yapılır; Android'de mDNS çözümlemesi güvenilir
  olmadığından bu tercih edilmiştir.
