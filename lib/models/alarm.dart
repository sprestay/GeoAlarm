import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class Alarm {
  late double latitude;
  late double longitude;
  late double radius;
  late String destination;
  bool isActive = false;
  int created = DateTime.now().millisecondsSinceEpoch;
  String id = Uuid().v4().toString();

  Alarm({
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.destination = '',
    this.isActive = false,
  });

  Alarm.fromJson(js) {
    fromJson(js);
  }

  Alarm.fromDB(String id) {
    fromDB(id);
  }

  Future<void> saveToDB() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setString(id, jsonEncode(toJson()));
    List<String>? all_db = db.getStringList('alarms');
    if (all_db == null) {
      all_db = [id];
    } else {
      all_db.add(id);
    }
    db.setStringList('alarms', all_db);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> js = {
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "destination": destination,
      "isActive": isActive,
      "id": id,
      "created": created
    };
    return js;
  }

  void fromJson(Map<String, dynamic> js) {
    latitude = js['latitude'];
    longitude = js['longitude'];
    radius = js['radius'];
    destination = js['destination'];
    isActive = js['isActive'];
    id = js['id'];
    created = js['created'];
  }

  void fromDB(String id) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    Map<String, dynamic> js = jsonDecode(db.getString(id)!);
    fromJson(js);
  }

  void toggleAlarm() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.setString(id, jsonEncode(toJson()));
  }

  void deleteAlarm() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.remove(id);
    List<String>? id_list = db.getStringList("alarms");
    id_list?.remove(id);
    db.setStringList("alarms", id_list != null ? id_list : []);
  }
}
