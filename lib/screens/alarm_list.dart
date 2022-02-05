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
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';
import 'package:android_intent/android_intent.dart';

// реклама
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/banner_inline_page.dart';

class AlarmListScreen extends StatefulWidget {
  Function? onStart;
  Function? onStop;
  Function? onUpdate;

  AlarmListScreen({Key? key, this.onStart, this.onStop, this.onUpdate})
      : super(key: key);

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen>
    with WidgetsBindingObserver {
  List<Alarm> alarms = [];
  bool geoIsGranted = false;
  bool ignoringBattery = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    extractFromDB();

    /// вызов логики, после того, как отработает рендер
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      triggerModalWindows(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Permission.locationAlways.isGranted) {
        // Navigator.pushNamed(context, '/main');
        setState(() {
          ignoringBattery = true;
        });
      }
    }
  }

  void _onRefresh() async {
    extractFromDB();
    bool r = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    setState(() {
      ignoringBattery = r;
    });
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
    bool res = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    if (res) {
      setState(() {
        ignoringBattery = true;
      });
    } else {
      SharedPreferences db = await SharedPreferences.getInstance();
      int? message_shown_counter = db.getInt("message_shown_counter");
      bool? never_show_again = db.getBool("never_show_again");
      await Future.delayed(Duration(seconds: 1));

      if (!ignoringBattery && never_show_again != true) {
        uf.showBlockModalWindow(
            context: context,
            msg: AppLocalizations.of(context)!.battery,
            submit: () async => await batteryOptimization(),
            skip: () => Navigator.pop(context),
            skip_forever:
                message_shown_counter != null && message_shown_counter >= 1
                    ? () {
                        db.setBool("never_show_again", true);
                        Navigator.pop(context);
                      }
                    : null,
            isClosable: false);

        db.setInt("message_shown_counter",
            message_shown_counter == null ? 1 : message_shown_counter + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => true,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _onRefresh,
          child: Scaffold(
              appBar: CustomAppBar(
                  allow_backstep: false,
                  show_info: () => uf.showBlockModalWindow(
                      context: context,
                      msg: AppLocalizations.of(context)!.msg_on_alarm_list,
                      isClosable: true)),
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    width: MediaQuery.of(context).size.width *
                        globals.most_element_width,
                    child: Column(
                      children: [
                        alarms.length != 0 ? BannerInlinePage() : Container(),
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
                          builder: (context) => CreateNewAlarm(
                                callback: widget.onStart,
                              )));
                },
                backgroundColor: Color(0xFF4FC28F),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat),
        ));
  }

  // COMPLETE: Change return type to Future<InitializationStatus>
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }
}
