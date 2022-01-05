import 'package:flutter/material.dart';
import 'package:geoalarm/styles/fonts.dart';
import 'package:geoalarm/widgets/CustomInputField.dart';
import 'package:searchfield/searchfield.dart';
import '../service/backend.dart';
import '../widgets/CustomSearchField.dart';
import '../styles/icons.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../widgets/InfoWidget.dart';
import '../styles/info_messages.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String input_string = '';
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          fullscreenDialog: true,
                          opaque: false,
                          pageBuilder: (_, __, ___) {
                            return InfoWidget(
                              msg: InfoMessages.geolocation_is_forbidden,
                              submit: () {},
                              skip: () {},
                            );
                          }));
                },
                child: Text("ShowModal"))
          ],
        ),
      ),
    );
  }
}
