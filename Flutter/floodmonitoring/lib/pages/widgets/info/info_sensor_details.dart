import 'package:floodmonitoring/pages/widgets/info/info_card.dart';
import 'package:floodmonitoring/pages/widgets/info/info_item.dart';
import 'package:flutter/material.dart';

Widget sensorDetails(Map<String, dynamic> sensor) {
  return card(
    "Sensor Details",
    Column(
      children: [
        item(
          "Coordinates",
          "lat: ${sensor['latlong'][0]}, lon: ${sensor['latlong'][1]}",
          null,
        ),
        item("Monitoring Radius", "${sensor['radius']} cm", null),
        item("Monitoring Height", "${sensor['distance']} cm", null),
      ],
    ),
  );
}
