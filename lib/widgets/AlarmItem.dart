import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import '../styles/gradient.dart';
import '../models/alarm.dart';

class AlarmItem extends StatefulWidget {
  late Alarm alarm;
  AlarmItem({Key? key, required this.alarm}) : super(key: key);

  @override
  _AlarmItemState createState() => _AlarmItemState();
}

class _AlarmItemState extends State<AlarmItem> {
  late Alarm alarm;

  @override
  void initState() {
    alarm = widget.alarm;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: Key(alarm.id),
        background: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0x4Dfe5f55),
          ),
        ),
        onDismissed: (direction) {
          alarm.deleteAlarm();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${alarm.destination} удален')));
        },
        child: SwitchListTile(
            // tileColor: Colors.yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text(alarm.destination,
                style: AppFontStyle.inter_medium_15_121212),
            value: alarm.isActive,
            activeColor: Color(0xFF4FC28F),
            inactiveTrackColor: Color(0xFFE9E9E9),
            inactiveThumbColor: Color(0xFFC6C6C6),
            onChanged: (bool selected) {
              setState(() {
                alarm.isActive = selected;
              });
              alarm.toggleAlarm();
            }));
  }
}
