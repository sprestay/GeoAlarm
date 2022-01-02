import 'package:flutter/material.dart';
import './gradient.dart';
import 'package:ionicons/ionicons.dart';

abstract class AppIcons {
  static Widget new_alarm = Icon(
    Ionicons.add,
    size: 50,
    color: Colors.white,
  );

  static Widget info = Container(
    width: 50,
    height: 50,
    child: Icon(
      Ionicons.help_circle_outline,
      color: Colors.white,
      size: 30,
    ),
    decoration:
        BoxDecoration(gradient: AppGradient.green, shape: BoxShape.circle),
  );

  static Widget backstep = Container(
      width: 50,
      height: 50,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_ios,
            size: 30,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Colors.white)),
        ),
      ));

  static Widget leading_search_icon = Container(
    width: 20,
    height: 20,
    child: Icon(Ionicons.search, color: Color(0xFF807D7D), size: 25),
  );
}
