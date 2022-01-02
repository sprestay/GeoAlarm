import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './utility_functions.dart' as uf;

class BackEnd {
  String google_api_key = "AIzaSyCARAl30gjHY2khqkJxXLNp_vo2st9O76c";
  String geocoding_url = "https://maps.googleapis.com/maps/api/geocode/json";
  String autocomple_url =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  Future<Map<String, dynamic>?> googleGeocodingApi(
      {String? address, Map<String, dynamic>? marker}) async {
    Uri url = Uri.parse("$geocoding_url");
    if (address != null) {
      String address_string = address.replaceAll(" ", "+");
      url = Uri.parse(
          "$geocoding_url?address=$address_string&language=RU&key=$google_api_key");
    } else {
      var x = marker!['latitude'];
      var y = marker['longitude'];
      String latlng_string = "${x},${y}";
      url = Uri.parse(
          "$geocoding_url?latlng=$latlng_string&language=RU&key=$google_api_key");
    }

    dynamic response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> js = jsonDecode(response.body);
      if (js['results'].length > 0) {
        return {
          "address": js['results'].map((i) => i['formatted_address']).toList(),
          "latlng":
              js['results'].map((i) => i['geometry']['location']).toList(),
          "custom_addr": js['results']
              .map((i) => uf.customAddressFormatter(i['address_components']))
              .toList(),
        };
      } else {
        return null;
      }
    } else {
      var b = response.body;
      var i = response.statusCode;
      print("Error $b , status code $i");
      return null;
    }
  }

  Future<List<dynamic>?> googleAutocompleteApi(
      {required String address}) async {
    Uri url = Uri.parse("$autocomple_url?input=$address&key=$google_api_key");
    dynamic response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> js = jsonDecode(response.body);
      return js['predictions'];
    } else {
      return null;
    }
  }
}
