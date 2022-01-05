import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/MainButton.dart';
import '../service/globals.dart' as globals;
import '../styles/fonts.dart';

class InfoWidget extends StatefulWidget {
  late String msg;
  Function? skip;
  Function? submit;
  late bool isClosable;

  InfoWidget(
      {Key? key,
      required this.msg,
      this.skip,
      this.submit,
      this.isClosable = true})
      : super(key: key);

  @override
  _InfoWidgetState createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.05,
            MediaQuery.of(context).size.height * 0.3,
            MediaQuery.of(context).size.width * 0.05,
            MediaQuery.of(context).size.width * 0.4),
        child: Material(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          color: Colors.white,
          child: Container(
            child: Column(
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
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Center(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          widget.msg.replaceAll(RegExp(r'\s'), " ").trim(),
                          textAlign: TextAlign.left,
                          style: AppFontStyle.inter_regular_16_black,
                        ),
                      ))),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.submit != null
                        ? MainButton(
                            callback: () {
                              if (widget.submit != null) widget.submit!();
                              Navigator.pop(context);
                            },
                            width: MediaQuery.of(context).size.width *
                                0.9 *
                                globals.most_element_width,
                            text: "подтвердить",
                          )
                        : Container(),
                    widget.skip != null
                        ? TextButton(
                            onPressed: () {
                              if (widget.skip != null) widget.skip!();
                            },
                            child: Text("ПРОПУСТИТЬ"))
                        : Container()
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
