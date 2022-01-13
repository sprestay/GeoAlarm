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
import '../service/globals.dart' as globals;
import '../service/utility_functions.dart' as uf;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/alarm.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/scheduler.dart';

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
  double sliderValue = 1;
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  bool shoulMakeApiRequest = true; // костыль
  /// Мы перезаписываем значение в контроллере в двух случаях -
  /// когда значение меняет руками сам пользователь,
  /// и когда значение записывается после api запроса на бэк.
  /// Чтобы избежать запроса predictions, при подстановке значения с бэка - используем этот костыль

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  GeoMethods geoMethods = GeoMethods(
    googleApiKey: BackEnd().google_api_key,
    language: 'ru',
  );
  TextEditingController modal_controller = TextEditingController();

  @override
  void initState() {
    marker_position = latLng.LatLng(59.929479, 30.321312);
    _controller.text = ""; // а надо ли?
    input_string = '';
    _controller.addListener(() {
      final String text = uf.upperfirst(_controller.text);
      if (shoulMakeApiRequest) {
        if (text.length > 5) apiRequest({"type": "addr", "value": text});
      } else {
        shoulMakeApiRequest = true;
      }
    });
    options = MapOptions(
        center: marker_position,
        zoom: 15.0,
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


    SchedulerBinding.instance?.addPostFrameCallback((_) {
      geoMethods = GeoMethods(googleApiKey: BackEnd().google_api_key, language: Localizations.localeOf(context).languageCode);
    });
  }

  void _onRefresh() async {
    initState();
    _refreshController.refreshCompleted();
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
          input_string = uf.upperfirst(resp!['custom_addr'][0]);
          marker_position = latLng.LatLng(resp['latlng'][0]['lat'] as double,
              resp['latlng'][0]['lng'] as double);
        });
        _controller.text = uf.upperfirst(resp['custom_addr'][0]);
        shoulMakeApiRequest = false;
        controller.move(marker_position, controller.zoom);
      }
    } else if (req['type'] == "addr") {
      List<dynamic>? responses =
          await BackEnd().googleAutocompleteApi(address: req['value']);
      if (responses != null) {
        List<String> sug =
            responses.map((e) => e['description'].toString()).toList();
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

  void modalWindowToFindAddress(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddressSearchBuilder.deft(
        geoMethods: geoMethods,
        controller: modal_controller,
        builder: AddressDialogBuilder(
          color: Color(0xFF4FC28F),
          backgroundColor: Color(0xFFF6F5F5),
          hintText: AppLocalizations.of(context)!.where_are_you_moving, // "Куда направляетесь?",
          cancelText: AppLocalizations.of(context)!.close, //  "Закрыть",
          continueText: AppLocalizations.of(context)!.submit, // "Подтвердить",
          useButtons: false,
        ),
        onDone: (address) {
          if (address.coords != null) {
            setState(() {
              marker_position = latLng.LatLng(
                  address.coords!.latitude, address.coords!.longitude);
              input_string = uf.upperfirst(address.reference ?? "");
            });
            controller.move(marker_position, controller.zoom);
            _controller.text = input_string;
          }
        },
      ),
    );
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
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _onRefresh,
      child: Scaffold(
          body: Stack(children: [
        Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: CustomAppBar(
              allow_backstep: true,
              show_info: () => uf.showBlockModalWindow(
                  context, AppLocalizations.of(context)!.msg_on_create_alarm, null, null, true),
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
                      IgnorePointer(
                        ignoring: secondStep,
                        child: FlutterMap(
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
                      ),
                      secondStep ? blockDetermineRadius() : blockFindAddress(),
                      secondStep
                          ? Container()
                          : Positioned(
                              right: 30,
                              bottom: 250,
                              child: mapControllButtons()),
                    ])))
      ])),
    );
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
                    "${AppLocalizations.of(context)!.radius_to_detect}: ${uf.metersToDistanceString(uf.sliderValueToDistance(sliderValue), context)}",
                    style: AppFontStyle.inter_semibold_12_black,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),

            /// минимальный радиус - 50м
            /// максимальный - 100 км
            /// слайдер должен начинаться с 1 (для использовании в квадратичной фукнции)
            /// 50 м - 1 шаг
            /// 100 км - 100 000 м - 2000 шагов
            Slider(
                activeColor: Color(0xFF4FC28F),
                inactiveColor: Color(0x4D4FC28F),
                value: sliderValue,
                min: 1,
                max: 2000,
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
                // для того чтобы заного сработал initState
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              text: AppLocalizations.of(context)!.create, //"создать",
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
                // CustomSearchField(
                //   disabled: false,
                //   suggestions: suggestions,
                //   labeltextbold: "Точка назначения",
                //   background_color: Colors.white,
                //   controller: _controller,
                //   onSelected: (String s) {
                //     apiRequest({"type": "geo", "value": s});
                //   },
                // ),
                CustomInputField(
                  labeltextbold: AppLocalizations.of(context)!.destination_point, // "Точка назначения",
                  background_color: Colors.white,
                  // controller: _controller,
                  initialValue: input_string,
                  key: Key(input_string),
                  onTap: () {
                    modalWindowToFindAddress(context);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            MainButton(
              disabled: input_string.trim().length == 0,
              active: input_string.trim().length > 0,
              text: AppLocalizations.of(context)!.next, //"далее",
              callback: () {
                setState(() {
                  input_string = _controller.text;
                  secondStep = true;
                  sliderValue = uf.sliderValueFromZoom(controller.zoom);
                });
                print(uf.sliderValueFromZoom(controller.zoom));
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
