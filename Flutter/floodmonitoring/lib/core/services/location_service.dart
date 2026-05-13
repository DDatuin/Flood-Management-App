import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class LocationService extends ChangeNotifier {
  Position? currentPosition;
  double _userHeading = 0.0;
  double _smoothedHeading = 0.0;

  StreamSubscription<Position>? _locationSub;
  StreamSubscription<CompassEvent>? _compassSub;

  Timer? _headingSmoother;

  void start() {
    _startLocation();
    _startCompass();

    _headingSmoother = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _smoothHeading();
    });
  }

  void stop() {
    _locationSub?.cancel();
    _compassSub?.cancel();
  }

  double get smoothedHeading => _smoothedHeading;

  void _startLocation() {
    _locationSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 1,
          ),
        ).listen((pos) {
          currentPosition = pos;
          notifyListeners();
        });
  }

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;

      _userHeading = heading;
      notifyListeners();
    });
  }

  LatLng? get latLng => currentPosition == null
      ? null
      : LatLng(currentPosition!.latitude, currentPosition!.longitude);

  void _smoothHeading() {
    const double smoothFactor = 0.15;

    double diff = _userHeading - _smoothedHeading;

    // handle wrap-around (359° → 0° case)
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    _smoothedHeading += diff * smoothFactor;

    notifyListeners();
  }
}
