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
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class AlarmListScreen extends StatefulWidget {
  Function? onStart;
  Function? onStop;
  Function? onUpdate;

  AlarmListScreen({Key? key, this.onStart, this.onStop, this.onUpdate})
      : super(key: key);

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> alarms = [];

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
                        return AlarmItem(
                          alarm: alarms[index],
                          callback: () {
                            if (widget.onStart != null) {
                              send_message("Calling update function");
                              widget.onStart!();
                            }
                          },
                          onDelete: () {
                            List<Alarm> tmp = alarms;
                            tmp.removeAt(index);
                            setState(() {
                              alarms = tmp;
                            });
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 10),
                      itemCount: alarms.length),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (widget.onStart != null) {
                              send_message("calling widget.onStart");
                              widget.onStart!();
                            }
                          },
                          child: Text("StartService")),
                      ElevatedButton(
                          onPressed: () {
                            if (widget.onStop != null) {
                              send_message("calling stop button");
                              widget.onStop!();
                            }
                          },
                          child: Text("StopService")),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            print(await FlutterForegroundTask
                                .isIgnoringBatteryOptimizations);
                          },
                          child: Text("Игнор?")),
                      ElevatedButton(
                          onPressed: () async {
                            print(await FlutterForegroundTask
                                .openIgnoreBatteryOptimizationSettings());
                          },
                          child: Text("Настройки")),
                      ElevatedButton(
                          onPressed: () async {
                            print(await FlutterForegroundTask
                                .requestIgnoreBatteryOptimization());
                          },
                          child: Text("Разрешения"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: AppIcons.new_alarm,
          onPressed: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateNewAlarm()));
          },
          backgroundColor: Color(0xFF4FC28F),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
