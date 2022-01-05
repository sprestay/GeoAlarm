import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import '../styles/gradient.dart';
import '../models/alarm.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AlarmItem extends StatefulWidget {
  late Alarm alarm;
  Function? callback;
  Function? onDelete;

  AlarmItem({Key? key, required this.alarm, this.callback, this.onDelete})
      : super(key: key);

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
    return Slidable(
      key: Key(alarm.id),
      child: SwitchListTile(
          // tileColor: Colors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(alarm.destination,
              style: AppFontStyle.inter_medium_15_121212),
          subtitle: Text(alarm.isActive.toString()),
          value: alarm.isActive,
          activeColor: Color(0xFF4FC28F),
          inactiveTrackColor: Color(0xFFE9E9E9),
          inactiveThumbColor: Color(0xFFC6C6C6),
          onChanged: (bool selected) {
            setState(() {
              alarm.isActive = selected;
            });
            alarm.toggleAlarm();
            if (widget.callback != null) {
              widget.callback!();
            }
          }),
      endActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            alarm.deleteAlarm();
            if (widget.onDelete != null) {
              widget.onDelete!();
            }
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${alarm.destination} удален')));
          },
          backgroundColor: Color(0xFFca3e47),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Удалить',
        ),
      ]),
    );
  }
}
