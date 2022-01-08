import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../widgets/InfoWidget.dart';

const num function_pow = 2.7;

double sliderValueToDistance(double val) {
  val = val / 2000; //  делим на maxSlider
  val = pow(val as num, function_pow) as double;
  // val = (1 + (val * 100)) > 100 ? 100 : (1 + (val * 100));
  val = (val * 2000) >= 2000 ? 100000 : ((1 + (val * 2000)) * 50);
  // return val * 1000; // в метрах
  return val;
}

Map<double, List<double>> zoomTable = {
  17: [0, 130],
  16: [130, 260],
  15: [260, 520],
  14: [520, 1050],
  13: [1050, 1750],
  12: [1750, 3500],
  11: [3500, 7000],
  10: [7000, 13750],
  9: [13750, 28000],
  8: [28000, 55000],
  7: [55000, 100001],
};

double determineZoomLevel(double val) {
  int x = val.round();
  List<double> k = zoomTable.keys.toList();
  for (int i = 0; i < k.length; i++) {
    if (x >= zoomTable[k[i]]![0] && x <= zoomTable[k[i]]![1]) {
      return k[i];
    }
  }
  return 7;
}

double sliderValueFromZoom(double zoomLevel) {
  if (zoomTable[zoomLevel] == null) {
    return 1000;
  }
  List<double> range = zoomTable[zoomLevel]!;
  double distance = (range[0] + range[1]) / 2 / 50;
  num val_for_log = ((distance - 1) / 2000);
  val_for_log = pow(val_for_log, 1 / function_pow);
  return val_for_log * 2000;
}

String metersToDistanceString(double meters) {
  if (meters < 1000) {
    return "${meters.round()} метров";
  } else {
    return "${(meters / 1000).toStringAsFixed(1)} километров";
  }
}

String upperfirst(String text) {
  if (text == null || text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

String customAddressFormatter(List adresses) {
  List<dynamic> result = [];
  List street =
      adresses.where((element) => element['types'].contains("route")).toList();
  List neighborhood = adresses
      .where((element) => element['types'].contains("neighborhood"))
      .toList();
  List number = adresses
      .where((element) => element['types'].contains("street_number"))
      .toList();
  List political = adresses
      .where((element) => element['types'].contains("political"))
      .toList();

  if (street.length > 0) {
    result.add(political[1]['long_name']);
    result.add(street[0]['short_name']);
    if (number.length > 0) {
      result.add(number[0]['short_name']);
    }
  } else {
    result = political.map((e) => e['short_name']).toList();
  }
  return upperfirst(result.join(', '));
}

void callRingtone() {
  FlutterRingtonePlayer.play(
    android: AndroidSounds.alarm,
    ios: IosSounds.alarm,
    looping: false, // Android only - API >= 28
    volume: 100, // Android only - API >= 28
    asAlarm: true, // Android only - all APIs
  );
}

void stopMelody() async {
  await Future.delayed(Duration(seconds: 2));
  FlutterRingtonePlayer.stop();
}

void showBlockModalWindow(BuildContext context, String msg,
    [Function? submit = null, Function? skip = null, bool isClosable = true]) {
  Navigator.push(
      context,
      PageRouteBuilder(
          barrierColor: Color.fromRGBO(163, 158, 158, 0.5),
          fullscreenDialog: true,
          opaque: false,
          pageBuilder: (_, __, ___) {
            return InfoWidget(
              msg: msg,
              mainbutton: submit,
              secondbutton: skip,
              isClosable: isClosable,
            );
          }));
}
