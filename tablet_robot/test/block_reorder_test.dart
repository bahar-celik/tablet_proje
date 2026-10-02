import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tablet_robot/main.dart';

RobotBlockData _block(String id, String label, BlockType type) => RobotBlockData(
      id: id,
      type: type,
      label: label,
      icon: Icons.circle,
      color: Colors.blue,
    );

List<String> _orderOnScreen(WidgetTester tester, List<String> labels) {
  final sorted = [...labels]
    ..sort((a, b) => tester.getCenter(find.text(a)).dy.compareTo(tester.getCenter(find.text(b)).dy));
  return sorted;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('çalışma alanındaki blok basılı tutulup yukarı/aşağı taşınabilir', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final labels = ['Birinci', 'LED Aç', 'Üçüncü'];
    await tester.pumpWidget(MaterialApp(
      home: ProgrammingScreen(initialBlocks: [
        _block('a', 'Birinci', BlockType.move),
        _block('b', 'LED Aç', BlockType.led),
        _block('c', 'Üçüncü', BlockType.wait),
      ]),
    ));
    await tester.pumpAndSettle();

    Future<void> dragLed(Offset to) async {
      final from = tester.getCenter(find.text('LED Aç'));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 400));
      // Birkaç adımda hareket et (gerçek parmak gibi).
      for (var i = 1; i <= 5; i++) {
        await gesture.moveTo(Offset.lerp(from, to, i / 5)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
    }

    // Yukarı: Birinci bloğun üst yarısına bırak.
    await dragLed(tester.getCenter(find.text('Birinci')) - const Offset(0, 8));
    expect(_orderOnScreen(tester, labels), ['LED Aç', 'Birinci', 'Üçüncü']);

    // Aşağı: Üçüncü bloğun alt yarısına bırak.
    await dragLed(tester.getCenter(find.text('Üçüncü')) + const Offset(0, 8));
    expect(_orderOnScreen(tester, labels), ['Birinci', 'Üçüncü', 'LED Aç']);
  });
}
