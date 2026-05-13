import 'dart:math';

import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

Map<String, dynamic> buildSensorPoints(List<SensorMapVisuals> sensors) {
  return {
    "type": "FeatureCollection",
    "features": sensors.map((s) {
      return {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [s.lng, s.lat],
        },
        "properties": {"icon": s.status, "sensorId": s.id},
      };
    }).toList(),
  };
}

Map<String, dynamic> buildSensorCircles(List<SensorMapVisuals> sensors) {
  return {
    "type": "FeatureCollection",
    "features": sensors.map((s) {
      return {
        "type": "Feature",
        "geometry": createCirclePolygon(s.lat, s.lng, s.radius),
        "properties": {"icon": s.status, "sensorId": s.id},
      };
    }).toList(),
  };
}

Map<String, dynamic> createCirclePolygon(
  double lat,
  double lng,
  double radiusCentimeters, {
  int points = 64,
}) {
  double radiusMeters = radiusCentimeters / 100;
  const earthRadius = 6371000.0;

  final List<List<List<double>>> coords = [];
  final List<List<double>> circlePoints = [];

  for (int i = 0; i <= points; i++) {
    final angle = 2 * 3.141592653589793 * i / points;

    final dx = radiusMeters * cos(angle);
    final dy = radiusMeters * sin(angle);

    final newLat = lat + (dy / earthRadius) * (180 / 3.141592653589793);

    final newLng =
        lng +
        (dx / earthRadius) *
            (180 / 3.141592653589793) /
            cos(lat * 3.141592653589793 / 180);

    circlePoints.add([newLng, newLat]);
  }

  coords.add(circlePoints);

  return {"type": "Polygon", "coordinates": coords};
}

Map<String, dynamic>? buildPointFeature(LatLng? pos, String type) {
  if (pos == null) return null;

  return {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [pos.longitude, pos.latitude],
    },
    "properties": {"type": type},
  };
}
