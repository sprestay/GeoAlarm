import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geoalarm/styles/fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import '../service/backend.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomInputField.dart';
import '../widgets/MainButton.dart';
import '../styles/icons.dart';
import '../service/globals.dart' as globals;
import '../service/utility_functions.dart' as uf;
import '../widgets/CustomSearchField.dart';
import '../models/alarm.dart';
import '../screens/alarm_list.dart';

class CreateNewAlarm extends StatefulWidget {
  const CreateNewAlarm({Key? key}) : super(key: key);

  @override
  _CreateNewAlarmState createState() => _CreateNewAlarmState();
}

class _CreateNewAlarmState extends State<CreateNewAlarm> {
  MapController controller = MapController();
  late latLng.LatLng marker_position;
  late MapOptions options;
  String input_string = '';
  bool secondStep = false;
  double sliderValue = 10;
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  bool shoulMakeApiRequest = true; // костыль
  /// Мы перезаписываем значение в контроллере в двух случаях -
  /// когда значение меняет руками сам пользователь,
  /// и когда значение записывается после api запроса на бэк.
  /// Чтобы избежать запроса predictions, при подстановке значения с бэка - используем этот костыль

  @override
  void initState() {
    marker_position = latLng.LatLng(59.929479, 30.321312);
    _controller.addListener(() {
      final String text = uf.upperfirst(_controller.text);
      if (shoulMakeApiRequest) {
        if (text.length > 5) apiRequest({"type": "addr", "value": text});
      } else {
        shoulMakeApiRequest = true;
      }
    });
    options = MapOptions(
        interactiveFlags: secondStep ? 0 : 1, // карта неактивна на вотром шаге
        center: marker_position,
        zoom: 13.0,
        maxZoom: 17,
        minZoom: 7,
        onMapCreated: (MapController _contr) {
          _contr.mapEventStream
              .where((event) => event is MapEventMoveEnd)
              .listen((event) {
            apiRequest({"type": "geo"});
          });
          _contr.mapEventStream
              .where((event) => event is MapEventMove)
              .listen((event) {
            mapOnMove();
          });
        });
    getUserPosition();
  }

  void apiRequest(Map<String, dynamic> req) async {
    Map<String, dynamic>? resp;
    if (req['type'] == "geo") {
      if (req.containsKey("value")) {
        resp = await BackEnd().googleGeocodingApi(address: req['value']);
      } else {
        resp = await BackEnd().googleGeocodingApi(marker: {
          "latitude": marker_position.latitude,
          "longitude": marker_position.longitude
        });
      }

      if (resp != null) {
        setState(() {
          input_string = uf.upperfirst(resp!['address'][0]);
          marker_position =
              latLng.LatLng(resp['latlng'][0]['lat'], resp['latlng'][0]['lng']);
        });
        _controller.text = uf.upperfirst(resp['address'][0]);
        shoulMakeApiRequest = false;
        controller.move(marker_position, controller.zoom);
      }
    } else if (req['type'] == "addr") {
      List<dynamic>? responses =
          await BackEnd().googleAutocompleteApi(address: req['value']);
      if (responses != null) {
        List<String> sug =
            responses.map((e) => e['description'].toString()).toList();
        print("GOT ${sug.length}");
        setState(() {
          suggestions = sug;
        });
      }
    }
  }

  void zoomIn() {
    controller.move(marker_position, controller.zoom + 1);
  }

  void zoomOut() {
    controller.move(marker_position, controller.zoom - 1);
  }

