import 'package:flutter/material.dart';
import 'package:geoalarm/styles/gradient.dart';
import '../styles/fonts.dart';
import '../styles/icons.dart';
import '../widgets/CircleButton.dart';
import 'package:ionicons/ionicons.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  late String title;
  late bool allow_backstep;
  Function? show_info;
  Function? backstep_function;
  CustomAppBar(
      {Key? key,
      this.title = '',
      this.allow_backstep = true,
      this.backstep_function,
      this.show_info = null})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading:
          false, //  должна исчезнуть стандартная кнопка назад
      bottomOpacity: 0.0,
      elevation: 0.0,
      centerTitle: true,
      title: Text(widget.title, style: AppFontStyle.appbar),
      leading: widget.allow_backstep
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              tooltip: 'Back step',
              onPressed: () {
                if (widget.backstep_function == null) {
                  Navigator.pop(context);
                } else {
                  widget.backstep_function!();
                }
              },
            )
          : Container(),
      actions: [
        widget.show_info != null
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: CircularButton(
                  size: 50,
                  background: AppGradient.green,
                  icon: Icon(
                    Ionicons.help_circle_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                  callback: () {
                    widget.show_info!();
                  },
                ))
            : Container(),
      ],
    );
  }
}
