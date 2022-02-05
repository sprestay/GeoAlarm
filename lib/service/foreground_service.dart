import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:isolate';
import '../models/alarm.dart';
// import '../main.dart';

class TrackingTask extends TaskHandler {
  late List<Alarm> targets;
  StreamSubscription<Position>? streamSubscription;

  TrackingTask({
    required this.targets,
  }) : super();

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print("ON START");
    final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(distanceFilter: 30));

    streamSubscription = positionStream.listen((event) {
      print("Having ${targets.length} alarms");
      for (Alarm alarm in targets) {
        double distance = Geolocator.distanceBetween(
            event.latitude, event.longitude, alarm.latitude, alarm.longitude);
        if (distance <= alarm.radius) {
          // удалить из массива
        }
      }
      sendPort?.send(event);
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await FlutterForegroundTask.clearAllData();
  }
}

class ForegroundService {
  ReceivePort? _receivePort;

  // void startCallback(List<Alarm> alarms) async {
  //   print("in startCallback");
  //   FlutterForegroundTask.setTaskHandler(TrackingTask(targets: alarms));
  // }

  // void updateCallback(List<Alarm> alarms) async {
  //   print("in updateCallback");
  //   FlutterForegroundTask.setTaskHandler(TrackingTask(targets: alarms));
  // }

  // Future<bool> startForegroundTask(List<Alarm> alarms) async {
  //   print("In startTask");
  //   ReceivePort? receivePort;
  //   if (await FlutterForegroundTask.isRunningService) {
  //     print("restarting service");
  //     receivePort = await FlutterForegroundTask.restartService();
  //   } else {
  //     print("starting new service");
  //     receivePort = await FlutterForegroundTask.startService(
  //       notificationTitle: 'GeoAlarm Будильник установлен',
  //       notificationText: 'Будильник сработает, как только вы попадете в зону',
  //       callback: () {
  //         print("we are ready to trigger callback");
  //         startCallback(alarms);
  //       },
  //     ).then((value) {
  //       print("async is done");
  //     });
  //   }

  //   if (receivePort != null) {
  //     _receivePort = receivePort;
  //     _receivePort?.listen((message) {
  //       if (message is DateTime) {
  //         print('receive timestamp: $message');
  //       } else if (message is int) {
  //         print('receive updateCount: $message');
  //       }
  //     });
  //     return true;
  //   }
  //   return false;
  // }

  // Future<void> initForegroundTask() async {
  //   await FlutterForegroundTask.init(
  //     androidNotificationOptions: AndroidNotificationOptions(
  //       channelId: 'notification_channel_id',
  //       channelName: 'GeoAlarm service is running',
  //       channelDescription:
  //           'This notification appears when the foreground service is running.',
  //       channelImportance: NotificationChannelImportance.HIGH,
  //       priority: NotificationPriority.HIGH,
  //       iconData: const NotificationIconData(
  //         resType: ResourceType.mipmap,
  //         resPrefix: ResourcePrefix.ic,
  //         name: 'launcher',
  //       ),
  //     ),
  //     foregroundTaskOptions: const ForegroundTaskOptions(
  //       interval: 30000,
  //       autoRunOnBoot: true,
  //       allowWifiLock: true,
  //     ),
  //     printDevLog: true,
  //   );
  // }

  Future<bool> stopForegroundTask() async {
    print("Stopping service");
    return await FlutterForegroundTask.stopService();
  }

  void addData(String val) async {
    await FlutterForegroundTask.saveData(key: "key", value: val);
  }

  Future<String> getData(String key) async {
    return await FlutterForegroundTask.getData(key: "key");
  }
}
