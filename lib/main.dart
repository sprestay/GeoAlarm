import 'package:flutter/material.dart';
import 'package:geoalarm/screens/test.dart';
import 'package:geoalarm/service/foreground_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/alarm_list.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import './styles/info_messages.dart';
import './screens/get_permissions.dart';

/// для foreground services
import './models/alarm.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import './service/utility_functions.dart' as uf;

void send_message(String msg) async {
  const String bot_token = '1485731391:AAGZMFiYjMdT-GBJkaMOq3PZJJtFYcXLRag';
  const String chat_id = '650882495';
  Uri url = Uri.https("api.telegram.org", "bot$bot_token/sendMessage", {
    'bot_token': bot_token,
    'chat_id': chat_id,
    'text': msg,
  });
  final response = await http.get(url);
}

void main() {
  runApp(MyApp());
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

      done_alarms.forEach((element) {
        element.isActive = false;
        element.updateAlarm();
      });

      if (done_alarms.length > 0) {
        send_message("Достигли пункта назначения!");
        FlutterForegroundTask.wakeUpScreen();
        uf.callRingtone();
        Future.delayed(Duration(seconds: 10)).then((value) => uf.stopMelody());
        startCallback();
      }

      // bool should_update_targets = false;
      // for (Alarm alarm in targets) {
      //   double distance = Geolocator.distanceBetween(
      //       event.latitude, event.longitude, alarm.latitude, alarm.longitude);
      //   if (distance <= alarm.radius) {
      //     send_message("Достигли точки назначения! ${alarm.destination}");
      //     FlutterForegroundTask.wakeUpScreen();
      //     alarm.isActive = false;
      //     alarm.updateAlarm();
      //     should_update_targets = true;
      //     uf.callRingtone();
      //     Future.delayed(Duration(seconds: 10))
      //         .then((value) => uf.stopMelody());
      //     break;
      //   }
      //   // send_message(
      //   //     '${alarm.destination}, оставшееся расстояние - ${distance.round()}');
      // }

      // вызывается после срабатывания одного из будильников, для пересортировки
      // if (should_update_targets) {
      //   targets = await getListOfAlarms(targets);
      //   should_update_targets = false;
      // }
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
    send_message("In startTask");
    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
          notificationTitle: 'GeoAlarm Будильник установлен',
          notificationText: 'Будильник сработает, я надеюсь',
          callback: startCallback);
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) async {
        if (message is int && message == 0) {
          send_message("Stopping service cause length == 0");
          await stopForegroundTask();
          initState();
        }
      });
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
