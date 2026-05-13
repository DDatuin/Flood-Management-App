import 'package:floodmonitoring/core/services/location.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';

import 'package:maplibre_gl/maplibre_gl.dart';

class AppManager extends ChangeNotifier {
  MapStyleType currentMapStyle = MapStyleType.liberty;
  OverlayType currentOverlaySelected = OverlayType.none;

  VehicleType? selectedVehicle;
  String selectedVehicleType = '';

  String startLocationName = '';
  String endLocationName = '';

  LatLng? startLocationCoords;
  LatLng? endLocationCoords;

  bool selectingStartLocation = false;
  bool selectingEndLocation = false;

  String selectedSensorId = '';

  void start() async {
    final ok = await LocationServicePermission.ensureLocationReady();

    if (!ok) {
      print("Location permission not granted");
      return;
    }

    print("Location permitted, starting services.");
  }

  void setEndLocation(LatLng position) {
    selectingEndLocation = true;
    endLocationCoords = position;
  }

  void setMapStyle(MapStyleType style) {
    currentMapStyle = style;
    notifyListeners();
  }

  void setOverlay(OverlayType overlay) {
    currentOverlaySelected = overlay;
    notifyListeners();
  }
}
