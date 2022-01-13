import 'package:flutter/material.dart';
import 'package:geoalarm/screens/create_new_alarm.dart';
import 'package:geoalarm/styles/fonts.dart';
import '../widgets/CustomAppBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../styles/icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../service/globals.dart' as globals;
import '../widgets/AlarmItem.dart';
import '../service/foreground_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// для проверки разрешений
import '../service/utility_functions.dart' as uf;
import '../styles/info_messages.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';
import 'package:android_intent/android_intent.dart';

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
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    extractFromDB();

    /// вызов логики, после того, как отработает рендер
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      // triggerModalWindows(context);
    });
  }

  void _onRefresh() async {
    extractFromDB();
    _refreshController.refreshCompleted();
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
    // if (!geoIsGranted) {
    //   Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

    //   ///
    //   /// После выхода из настроек модальное окно закрывалось, и можно было пользоваться
    //   /// приложением без доступа к геолокации
    //   ///
    //   uf.showBlockModalWindow(context, InfoMessages.geolocation_is_forbidden,
    //       () async {
    //     AndroidIntent intent = AndroidIntent(
    //       action: "android.settings.APPLICATION_DETAILS_SETTINGS",
    //       package: "com.example.geoalarm",
    //       data: "package:com.example.geoalarm",
    //     );
    //     intent.launch();
    //   }, null, false);
    // }

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
    return WillPopScope(
        onWillPop: () async => false,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _onRefresh,
          child: Scaffold(
              appBar: CustomAppBar(
                  allow_backstep: false,
                  show_info: () => uf.showBlockModalWindow(context,
                      AppLocalizations.of(context)!.msg_on_alarm_list, null, null, true)),
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
                                    key: Key(alarms[index].id),
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
                                    (BuildContext context, int index) =>
                                        SizedBox(
                                            height: 10,
                                            child: Center(
                                              child: Container(
                                                height: 0.2,
                                                color: Colors.black,
                                              ),
                                            )),
                                itemCount: alarms.length)
                            : Text(
                                AppLocalizations.of(context)!.no_created_alarms,
                                style: AppFontStyle.big_message,
                              ),
                        // TextButton(
                        //     onPressed: () {
                        //       uf.callRingtone();
                        //     },
                        //     child: Text("PlayMelody")),
                        // TextButton(
                        //     onPressed: () {
                        //       uf.stopMelody();
                        //     },
                        //     child: Text("StopMelody"))
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: AppIcons.new_alarm,
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateNewAlarm(callback: widget.onStart,)));
                },
                backgroundColor: Color(0xFF4FC28F),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat),
        ));
  }
}
