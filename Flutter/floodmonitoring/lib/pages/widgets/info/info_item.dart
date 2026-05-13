import 'package:flutter/material.dart';

Widget item(String name, String value, Color? color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    ),
  );
}
