// ============================================================
// ROBOTKOD - ESP8266 ROBOT KARTI FIRMWARE (BAŞLANGIÇ SÜRÜMÜ)
// ============================================================
//
// Bu kod her robot kartına (robot1, robot2, ...) AYRI AYRI, sadece
// WIFI_SSID / WIFI_PASSWORD / ROBOT_NAME değerlerini değiştirerek
// yüklenir. Kart, evdeki/ofisteki mevcut modeme (router'a) normal bir
// Wi-Fi istemcisi gibi bağlanır (kendi erişim noktasını oluşturmaz).
// Tablet de aynı ağa bağlı olduğu için, tablet bu kartın yerel IP
// adresine doğrudan HTTP isteği atarak konuşur.
//
// GEREKLİ KÜTÜPHANELER (Arduino IDE > Kütüphane Yöneticisi'nden kurun):
//   - ESP8266WiFi      (ESP8266 board paketiyle birlikte gelir)
//   - ESP8266WebServer (ESP8266 board paketiyle birlikte gelir)
//   - ArduinoJson      (Benoit Blanchon) - sürüm 6.x
//
// KURULUM ADIMLARI:
//   1. Aşağıdaki "AYARLAR" bölümünü bu karta göre doldurun.
//   2. Router'ın yönetim panelinden bu kartın MAC adresine sabit bir
//      IP ayırın (DHCP rezervasyonu) — örn. robot1 için 192.168.1.101.
//      Bu yapılmazsa kart her açılışta farklı bir IP alabilir ve
//      tablet uygulamasındaki kayıtlı IP geçersiz kalır.
//   3. Kodu Arduino IDE ile karta yükleyin, Seri Port Monitörü'nden
//      (115200 baud) kartın aldığı IP adresini görüp tablet
//      uygulamasındaki "Robotlarım" ekranına o IP'yi girin.
//
// DESTEKLENEN UÇ NOKTALAR (tablet uygulamasının kullandığı):
//   GET  /status   -> kart canlı mı / adı nedir
//   POST /command  -> tek bir anlık komut  {"command":"forward", ...}
//   POST /program  -> blok programından derlenmiş komut dizisi
//   POST /stop     -> motorları ve her şeyi acil durdur

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// ------------------------------------------------------------
// AYARLAR (HER KART İÇİN BU BÖLÜMÜ DEĞİŞTİRİN)
// ------------------------------------------------------------

const char *WIFI_SSID = "EvWifi";          // Modeminizin Wi-Fi adı
const char *WIFI_PASSWORD = "sifre12345";  // Modeminizin Wi-Fi şifresi
const char *ROBOT_NAME = "robot1";          // Bu karta verdiğiniz isim

// Motor sürücü pinleri (L298N / L9110 gibi tipik bir sürücü için
// örnek pin ataması — kendi bağlantınıza göre güncelleyin).
const int PIN_MOTOR_LEFT_FWD = D1;
const int PIN_MOTOR_LEFT_BWD = D2;
const int PIN_MOTOR_RIGHT_FWD = D3;
const int PIN_MOTOR_RIGHT_BWD = D4;

const int PIN_LED = D5;
const int PIN_BUZZER = D6;

// ------------------------------------------------------------

ESP8266WebServer server(80);

// Acil durdurma / yeni bir komut geldiğinde devam eden programı
// kesmek için kullanılan bayrak.
volatile bool stopRequested = false;

void motorsStop() {
  digitalWrite(PIN_MOTOR_LEFT_FWD, LOW);
  digitalWrite(PIN_MOTOR_LEFT_BWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_FWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_BWD, LOW);
}

void motorsForward() {
  digitalWrite(PIN_MOTOR_LEFT_FWD, HIGH);
  digitalWrite(PIN_MOTOR_LEFT_BWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_FWD, HIGH);
  digitalWrite(PIN_MOTOR_RIGHT_BWD, LOW);
}

void motorsBackward() {
  digitalWrite(PIN_MOTOR_LEFT_FWD, LOW);
  digitalWrite(PIN_MOTOR_LEFT_BWD, HIGH);
  digitalWrite(PIN_MOTOR_RIGHT_FWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_BWD, HIGH);
}

void motorsTurnLeft() {
  digitalWrite(PIN_MOTOR_LEFT_FWD, LOW);
  digitalWrite(PIN_MOTOR_LEFT_BWD, HIGH);
  digitalWrite(PIN_MOTOR_RIGHT_FWD, HIGH);
  digitalWrite(PIN_MOTOR_RIGHT_BWD, LOW);
}

void motorsTurnRight() {
  digitalWrite(PIN_MOTOR_LEFT_FWD, HIGH);
  digitalWrite(PIN_MOTOR_LEFT_BWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_FWD, LOW);
  digitalWrite(PIN_MOTOR_RIGHT_BWD, HIGH);
}

// Belirli bir süre bekler, ancak bu sırada /stop isteği gelirse
// (stopRequested bayrağı ile) bekleme hemen kesilir. Bu sayede uzun
// bir program çalışırken acil durdur anında etkili olur.
void waitInterruptible(unsigned long durationMs) {
  unsigned long start = millis();
  while (millis() - start < durationMs) {
    if (stopRequested) break;
    server.handleClient();
    delay(5);
  }
}

void setLed(bool on) {
  digitalWrite(PIN_LED, on ? HIGH : LOW);
}

void buzz(unsigned long durationMs) {
  digitalWrite(PIN_BUZZER, HIGH);
  waitInterruptible(durationMs);
  digitalWrite(PIN_BUZZER, LOW);
}

