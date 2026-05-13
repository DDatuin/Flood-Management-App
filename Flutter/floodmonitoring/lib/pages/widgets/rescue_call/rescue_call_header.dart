import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';

Widget header() {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.local_phone, color: colorPrimary, size: 36),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Stay Safe!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'AvenirNext',
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Quick access to emergency contacts",
              style: TextStyle(color: Colors.black54, fontFamily: 'AvenirNext'),
            ),
          ],
        ),
      ),
    ],
  );
}
