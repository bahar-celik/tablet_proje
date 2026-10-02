import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tablet_robot/esp_service.dart';
import 'package:tablet_robot/main.dart';

RobotBlockData _arm(String label, String value) => RobotBlockData(
      id: label,
      type: BlockType.servo,
      label: label,
      icon: Icons.front_hand,
      color: Colors.purple,
      value: value,
    );

void main() {
  test('kol blokları servo komutuna çevrilir', () {
    final program = compileBlocksToProgram([
      _arm('Sol kol', 'Yukarı'),
      _arm('Sağ kol', 'Aşağı'),
    ]);
    expect(program, [
      {'type': 'servo', 'arm': 'sol', 'direction': 'yukari'},
      {'type': 'servo', 'arm': 'sag', 'direction': 'asagi'},
    ]);
  });
}
