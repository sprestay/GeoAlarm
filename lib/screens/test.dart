import 'package:flutter/material.dart';
import 'package:geoalarm/styles/fonts.dart';
import 'package:geoalarm/widgets/CustomInputField.dart';
import 'package:searchfield/searchfield.dart';
import '../service/backend.dart';
import '../widgets/CustomSearchField.dart';
import '../styles/icons.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../widgets/InfoWidget.dart';
import '../styles/info_messages.dart';
import 'package:address_search_field/address_search_field.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String input_string = '';
  TextEditingController controller = TextEditingController();
  final geoMethods = GeoMethods(
    googleApiKey: BackEnd().google_api_key,
    language: 'ru',
  );

  Widget CustomGeoModalWindow(
      {snapshot, controller, searchAddress, getGeometry, onDone}) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: Text("click"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddressSearchBuilder.deft(
                    geoMethods: geoMethods,
                    controller: controller,
                    builder: AddressDialogBuilder(
                      color: Color(0xFF4FC28F),
                      backgroundColor: Color(0xFFF6F5F5),
                      hintText: "Куда направляетесь?",
                      cancelText: "Закрыть",
                      continueText: "Подтвердить",
                      useButtons: false,
                    ),
                    onDone: (address) => print(address),
                  ),
                );
              },
            ),
            TextButton(
                child: Text("custom"),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AddressSearchBuilder(
                            geoMethods: geoMethods,
                            controller: controller,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<List<Address>> snapshot,
                              TextEditingController controller,
                              Future<void> Function() searchAddress,
                              Future<Address> Function(Address address)
                                  getGeometry,
                            ) {
                              return CustomGeoModalWindow(
                                snapshot: snapshot,
                                controller: controller,
                                searchAddress: searchAddress,
                                getGeometry: getGeometry,
                                onDone: (Address address) => null,
                              );
                            },
                          ));
                }),
          ],
        ),
      ),
    );
  }
}
