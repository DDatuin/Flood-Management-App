import 'package:floodmonitoring/core/services/category_parser.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';

Widget header(Map<String, dynamic> sensor, String selectedSensorId) {
  FloodStatusLevels parsedCat = parseFloodCat(sensor['flood_cat']);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.sensors, color: Colors.blueAccent, size: 36),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedSensorId,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Flood Monitoring Unit",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                color: FloodStatuses.floodStatuses[parsedCat]!['color'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sensor['flood_cat'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
