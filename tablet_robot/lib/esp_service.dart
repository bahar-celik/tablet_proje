// ============================================================
// ESP8266 ROBOT KARTLARI İLE YEREL AĞ ÜZERİNDEN HABERLEŞME
// ============================================================
//
// Mimari: Tablet ve tüm ESP8266 kartları (robot1, robot2, ...) aynı
// modeme/routera bağlıdır. Modem komutları yönlendirmez; o sadece
// ortak ağı sağlar. Tablet, seçili robotun yerel IP adresine HTTP
// istekleri atarak DOĞRUDAN konuşur.
//
// Buradaki uç nokta adları, kullanıcının ESP8266 kartına yüklediği
// GERÇEK firmware'in (esp8266.ino) protokolüyle birebir eşleşecek
// şekilde yazılmıştır:
//   GET /manuel/ileri | /manuel/geri | /manuel/sol | /manuel/sag | /manuel/dur
//   GET /led-islem?durum=ac|kapat&renk=kirmizi|yesil|mavi
//   GET /bekle?sure=<ms>
//   GET /bip            (kısa bip)
//   GET /ses-cal        (3 vuruşluk melodi)
//   GET /mesafe         (cm cinsinden mesafe; aynı zamanda "kart canlı mı" testi için kullanılır)
//   GET /engel          ("var" / "yok")
//
// "İleri git 2 saniye" gibi kullanıcının seçtiği süreyi uygulayabilmek
// için /ileri, /geri, /sol, /sag gibi kendi içinde sabit 1 saniye bekleyen
// uç noktalar KULLANILMIYOR; bunun yerine /manuel/* ile hareket başlatılıp
// istenen süre kadar beklenip /manuel/dur ile durduruluyor.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

// Kullanıcının IP/host alanına yanlışlıkla "http://" öneki, sonuna "/"
// veya baştan/sondan boşluk eklemesi gibi yaygın hataları temizler.
// Böylece "http://192.168.1.48" gibi bir giriş, "http://http://..."
// şeklinde bozuk bir adrese dönüşüp sessizce başarısız olmaz.
String sanitizeHost(String input) {
  var value = input.trim();
  value = value.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value.trim();
}

// ------------------------------------------------------------
// ROBOT KAYDI (isim + IP, cihazda yerel olarak saklanır)
// ------------------------------------------------------------

class RobotDevice {
  final String id;
  final String name;
  final String ip;

  const RobotDevice({
    required this.id,
    required this.name,
    required this.ip,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'ip': ip};

  factory RobotDevice.fromJson(Map<String, dynamic> json) => RobotDevice(
        id: json['id'] as String,
        name: json['name'] as String,
        ip: json['ip'] as String,
      );
}

class RobotService {
  static const _robotsKey = 'robots_v1';
  static const _activeIdKey = 'active_robot_id_v1';

  static Future<List<RobotDevice>> listRobots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_robotsKey) ?? [];
    return raw
        .map((s) => RobotDevice.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _writeAll(List<RobotDevice> robots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _robotsKey,
      robots.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  static Future<RobotDevice> addRobot(String name, String ip) async {
    final robots = await listRobots();
    final robot = RobotDevice(
      id: 'robot_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      ip: ip,
    );
    robots.add(robot);
    await _writeAll(robots);
    final active = await getActiveRobotId();
    if (active == null) {
      await setActiveRobotId(robot.id);
    }
    return robot;
  }

  static Future<void> updateRobot(String id, String name, String ip) async {
    final robots = await listRobots();
    final idx = robots.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    robots[idx] = RobotDevice(id: id, name: name, ip: ip);
    await _writeAll(robots);
  }

  static Future<void> deleteRobot(String id) async {
    final robots = await listRobots();
    robots.removeWhere((r) => r.id == id);
    await _writeAll(robots);
    if (await getActiveRobotId() == id) {
      await setActiveRobotId(robots.isEmpty ? null : robots.first.id);
    }
  }

  static Future<String?> getActiveRobotId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeIdKey);
  }