// ------------------------------------------------------------
// TEK BİR KOMUTU ÇALIŞTIRIR (hem /command hem /program bunu kullanır)
// ------------------------------------------------------------

void runCommand(const JsonVariantConst &cmd) {
  if (stopRequested) return;

  const char *type = cmd["type"] | cmd["command"] | "";

  if (strcmp(type, "move") == 0 || strcmp(type, "forward") == 0 || strcmp(type, "backward") == 0) {
    const char *direction = cmd["direction"] | type;
    unsigned long duration = cmd["duration"] | 1000;
    if (strcmp(direction, "backward") == 0) {
      motorsBackward();
    } else {
      motorsForward();
    }
    waitInterruptible(duration);
    motorsStop();
  } else if (strcmp(type, "turn") == 0 || strcmp(type, "left") == 0 || strcmp(type, "right") == 0) {
    const char *direction = cmd["direction"] | type;
    unsigned long duration = cmd["duration"] | 500;
    if (strcmp(direction, "right") == 0) {
      motorsTurnRight();
    } else {
      motorsTurnLeft();
    }
    waitInterruptible(duration);
    motorsStop();
  } else if (strcmp(type, "stop") == 0) {
    motorsStop();
  } else if (strcmp(type, "wait") == 0) {
    unsigned long duration = cmd["duration"] | 1000;
    waitInterruptible(duration);
  } else if (strcmp(type, "led") == 0 || strcmp(type, "led_on") == 0 || strcmp(type, "led_off") == 0) {
    const char *state = cmd["state"] | (strcmp(type, "led_off") == 0 ? "off" : "on");
    setLed(strcmp(state, "on") == 0);
    // Not: Tek renkli LED için "color" alanı şimdilik kullanılmıyor.
    // RGB LED varsa buraya renk çözme eklenebilir.
  } else if (strcmp(type, "buzzer") == 0) {
    unsigned long duration = cmd["duration"] | 300;
    buzz(duration);
  }
}

// ------------------------------------------------------------
// HTTP UÇ NOKTALARI
// ------------------------------------------------------------

void sendJsonSuccess(const char *message) {
  StaticJsonDocument<128> doc;
  doc["success"] = true;
  doc["message"] = message;
  String out;
  serializeJson(doc, out);
  server.send(200, "application/json", out);
}

void handleStatus() {
  StaticJsonDocument<192> doc;
  doc["success"] = true;
  doc["connected"] = true;
  doc["name"] = ROBOT_NAME;
  doc["ip"] = WiFi.localIP().toString();
  String out;
  serializeJson(doc, out);
  server.send(200, "application/json", out);
}

void handleCommand() {
  stopRequested = false;

  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"success\":false,\"message\":\"Govde bos\"}");
    return;
  }

  StaticJsonDocument<256> doc;
  DeserializationError err = deserializeJson(doc, server.arg("plain"));
  if (err) {
    server.send(400, "application/json", "{\"success\":false,\"message\":\"JSON hatali\"}");
    return;
  }

  runCommand(doc.as<JsonVariantConst>());
  sendJsonSuccess("Komut calistirildi");
}

void handleProgram() {
  stopRequested = false;

  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"success\":false,\"message\":\"Govde bos\"}");
    return;
  }

  // Not: Program listesi uzun olabileceği için daha büyük bir buffer
  // kullanıyoruz. Çok uzun programlarda bu değeri artırmanız gerekebilir.
  DynamicJsonDocument doc(4096);
  DeserializationError err = deserializeJson(doc, server.arg("plain"));
  if (err) {
    server.send(400, "application/json", "{\"success\":false,\"message\":\"JSON hatali\"}");
    return;
  }

  // Tablet isteği beklemesin diye hemen "alındı" cevabı gönderiyoruz,
  // ardından programı sırayla çalıştırıyoruz.
  sendJsonSuccess("Program alindi");

  JsonArrayConst program = doc["program"].as<JsonArrayConst>();
  for (JsonVariantConst cmd : program) {
    if (stopRequested) break;
    runCommand(cmd);
  }
  motorsStop();
}

void handleStop() {
  stopRequested = true;
  motorsStop();
  digitalWrite(PIN_BUZZER, LOW);
  sendJsonSuccess("Robot durduruldu");
}

void handleNotFound() {
  server.send(404, "application/json", "{\"success\":false,\"message\":\"Bulunamadi\"}");
}

// ------------------------------------------------------------

void setup() {
  Serial.begin(115200);
  delay(200);

  pinMode(PIN_MOTOR_LEFT_FWD, OUTPUT);
  pinMode(PIN_MOTOR_LEFT_BWD, OUTPUT);
  pinMode(PIN_MOTOR_RIGHT_FWD, OUTPUT);
  pinMode(PIN_MOTOR_RIGHT_BWD, OUTPUT);
  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  motorsStop();

  Serial.println();
  Serial.print("[" );
  Serial.print(ROBOT_NAME);
  Serial.print("] Wi-Fi'ye baglaniliyor: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(400);
    Serial.print(".");
  }

  Serial.println();
  Serial.print("Baglandi! IP adresi: ");
  Serial.println(WiFi.localIP());
  Serial.println("Bu IP adresini tablet uygulamasindaki 'Robotlarim' ekranina girin.");

  server.on("/status", HTTP_GET, handleStatus);
  server.on("/command", HTTP_POST, handleCommand);
  server.on("/program", HTTP_POST, handleProgram);
  server.on("/stop", HTTP_POST, handleStop);
  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP sunucusu baslatildi (port 80).");
}

void loop() {
  server.handleClient();
}
