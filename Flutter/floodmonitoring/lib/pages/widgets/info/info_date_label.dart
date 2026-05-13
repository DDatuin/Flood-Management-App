import 'package:flutter/material.dart';

Widget dateLabel(String text) {
  String militaryTime = text.contains(',') ? text.split(',')[1].trim() : text;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 1.5,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        militaryTime,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}
