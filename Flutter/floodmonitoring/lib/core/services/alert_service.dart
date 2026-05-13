import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class AlertService extends ChangeNotifier {
  bool nearAlertZone = false;
  bool displayAlert = false;

  bool _toastShown = false;

  Timer? _blinkTimer;
  Timer? _autoStopTimer;

  bool get toastShown => _toastShown;

  void evaluate(bool insideOrNear) {
    if (insideOrNear) {
      start();
    } else {
      stop();
    }
  }

  void start() {
    if (nearAlertZone) return;

    nearAlertZone = true;
    displayAlert = true;

    if (!_toastShown) {
      _toastShown = true;
    }

    notifyListeners();

    Vibration.vibrate(duration: 100, amplitude: 255);

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      displayAlert = !displayAlert;
      notifyListeners();
    });

    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(const Duration(minutes: 5), stop);
  }

  void stop() {
    nearAlertZone = false;
    displayAlert = false;

    _blinkTimer?.cancel();
    _autoStopTimer?.cancel();

    notifyListeners();
  }
}
