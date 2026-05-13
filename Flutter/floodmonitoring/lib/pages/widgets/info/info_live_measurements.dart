import 'package:floodmonitoring/core/services/category_parser.dart';
import 'package:floodmonitoring/pages/widgets/info/info_card.dart';
import 'package:floodmonitoring/pages/widgets/info/info_item.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';

Widget liveMeasurements(Map<String, dynamic> sensor) {
  FloodStatusLevels parsedCat = parseFloodCat(sensor['flood_cat']);

  return card(
    "Live Measurements",
    Column(
      children: [
        item("Flood Height", "${sensor['wlvl_now']} cm", null),
        item("Forecast (5-mins-ahead)", "${sensor['forecast']} cm", null),
        item(
          "Forecasted Status",
          sensor['flood_cat'],
          FloodStatuses.floodStatuses[parsedCat]!['color'],
        ),
        item("Last Update", sensor['datetime'], null),
      ],
    ),
  );
}
