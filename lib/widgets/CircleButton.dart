import 'package:flutter/material.dart';
import '../styles/gradient.dart';

class CircularButton extends StatelessWidget {
  late double? size;
  late Function callback;
  late bool isActive;
  late LinearGradient background;
  late Widget icon;
  late double? icon_size;

  CircularButton({
    this.size = 70,
    required this.callback,
    this.isActive = true,
    this.background = AppGradient.green,
    required this.icon,
    this.icon_size = 33,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: background != null ? background : AppGradient.green,
          ),
          child: InkWell(
            onTap: () {
              callback();
            },
            customBorder: CircleBorder(),
            child: Center(
              child: icon,
            ),
          ),
        ));
  }
}
