# RobotKod — ESP8266 Firmware

Bu klasördeki `robot_firmware/robot_firmware.ino` dosyası, her robot kartına
(robot1, robot2, ...) ayrı ayrı yüklenecek Arduino kodudur.

## Mimari

```
          [Modem / Router]
        (tek Wi-Fi ağı: EvWifi)
         /          |          \
    Tablet       ESP "robot1"  ESP "robot2"
  (RobotKod)    192.168.1.101  192.168.1.102
```

- Modem komutları yönlendirmez — sadece ortak ağı sağlar.
- Tablet, seçtiği robotun IP adresine HTTP isteği atarak **doğrudan** konuşur.
- Her ESP kartı modeme normal bir Wi-Fi istemcisi gibi bağlanır (kendi erişim
  noktasını oluşturmaz).

## Kurulum

1. **Arduino IDE hazırlığı**
   - Dosya > Tercihler > "Ek Kart Yöneticisi URL'leri" kısmına şunu ekleyin:
     `https://arduino.esp8266.com/stable/package_esp8266com_index.json`
   - Araçlar > Kart > Kart Yöneticisi'nden **esp8266** paketini kurun.
   - Kütüphane Yöneticisi'nden **ArduinoJson** (Benoit Blanchon, 6.x) kütüphanesini kurun.

2. **Her kart için kodu düzenleyin**
   `robot_firmware.ino` dosyasının başındaki AYARLAR bölümünü doldurun:
   ```cpp
   const char *WIFI_SSID = "EvWifi";
   const char *WIFI_PASSWORD = "sifre12345";
   const char *ROBOT_NAME = "robot1";   // robot2, robot3... için değiştirin
   ```
   Motor sürücü pinlerini de kendi bağlantınıza göre güncelleyin (`PIN_MOTOR_*`).

3. **Sabit IP ayarlayın (önemli)**
   Router'ın yönetim paneline girip (genelde `192.168.1.1` veya `192.168.0.1`)
   her ESP kartının MAC adresine sabit bir IP ayırın (DHCP rezervasyonu).
   Bu yapılmazsa kart her açılışta farklı IP alabilir ve tablet
   uygulamasındaki kayıtlı adres geçersiz kalır.

4. **Yükleyin**
   Kartı USB ile bağlayın, doğru board'u seçin (ör. "NodeMCU 1.0 (ESP-12E Module)"),
   yükleyin. Seri Port Monitörü'nü (115200 baud) açarak kartın aldığı IP
   adresini görün.

5. **Tablet uygulamasında ekleyin**
   RobotKod uygulamasında Ayarlar > Robotları Yönet (veya Programla ekranındaki
   "Robot Seç") üzerinden robotun adını ve bu IP adresini girin.

## HTTP Protokolü

| Uç nokta        | Yöntem | Açıklama                                  |
|------------------|--------|--------------------------------------------|
| `/status`        | GET    | Kart canlı mı, adı ve IP'si                |
| `/command`       | POST   | Tek bir anlık komut                        |
| `/program`       | POST   | Blok programından derlenmiş komut dizisi   |
| `/stop`          | POST   | Her şeyi acil durdurur                     |

Örnek `/command` gövdesi:
```json
{"command": "forward"}
```

Örnek `/program` gövdesi:
```json
{
  "program": [
    {"type": "move", "direction": "forward", "duration": 2000},
    {"type": "turn", "direction": "right", "duration": 700},
    {"type": "wait", "duration": 1000},
    {"type": "led", "state": "on"},
    {"type": "buzzer", "duration": 300},
    {"type": "stop"}
  ]
}
```

## Şu an desteklenmeyenler (sonraki aşama)

Tablet tarafındaki blok derleyicisi (`compileBlocksToProgram`), "Tekrarla"
bloklarını derleme anında açar (unroll eder), ancak "Sürekli tekrarla",
"Eğer / Değilse" ve sensör/olay bloklarını henüz desteklemiyor — bu bloklar
şimdilik atlanır. `asamalar.txt`'deki plana göre bunlar ileri aşamada
eklenecek (sensör okuma + koşullu dallanma firmware'e eklenmeli).
