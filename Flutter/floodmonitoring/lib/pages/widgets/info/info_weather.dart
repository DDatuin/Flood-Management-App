import 'package:floodmonitoring/pages/widgets/info/info_card.dart';
import 'package:floodmonitoring/pages/widgets/info/info_item.dart';
import 'package:flutter/material.dart';

Widget weatherSection(Map<String, dynamic> weather) {
  return card(
    "Weather",
    Column(
      children: [
        item("Temperature", "${weather['temperature']}°C", null),
        item("Condition", "${weather['description']}", null),
        item("Pressure", "${weather['pressure']} hPa", null),
      ],
    ),
  );
}
