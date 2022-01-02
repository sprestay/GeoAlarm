import 'dart:math';

// val 1-100
// distance 1-100
double sliderValueToDistance(double val) {
  val = val / 100;
  val = pow(val as num, 2.7) as double;
  val = (1 + (val * 100)) > 100 ? 100 : (1 + (val * 100));
  return val * 1000; // в метрах
}

Map<double, List<double>> zoomTable = {
  13: [0, 1750],
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
