import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:isolate';
import '../models/alarm.dart';

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

class TrackingTask extends TaskHandler {
  late Position targetPosition;
  late int radius;
  StreamSubscription<Position>? streamSubscription;

  TrackingTask({
    required this.targetPosition,
    required this.radius,
  }) : super();

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    final customData = await FlutterForegroundTask.getData<String>(key: 'key');
    print("On start $customData");

    final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(distanceFilter: 30));
    streamSubscription = positionStream.listen((event) {
      double distance = Geolocator.distanceBetween(event.latitude,
          event.longitude, targetPosition.latitude, targetPosition.longitude);
      send_message('Оставшееся расстояние - ${distance.round()}');
      sendPort?.send(event);
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final customData = await FlutterForegroundTask.getData<String>(key: 'key');
    print("On event $customData");
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await FlutterForegroundTask.clearAllData();
  }
}

class ForegroundService {
  ReceivePort? _receivePort;

  void startCallback() async {
    Position target = Position(
        latitude: 59.9284315,
        longitude: 30.3112665,
        timestamp: DateTime.now(),
        accuracy: 17.613000869750977,
        altitude: 26.0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    // The setTaskHandler function must be called to handle the task in the background.
    FlutterForegroundTask.setTaskHandler(
        TrackingTask(radius: 10, targetPosition: target));
  }

  Future<bool> startForegroundTask(Alarm target) async {
    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      print("Service is running");
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      print("creating new service");
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'GeoAlarm Будильник установлен',
        notificationText: 'Будильник сработает через 29 км',
        callback: startCallback,
      ).then((value) {
        print("async work is node");
      });
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          print('receive timestamp: $message');
        } else if (message is int) {
          print('receive updateCount: $message');
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

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  void addData(String val) async {
    await FlutterForegroundTask.saveData(key: "key", value: val);
  }
}
