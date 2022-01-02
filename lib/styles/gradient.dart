import 'package:flutter/material.dart';

abstract class AppGradient {
  static const LinearGradient green = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF7CCB8D),
        Color(0xFF77CA8D),
        Color(0xFF68C78E),
        Color(0xFF4FC28F),
        Color(0xFF2CBC90),
        Color(0xFF08B591)
      ]);

  static const LinearGradient green_unselected = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0x4D7CCB8D),
        Color(0x4D77CA8D),
        Color(0x4D68C78E),
        Color(0x4D4FC28F),
        Color(0x4D2CBC90),
        Color(0x4D08B591)
      ]);
}
