import 'dart:async';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:floodmonitoring/core/services/category_parser.dart';
import 'package:floodmonitoring/utils/data_classes.dart';

bool _isToastShowing = false;

/// ----- SHOW NEAR FLOOD ALERT TOAST -----
void showNearFloodAlertToast(BuildContext context) {
  if (_isToastShowing) return;

  _isToastShowing = true;

  DelightToastBar(
    builder: (context) => ToastCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: const Text(
        "Flood area nearby",
        style: TextStyle(
          fontFamily: "AvenirNext",
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      subtitle: const Text(
        "Within 120–150 m of a flood zone.",
        style: TextStyle(
          fontFamily: "AvenirNext",
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
      color: const Color(0xFFD32F2F),
    ),
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 3),
  ).show(context);

  Timer(const Duration(seconds: 3), () {
    _isToastShowing = false;
  });
}

/// ----- SHOW SELECT VEHICLE TOAST -----
void showSelectVehicleToast(BuildContext context) {
  if (_isToastShowing) return; // 🚫 block duplicates

  _isToastShowing = true;

  DelightToastBar(
    builder: (context) => ToastCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.directions_car_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: const Text(
        "Select a vehicle to continue",
        style: TextStyle(
          fontFamily: "AvenirNext",
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      subtitle: const Text(
        "Vehicle selection is required to enable map and safety features.",
        style: TextStyle(
          fontFamily: "AvenirNext",
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
      color: const Color(0xFF1E88E5),
    ),
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 3),
  ).show(context);

  Timer(const Duration(seconds: 3), () {
    _isToastShowing = false;
  });
}

void showVehicleErrorToast(BuildContext context) {
  DelightToastBar(
    builder: (context) => ToastCard(
      leading: const Icon(Icons.error_outline, color: Colors.red, size: 28),
      title: const Text(
        "Please select a vehicle to continue",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      color: Colors.white, // background white
    ),
    autoDismiss: true,
    snackbarDuration: Durations.extralong4,
  ).show(context);
}

void showAppToast(
  BuildContext context, {
  required String message,
  required String status,
  double? distance,
}) {
  Color bgColor = FloodStatuses.floodStatuses[parseFloodCat(status)]!['color'];

  String icon = FloodStatuses.floodStatuses[parseFloodCat(status)]!['icon'];

  final displayMessage = distance != null
      ? "$message (Distance: ${distance.toStringAsFixed(1)} cm)"
      : message;

  DelightToastBar(
    builder: (context) => ToastCard(
      leading: Image.asset(icon, width: 28, height: 28, fit: BoxFit.contain),

      title: Text(
        displayMessage,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      color: bgColor,
    ),

    autoDismiss: true,
    snackbarDuration: Durations.extralong4,
  ).show(context);
}
