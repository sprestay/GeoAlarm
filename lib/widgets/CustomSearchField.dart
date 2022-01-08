import 'package:flutter/material.dart';
import 'package:geoalarm/styles/fonts.dart';
import 'package:searchfield/searchfield.dart';
import '../service/globals.dart' as globals;

class CustomSearchField extends StatelessWidget {
  late String? labeltext;
  late String? hinttext;
  late String? labeltextbold;
  List<String> suggestions = [];
  late double? width;
  late Color background_color;
  late double height;
  Function? onSelected;
  TextEditingController? controller;
  bool disabled;

  CustomSearchField({
    Key? key,
    this.labeltext,
    this.hinttext,
    this.labeltextbold,
    this.suggestions = const [],
    this.width,
    this.height = 56,
    this.background_color = const Color(0xFFF3F3F3),
    this.controller,
    this.onSelected,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: IgnorePointer(
            ignoring: disabled,
            child: SearchField(
              suggestions: suggestions,
              searchInputDecoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 30, left: 10, right: 10),
                hintText: hinttext,
                border: InputBorder.none,
              ),
              suggestionItemDecoration: BoxDecoration(),
              itemHeight: 40,
              hasOverlay: true,
              suggestionStyle: AppFontStyle.inter_regular_16_black,
              searchStyle: AppFontStyle.inter_regular_16_black,
              marginColor: Color(0x4D4FC28F),
              controller: controller,
              onTap: (String? text) {
                if (onSelected != null) onSelected!(text);
              },
              suggestionAction: SuggestionAction.unfocus,
            ),
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
                style: AppFontStyle.inter_semibold_12_black,
              ),
              TextSpan(text: labeltext, style: AppFontStyle.custom_labeltext)
            ]),
          ),
          margin: EdgeInsets.only(top: 6, left: 12),
        )
      ],
    );
  }
}
