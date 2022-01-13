import 'package:flutter/material.dart';
import '../styles/fonts.dart';
import '../models/alarm.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../service/utility_functions.dart' as uf;

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(alarm.destination,
              style: AppFontStyle.inter_medium_15_121212),
          value: alarm.isActive,
          activeColor: Color(0xFF4FC28F),
          inactiveTrackColor: Color(0xFFE9E9E9),
          inactiveThumbColor: Color(0xFFC6C6C6),
          onChanged: (bool selected) async {
            setState(() {
              alarm.isActive = selected;
            });
            alarm.updateAlarm();
            if (widget.callback != null) {
              await widget.callback!();
            }
            if (!selected) {
              uf.stopMelody();
              Restart.restartApp();
            }
          }),
      endActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
          onPressed: (context) async {
            alarm.deleteAlarm();
            if (widget.onDelete != null) {
              await widget.onDelete!();
              await widget.callback!();
            }
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${alarm.destination} ${AppLocalizations.of(context)!.ondeleted}')));
          },
          backgroundColor: Color(0xFFca3e47),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: AppLocalizations.of(context)!.delete, //'Удалить',
        ),
      ]),
    );
  }
}
