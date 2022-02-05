import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/MainButton.dart';
import '../service/globals.dart' as globals;
import '../styles/fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

class InfoWidget extends StatefulWidget {
  late String msg;
  Function? secondbutton;
  Function? mainbutton;
  Function? thirdbutton;
  late bool isClosable;

  InfoWidget(
      {Key? key,
      required this.msg,
      this.secondbutton,
      this.mainbutton,
      this.thirdbutton,
      this.isClosable = true})
      : super(key: key);

  @override
  _InfoWidgetState createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  // bool neverShowAgain = false;

  double calculateHeight(double width) {
    TextPainter textPainter = TextPainter()
      ..text =
          TextSpan(text: widget.msg, style: AppFontStyle.inter_regular_16_black)
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: width);
    double text_height = textPainter.size.height + 50;
    if (widget.mainbutton != null || widget.secondbutton != null) {
      text_height += 56 + 20;
    }
    if (widget.mainbutton != null && widget.secondbutton != null) {
      text_height += 56;
    }
    if (widget.isClosable) {
      text_height += 40;
    }
    if (widget.thirdbutton != null) {
      text_height += 30;
    }
    return text_height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          top: (MediaQuery.of(context).size.height -
                  calculateHeight(MediaQuery.of(context).size.width *
                      0.9 *
                      globals.most_element_width)) /
              2,
          bottom: (MediaQuery.of(context).size.height -
                  calculateHeight(MediaQuery.of(context).size.width *
                      0.9 *
                      globals.most_element_width)) /
              2,
        ),
        child: Material(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          color: Colors.white,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.isClosable
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Ionicons.close,
                                size: 45,
                                color: Colors.black,
                              )),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      )
                    : Container(),
                Expanded(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Center(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          widget.msg.trim(),
                          textAlign: TextAlign.left,
                          style: AppFontStyle.inter_regular_16_black,
                        ),
                      ))),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.mainbutton != null
                          ? MainButton(
                              callback: () {
                                if (widget.mainbutton != null)
                                  widget.mainbutton!();
                                Navigator.pop(context);
                              },
                              width: MediaQuery.of(context).size.width *
                                  0.9 *
                                  globals.most_element_width,
                              text: AppLocalizations.of(context)!.submit,
                            )
                          : Container(),
                      widget.secondbutton != null
                          ? TextButton(
                              onPressed: () {
                                if (widget.secondbutton != null)
                                  widget.secondbutton!();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .skip
                                  .toUpperCase()))
                          : Container(),
                      widget.thirdbutton != null
                          ? TextButton(
                              onPressed: () {
                                if (widget.thirdbutton != null)
                                  widget.thirdbutton!();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .never_show_again
                                  .toUpperCase()))
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}


// Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Checkbox(
//                                 activeColor: Color(0xFF68C78E),
//                                 shape: CircleBorder(),
//                                 value: neverShowAgain,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     neverShowAgain = value!;
//                                   });
//                                 }),
//                             Text("Не показывать больше")
//                           ],
//                         ),
//                         color: Colors.amber,
//                       ),