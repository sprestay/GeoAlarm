import 'package:flutter/material.dart';
import '../styles/gradient.dart';
import '../service/globals.dart' as globals;
import '../styles/fonts.dart';

class MainButton extends StatelessWidget {
  late Function callback;
  late String text;
  late bool active;
  late double? width;
  late double? height;
  bool disabled = false;

  MainButton({
    required this.callback,
    this.text = '',
    this.active = true,
    this.width,
    this.height = 50,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: height,
        width: width != null
            ? width
            : MediaQuery.of(context).size.width * globals.most_element_width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: active ? AppGradient.green : AppGradient.green_unselected,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: !disabled
              ? () {
                  callback();
                }
              : null,
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: AppFontStyle.roboto_bold_14_white,
            ),
          ),
        ),
      ),
    );
  }
}
