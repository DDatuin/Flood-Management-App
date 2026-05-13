import 'package:flutter/material.dart';

Widget customAppBar(BuildContext context, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'AvenirNext',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
