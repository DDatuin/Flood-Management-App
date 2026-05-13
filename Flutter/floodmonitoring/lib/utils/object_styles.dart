import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';

/// ----- PRIMARY BUTTON -----
Widget primaryButton({required String text, required VoidCallback onTap}) {
  return SizedBox(
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorPrimaryMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

/// ----- SECONDARY BUTTON -----
Widget secondaryButton({required String text, required VoidCallback onTap}) {
  return SizedBox(
    height: 48,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: colorPrimaryMid, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorPrimaryMid,
        ),
      ),
    ),
  );
}

Widget primaryButton2({required String text, required VoidCallback onTap}) {
  return SizedBox(
    height: 48,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}
