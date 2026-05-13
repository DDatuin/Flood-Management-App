import 'package:flutter/material.dart';

Widget statusRow(String label, String value, Color color, String iconUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(iconUrl, width: 16, height: 16, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    ),
  );
}
