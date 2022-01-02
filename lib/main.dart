import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import './screens/alarm_list.dart';
import './screens/create_new_alarm.dart';
import './screens/test.dart';
import 'dart:isolate';
import './service/foreground_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ReceivePort? _receivePort;
  ForegroundService service = ForegroundService();

  @override
  void initState() {
    super.initState();
    service.initForegroundTask();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AlarmListScreen());
  }
}
