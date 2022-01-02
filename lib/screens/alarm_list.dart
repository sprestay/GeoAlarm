import 'package:flutter/material.dart';
import 'package:geoalarm/screens/create_new_alarm.dart';
import 'package:geoalarm/styles/gradient.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CircleButton.dart';
import '../styles/icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../service/globals.dart' as globals;
import '../widgets/AlarmItem.dart';
import '../service/foreground_service.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> alarms = [];
  ForegroundService service = ForegroundService();

  @override
  void initState() {
    extractFromDB();
  }

  Future<void> extractFromDB() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    List<String>? ids = db.getStringList('alarms');
    List<Alarm> tmp =
        ids == null ? [] : ids.map((e) => Alarm.fromDB(e)).toList();
    tmp.sort((Alarm a, Alarm b) => a.created.compareTo(b.created));
    setState(() {
      alarms = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(allow_backstep: false, show_info: true),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 30),
              width: MediaQuery.of(context).size.width *
                  globals.most_element_width,
              child: Column(
                children: [
                  ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (BuildContext context, int index) {
                        return AlarmItem(alarm: alarms[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 10),
                      itemCount: alarms.length)
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: AppIcons.new_alarm,
          onPressed: () {
            // service.startForegroundTask(
            //     Alarm(latitude: 10, longitude: 10, radius: 10));
            service.addData("adolf");
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => CreateNewAlarm()));
          },
          backgroundColor: Color(0xFF4FC28F),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
