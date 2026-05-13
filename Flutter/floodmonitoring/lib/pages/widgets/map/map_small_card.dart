import 'package:flutter/material.dart';

Widget smallCard({
  required Color color,
  required String image,
  required String text,
}) {
  return Container(
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
