import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/alarm_list.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import './screens/get_permissions.dart';
import 'package:flutter/services.dart';

/// для foreground services
import './models/alarm.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import './service/utility_functions.dart' as uf;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// реклама
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

void startCallback() async {
  print("in startCallback");
  FlutterForegroundTask.setTaskHandler(TrackingTask());
}

class TrackingTask extends TaskHandler {
  StreamSubscription<Position>? streamSubscription;

  TrackingTask() : super();

  Future<List<Alarm>> getListOfAlarms([List<Alarm>? al = null]) async {
    if (al != null) {
      return al.where((element) => element.isActive).toList();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList("alarms");
    List<Alarm> targets = [];

    /// Делаем асинхронные запросы к базе, Future сохраняем в массив to_wait
    /// после того, как все асинхронные таски выполнены - продолжаем работу

    if (ids != null) {
      List<Future<bool>> to_wait = [];
      targets = ids.map((e) {
        Alarm a = Alarm.constructorWithAsyncRequest();
        to_wait.add(a.fromDB(e));
        return a;
      }).toList();
      await Future.wait(to_wait);
      targets = targets.where((element) => element.isActive).toList();
    }
    return targets;
  }

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    List<Alarm> targets = await getListOfAlarms();

    /// Если нет будильников - то дропаем сервис
    sendPort?.send(targets.length);
    if (targets.length == 0) {
      // костыль. сервис не останавливается после перезагрузки
      await FlutterForegroundTask.stopService();
    }

    final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(distanceFilter: 30));

    streamSubscription = positionStream.listen((event) async {
      List<Alarm> done_alarms = targets.where((element) {
        double distance = Geolocator.distanceBetween(event.latitude,
            event.longitude, element.latitude, element.longitude);
        if (distance <= element.radius) {
          return true;
        } else {
          return false;
        }
      }).toList();

      if (done_alarms.length > 0) {
        FlutterForegroundTask.wakeUpScreen();
        uf.callRingtone();
        startCallback();
      }
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Destroyng');

    /// метод сносит все sharedPreferences.
    /// Либо не вызывать его, либо сохранять свои prefы

    // await FlutterForegroundTask.clearAllData();
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ReceivePort? _receivePort;
  late Position position;
  bool isGranted = false;

  @override
  void initState() {
    getCurrentPermission();
    super.initState();
    initForegroundTask();
  }

  Future<bool> startForegroundTask() async {
    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
          notificationTitle: "Alarm is started",
          notificationText: '',
          callback: startCallback);
    }

    if (receivePort != null) {
      return true;
    }
    return false;
  }

  Future<void> initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'GeoAlarm service is running',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 30000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> stopForegroundTask() async {
    print("Stopping service");
    return await FlutterForegroundTask.stopService();
  }

  void getCurrentPermission() async {
    bool x = await Permission.locationAlways.isGranted;
    setState(() {
      isGranted = x;
    });
  }

  @override
  void dispose() {
    _receivePort?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en"),
        Locale("ru"),
        Locale("de"),
        Locale("fr"),
        Locale("zh"),
        Locale("es")
      ],
      routes: <String, WidgetBuilder>{
        "/main": (BuildContext context) => WithForegroundTask(
                child: AlarmListScreen(
              onStart: startForegroundTask,
              onStop: stopForegroundTask,
            ))
      },
      home: !isGranted
          ? GetPermissionsPage()
          : WithForegroundTask(
              child: AlarmListScreen(
              onStart: startForegroundTask,
              onStop: stopForegroundTask,
            )),
    );
  }
}
