import 'dart:ui';
import 'package:flutter/material.dart';

abstract class AppFontStyle {
  static const TextStyle inter_medium_15_121212 = TextStyle(
    fontSize: 15,
    fontFamily: "Inter",
    fontWeight: FontWeight.normal,
    color: Color(0xFF121212),
  );

  static const TextStyle appbar = TextStyle(
    fontSize: 18,
    fontFamily: "Inter",
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle inter_regular_12_5b5b5b = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: Color(0xFF5B5B5B),
  );

  static const TextStyle inter_semibold_12_black = TextStyle(
      fontFamily: "Inter",
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.black);

  static const TextStyle inter_regular_16_black = TextStyle(
      fontFamily: "Inter",
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black);

  static const TextStyle roboto_bold_14_white = TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white);

  static const TextStyle custom_labeltext = TextStyle(
    fontSize: 12,
    fontFamily: "Inter",
    fontWeight: FontWeight.w400,
    color: Color(0xFF8D8D8D),
  );
}