  static Future<void> setActiveRobotId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_activeIdKey);
    } else {
      await prefs.setString(_activeIdKey, id);
    }
  }

  static Future<RobotDevice?> getActiveRobot() async {
    final id = await getActiveRobotId();
    if (id == null) return null;
    final robots = await listRobots();
    for (final r in robots) {
      if (r.id == id) return r;
    }
    return null;
  }
}

// ------------------------------------------------------------
// ESP8266 HTTP İSTEMCİSİ
// ------------------------------------------------------------

class EspService {
  static const Duration _timeout = Duration(seconds: 3);

  static Uri _uri(String ip, String path, [Map<String, String>? query]) =>
      Uri.http(sanitizeHost(ip), path, query);

  static Future<bool> _getOk(
    String ip,
    String path, {
    Map<String, String>? query,
    Duration? timeout,
  }) async {
    try {
      final res = await http.get(_uri(ip, path, query)).timeout(timeout ?? _timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Kart canlı mı testi: /status yok, bu yüzden zararsız ve her zaman
  // var olan /mesafe uç noktasını kullanıyoruz.
  static Future<bool> ping(String ip) => _getOk(ip, '/mesafe');

  // Manuel kontrol (basılı tut / bırak): yön tuşuna basınca "forward" vb.,
  // bırakınca "stop" gönderilir — doğrudan /manuel/* uç noktalarına denk gelir.
  static Future<bool> sendCommand(String ip, String command) {
    switch (command) {
      case 'forward':
        return _getOk(ip, '/manuel/ileri');
      case 'backward':
        return _getOk(ip, '/manuel/geri');
      case 'left':
        return _getOk(ip, '/manuel/sol');
      case 'right':
        return _getOk(ip, '/manuel/sag');
      default:
        return _getOk(ip, '/manuel/dur');
    }
  }

  // Donanımda tek renkli 3 ayrı LED (kırmızı/yeşil/mavi) var, karışık RGB
  // yok. colorHex verilmezse (düz "LED Aç"/"LED Kapat") üç LED'i de
  // sırayla açıp kapatıyoruz; colorHex verilmişse en baskın renk kanalına
  // en yakın LED seçiliyor.
  static Future<bool> sendLed(String ip, {required bool on, String? colorHex}) async {
    final durum = on ? 'ac' : 'kapat';
    final renk = _nearestLedColor(colorHex);
    if (renk != null) {
      return _getOk(ip, '/led-islem', query: {'durum': durum, 'renk': renk});
    }
    var allOk = true;
    for (final c in ['kirmizi', 'yesil', 'mavi']) {
      final ok = await _getOk(ip, '/led-islem', query: {'durum': durum, 'renk': c});
      allOk = allOk && ok;
    }
    return allOk;
  }

  static String? _nearestLedColor(String? hex) {
    if (hex == null || hex.length < 6) return null;
    final r = int.tryParse(hex.substring(0, 2), radix: 16) ?? 0;
    final g = int.tryParse(hex.substring(2, 4), radix: 16) ?? 0;
    final b = int.tryParse(hex.substring(4, 6), radix: 16) ?? 0;
    if (r >= g && r >= b) return 'kirmizi';
    if (g >= r && g >= b) return 'yesil';
    return 'mavi';
  }

  static Future<bool> sendBuzzer(String ip, {int durationMs = 300}) => _getOk(ip, '/bip');

  static Future<bool> stop(String ip) => _getOk(ip, '/manuel/dur');

  // Programı tek seferde büyük bir JSON olarak GÖNDERMÜYORUZ — kartta
  // böyle bir uç nokta yok. Bunun yerine her derlenmiş komutu kendi HTTP
  // isteğiyle, sırayla ve bir öncekinin bitmesini bekleyerek çalıştırıyoruz.
  static Future<bool> sendProgram(String ip, List<RobotBlockData> blocks) async {
    final program = compileBlocksToProgram(blocks);
    for (final command in program) {
      final ok = await _runSingleCommand(ip, command);
      if (!ok) return false;
    }
    return true;
  }

  static Future<bool> _runSingleCommand(String ip, Map<String, dynamic> command) async {
    final duration = command['duration'] as int? ?? 1000;
    switch (command['type']) {
      case 'move':
        final path = command['direction'] == 'backward' ? '/manuel/geri' : '/manuel/ileri';
        return _timedMove(ip, path, duration);
      case 'turn':
        final path = command['direction'] == 'right' ? '/manuel/sag' : '/manuel/sol';
        return _timedMove(ip, path, duration);
      case 'stop':
        return _getOk(ip, '/manuel/dur');
      case 'wait':
        // /bekle kart tarafında "sure" ms boyunca beklendikten sonra
        // cevap döner; bu yüzden zaman aşımını süreye göre genişletiyoruz.
        return _getOk(
          ip,
          '/bekle',
          query: {'sure': '$duration'},
          timeout: Duration(milliseconds: duration + 3000),
        );
      case 'led':
        return sendLed(ip, on: command['state'] != 'off', colorHex: command['color'] as String?);
      case 'buzzer':
        return _getOk(ip, '/bip');
      default:
        return true;
    }
  }

  // Hareketi başlatır, tablet tarafında istenen süre kadar bekler, sonra
  // durdurur — böylece bloktaki "kaç saniye" değeri gerçekten uygulanır
  // (kartın kendi /ileri gibi uç noktaları her zaman sabit 1 saniye sürer).
  static Future<bool> _timedMove(String ip, String startPath, int durationMs) async {
    final started = await _getOk(ip, startPath);
    if (!started) return false;
    await Future.delayed(Duration(milliseconds: durationMs));
    return _getOk(ip, '/manuel/dur');
  }
}

// ------------------------------------------------------------
// BLOK PROGRAMINI JSON KOMUT LİSTESİNE ÇEVİRME
// ------------------------------------------------------------
//
// "Tekrarla" blokları, ilk sürümde ESP firmware'ini basit tutmak için
// derleme anında açılır (unroll edilir). "Sürekli tekrarla", "Eğer" ve
// olay blokları henüz desteklenmiyor (asamalar.txt'deki ileri aşama
// planına göre bu bloklar sonraki sürümde eklenecek) — program
// derlenirken bu bloklar şimdilik atlanır.

List<Map<String, dynamic>> compileBlocksToProgram(List<RobotBlockData> blocks) {
  final result = <Map<String, dynamic>>[];
  for (final block in blocks) {
    if (block.type == BlockType.repeat) {
      final count = int.tryParse(block.value ?? '10') ?? 10;
      final inner = compileBlocksToProgram(block.children);
      for (var i = 0; i < count; i++) {
        result.addAll(inner);
      }
      continue;
    }
    if (block.type == BlockType.forever ||
        block.type == BlockType.ifBlock ||
        block.type == BlockType.ifElse ||
        block.type == BlockType.event) {
      // Henüz desteklenmiyor: sonraki aşamada eklenecek.
      continue;
    }
    final command = _blockToCommand(block);
    if (command != null) result.add(command);
  }
  return result;
}

Map<String, dynamic>? _blockToCommand(RobotBlockData block) {
  final seconds = double.tryParse(block.value ?? '') ?? 1;
  final durationMs = (seconds * 1000).round();

  switch (block.type) {
    case BlockType.move:
      return {
        'type': 'move',
        'direction': block.label == 'Geri git' ? 'backward' : 'forward',
        'duration': durationMs,
      };
    case BlockType.turn:
      return {
        'type': 'turn',
        'direction': block.label == 'Sağa dön' ? 'right' : 'left',
        'duration': durationMs,
      };
    case BlockType.stop:
      return {'type': 'stop'};
    case BlockType.wait:
      return {'type': 'wait', 'duration': durationMs};
    case BlockType.led:
      if (block.label == 'LED Aç') return {'type': 'led', 'state': 'on'};
      if (block.label == 'LED Kapat') return {'type': 'led', 'state': 'off'};
      if (block.label == 'LED Rengi') {
        return {'type': 'led', 'state': 'on', 'color': block.value ?? 'FFFFFF'};
      }
      return null;
    case BlockType.sound:
      return {'type': 'buzzer', 'duration': durationMs};
    default:
      return null;
  }
}
