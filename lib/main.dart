import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/alarm_list.dart';
// import './screens/create_new_alarm.dart';
// import './screens/test.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
// import './service/foreground_service.dart';

/// для foreground services
import './models/alarm.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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

void updateCallback() async {
  print("in updateCallback");
  FlutterForegroundTask.setTaskHandler(TrackingTask());
}

class TrackingTask extends TaskHandler {
  StreamSubscription<Position>? streamSubscription;

  TrackingTask() : super();

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
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

    /// Если нет будильников - то дропаем сервис
    sendPort?.send(targets.length);

    final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(distanceFilter: 30));

    streamSubscription = positionStream.listen((event) {
      for (Alarm alarm in targets) {
        double distance = Geolocator.distanceBetween(
            event.latitude, event.longitude, alarm.latitude, alarm.longitude);
        if (distance <= alarm.radius) {
          send_message("Достигли точки назначения! ${alarm.destination}");
          // удалить из массива
        }
        send_message(
            '${alarm.destination}, оставшееся расстояние - ${distance.round()}');
      }
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Destroyng');
    await FlutterForegroundTask.clearAllData();
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
      _receivePort?.listen((message) {
        if (message is int && message == 0) {
          stopForegroundTask();
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
    print("Checking permissiongs");
    if (await Permission.locationAlways.request().isGranted) {
      Position p = await Geolocator.getCurrentPosition();
      setState(() {
        isGranted = true;
        position = p;
      });
      print("granted!");
    } else {
      print("not granted");
      setState(() {
        isGranted = false;
      });
    }
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
      home: WithForegroundTask(
          child: AlarmListScreen(
        onStart: startForegroundTask,
        onStop: stopForegroundTask,
        onUpdate: updateCallback,
      )),
    );
  }
}
