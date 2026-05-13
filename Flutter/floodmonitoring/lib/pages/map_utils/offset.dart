import 'package:maplibre_gl/maplibre_gl.dart';

LatLng offsetPosition(LatLng original, double offsetInDegrees) {
  return LatLng(original.latitude - offsetInDegrees, original.longitude);
}
