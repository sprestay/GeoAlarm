import 'package:flutter/material.dart';
import 'package:geoalarm/styles/fonts.dart';
import 'package:geoalarm/widgets/CustomInputField.dart';
import 'package:searchfield/searchfield.dart';
import '../service/backend.dart';
import '../widgets/CustomSearchField.dart';
import '../styles/icons.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String input_string = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Stack(
                overflow: Overflow.visible,
                clipBehavior: Clip.none,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                  ),

                  // child: Container(
                  //   height: 500,
                  //   width: MediaQuery.of(context).size.width,
                  //   decoration: BoxDecoration(color: Colors.yellow),
                  //   child: SearchResultsContainer(
                  //     items: ["Name1", "Name2", "Name3", "Name4", "Name5"],
                  //     callback: (item) {
                  //       print(item);
                  //     },
                  //   ),
                  // )),

                  // child: Container(
                  //   width: 120,
                  //   height: 230,
                  //   color: Colors.yellow,
                  // ),
                  // )
                ],
              ),
              height: 70,
              decoration: BoxDecoration(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
