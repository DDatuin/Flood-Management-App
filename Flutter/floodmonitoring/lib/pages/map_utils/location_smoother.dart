import 'package:maplibre_gl/maplibre_gl.dart';

class LocationSmoother {
  LatLng? _smoothedLatLng;

  LatLng smoothPosition(LatLng newPosition) {
    const double smoothFactor = 0.2;

    if (_smoothedLatLng == null) {
      _smoothedLatLng = newPosition;
      return newPosition;
    }

    final lat =
        _smoothedLatLng!.latitude +
        (newPosition.latitude - _smoothedLatLng!.latitude) * smoothFactor;

    final lng =
        _smoothedLatLng!.longitude +
        (newPosition.longitude - _smoothedLatLng!.longitude) * smoothFactor;

    _smoothedLatLng = LatLng(lat, lng);

    return _smoothedLatLng!;
  }
}
