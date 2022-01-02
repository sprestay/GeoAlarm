import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/fonts.dart';
import '../service/globals.dart' as globals;

class CustomInputField extends StatelessWidget {
  String? initialValue; // null - для использования controller
  late TextInputType keyboardType;
  late bool readonly;
  late Function? onchanged;
  late Function onsaved;
  late int? maxlength;
  late String? labeltext;
  late String? hinttext;
  late String? labeltextbold;
  late double height;
  late int? maxlines;
  late double? width;
  late Color background_color;
  late Widget? leading_icon;
  Key? key;
  List<TextInputFormatter>? formatters;
  TextEditingController? controller;
  Function? focus;

  CustomInputField(
      {this.initialValue,
      this.keyboardType = TextInputType.text,
      this.readonly = false,
      this.onchanged,
      this.onsaved = print,
      this.maxlength,
      this.labeltext,
      this.hinttext,
      this.labeltextbold = '',
      this.height = 56,
      this.maxlines = 1,
      this.width,
      this.background_color = const Color(0xFFF3F3F3),
      this.leading_icon,
      this.key,
      this.formatters,
      this.controller,
      this.focus});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Focus(
            child: TextFormField(
              key: key != null
                  ? key
                  : null, // костыль, чтобы данные обновлялись извне
              style: AppFontStyle.inter_regular_16_black,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 30, left: 10, right: 10),
                  hintText: hinttext,
                  counterText: "",
                  border: InputBorder.none,
                  hintMaxLines: maxlines == null ? 3 : 1),
              initialValue: initialValue,
              onSaved: (res) {
                onsaved(res);
              },
              onChanged: (res) {
                if (onchanged != null) {
                  onchanged!(res);
                }
              },
              enabled: !readonly,
              maxLength: maxlength,
              keyboardType: keyboardType,
              inputFormatters: formatters == null ? [] : formatters,
              maxLines: maxlines,
              controller: controller,
            ),
            onFocusChange: (bool b) {
              if (focus != null) focus!(b);
            },
          ),
          height: height,
          width: width == null
              ? MediaQuery.of(context).size.width * globals.most_element_width
              : width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: background_color,
          ),
        ),
        Container(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: labeltextbold,
                  style: AppFontStyle.inter_semibold_12_black),
              TextSpan(text: labeltext, style: AppFontStyle.custom_labeltext),
            ]),
          ),
          margin: EdgeInsets.only(top: 6, left: 12),
        ),
      ],
    );
  }
}