  void getUserPosition() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      marker_position = latLng.LatLng(pos.latitude, pos.longitude);
    });
    controller.move(marker_position, controller.zoom);
    apiRequest({"type": "geo"});
  }

  void mapOnMove() {
    setState(() {
      marker_position = latLng.LatLng(
          controller.center.latitude, controller.center.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            allow_backstep: true,
            show_info: true,
            backstep_function: secondStep
                ? () {
                    setState(() {
                      secondStep = false;
                    });
                  }
                : null,
          ),
          body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    FlutterMap(
                      options: options,
                      mapController: controller,
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: marker_position,
                              builder: (ctx) => Image.asset(
                                "marker.png",
                                width: 20,
                              ),
                            ),
                          ],
                        ),
                        CircleLayerOptions(circles: [
                          CircleMarker(
                            useRadiusInMeter: true,
                            point: marker_position,
                            color: Color(0xFF0EA64F).withOpacity(0.2),
                            radius: secondStep
                                ? uf.sliderValueToDistance(sliderValue)
                                : 0, // чтобы круг отображался только при задании радиуса
                          )
                        ]),
                      ],
                    ),
                    secondStep ? blockDetermineRadius() : blockFindAddress(),
                    secondStep
                        ? Container()
                        : Positioned(
                            right: 30,
                            bottom: 250,
                            child: mapControllButtons()),
                  ])))
    ]));
  }

  Widget mapControllButtons() {
    /// не можем обращаться к контроллеру внутри функции - получаем late initialization error, поэтому
    /// не можем проверить, можем ли зумить, или нет (и отображать / не отображать) кнопки
    return Container(
      width: 50,
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () => zoomIn(),
              icon: Icon(
                Ionicons.add,
                size: 60,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () => zoomOut(),
              icon: Icon(
                Ionicons.remove,
                size: 60,
                color: Colors.black,
              )),
          SizedBox(
            height: 30,
          ),
          IconButton(
              onPressed: () {
                getUserPosition();
              },
              icon: Icon(
                Ionicons.navigate_circle_outline,
                size: 60,
                color: Colors.black,
              )),
        ],
      ),
    );
  }

  Widget blockDetermineRadius() {
    return Container(
        child: Center(
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width *
                  globals.most_element_width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Радиус для срабатывания: ${(uf.sliderValueToDistance(sliderValue) / 1000).toStringAsFixed(2)} км",
                    style: AppFontStyle.inter_semibold_12_black,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Slider(
                activeColor: Color(0xFF4FC28F),
                inactiveColor: Color(0x4D4FC28F),
                value: sliderValue,
                min: 1,
                max: 100,
                onChanged: (double value) {
                  setState(() {
                    sliderValue = value;
                  });
                  double tmp =
                      uf.determineZoomLevel(uf.sliderValueToDistance(value))
                          as double;
                  controller.move(marker_position, tmp);
                }),
            SizedBox(
              height: 10,
            ),
            MainButton(
              callback: () {
                Alarm a = Alarm(
                  latitude: marker_position.latitude,
                  longitude: marker_position.longitude,
                  radius: uf.sliderValueToDistance(sliderValue),
                  destination: input_string,
                  isActive: false,
                );
                a.saveToDB();
                // Navigator.pop(context);
                // для того чтобы заного сработал initState
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AlarmListScreen()));
              },
              text: "создать",
            ),
            SizedBox(
              height: 34,
            )
          ]),
        ),
        height: 186,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  offset: Offset(0, -5),
                  blurRadius: 8)
            ],
            color: Color(0xFFF6F5F5),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))));
  }

  Widget blockFindAddress() {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 26),
            Stack(
              children: [
                CustomSearchField(
                  suggestions: suggestions,
                  labeltextbold: "Точка назначения",
                  background_color: Colors.white,
                  controller: _controller,
                  onSelected: (String s) {
                    apiRequest({"type": "geo", "value": s});
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            MainButton(
              disabled: input_string.isEmpty,
              active: input_string.isNotEmpty,
              text: "далее",
              callback: () {
                setState(() {
                  input_string = _controller.text;
                  secondStep = true;
                });
              },
            ),
            SizedBox(height: 34),
          ],
        ),
      ),
      height: 186,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: Offset(0, -5),
                blurRadius: 8)
          ],
          color: Color(0xFFF6F5F5),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    );
  }
}
