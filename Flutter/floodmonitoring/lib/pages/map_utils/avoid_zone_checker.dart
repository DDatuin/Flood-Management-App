import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

bool isInsideAvoidZone(
  LatLng usersPosition,
  List<Map<String, dynamic>> avoidZones,
) {
  for (var zone in avoidZones) {
    LatLng zoneCenter = zone["position"];
    double radius = zone["radius"] / 100;

    double distance = Geolocator.distanceBetween(
      usersPosition.latitude,
      usersPosition.longitude,
      zoneCenter.latitude,
      zoneCenter.longitude,
    );

    if (distance <= radius) {
      return true;
    }
  }
  return false;
}

bool isNearAvoidZone(
  LatLng usersPosition,
  List<Map<String, dynamic>> avoidZones,
) {
  for (var zone in avoidZones) {
    LatLng zoneCenter = zone["position"];
    double radius = zone["radius"] / 100;

    double distance = Geolocator.distanceBetween(
      usersPosition.latitude,
      usersPosition.longitude,
      zoneCenter.latitude,
      zoneCenter.longitude,
    );

    if (distance <= radius + 500) {
      return true;
    }
  }
  return false;
}
