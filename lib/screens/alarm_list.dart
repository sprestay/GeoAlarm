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

/// для проверки разрешений
import '../service/utility_functions.dart' as uf;
import '../styles/info_messages.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool geoIsGranted = false;
  bool ignoringBattery = false;

  @override
  void initState() {
    extractFromDB();
    checkPermissions();
  }

  void checkPermissions() async {
    if (await Permission.locationAlways.isGranted) {
      setState(() {
        geoIsGranted = true;
      });
    }
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      setState(() {
        ignoringBattery = true;
      });
    }
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

  Future<bool> batteryOptimization() async {
    bool res = await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    if (!res) {
      res = await FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
    }
    return res;
  }

  void triggerModalWindows(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    if (!geoIsGranted) {
      uf.showBlockModalWindow(
          context, InfoMessages.geolocation_is_forbidden, null, null, false);
    }

    if (!ignoringBattery) {
      uf.showBlockModalWindow(
          context,
          InfoMessages.ignore_battery_optimization,
          () async => await batteryOptimization(),
          () => Navigator.pop(context),
          false);
    }
  }

  @override
  Widget build(BuildContext context) {
    triggerModalWindows(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: CustomAppBar(allow_backstep: false, show_info: true),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 30),
                width: MediaQuery.of(context).size.width *
                    globals.most_element_width,
                child: Column(
                  children: [
                    alarms.length != 0
                        ? ListView.separated(
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
                            separatorBuilder:
                                (BuildContext context, int index) => SizedBox(
                                    height: 10,
                                    child: Center(
                                      child: Container(
                                        height: 0.2,
                                        color: Colors.black,
                                      ),
                                    )),
                            itemCount: alarms.length)
                        : Text("Нет сохраненных будильников"),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }
}
