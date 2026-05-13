import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FloodMap extends StatelessWidget {
  final Function(MapLibreMapController) onMapCreated;
  final Function(LatLng) onMapTap;

  final MapLibreMapController? mapController;

  final dynamic currentPosition;
  final LatLng center;
  final String styleString;

  const FloodMap({
    super.key,
    required this.onMapCreated,
    required this.onMapTap,
    required this.mapController,
    required this.currentPosition,
    required this.center,
    required this.styleString,
  });

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      onMapCreated: (controller) {
        onMapCreated(controller);

        if (currentPosition != null) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  currentPosition.latitude,
                  currentPosition.longitude,
                ),
                zoom: 17.0,
              ),
            ),
          );
        }
      },

      onMapClick: (point, latLng) {
        onMapTap(latLng);
      },

      initialCameraPosition: CameraPosition(
        target: currentPosition != null
            ? LatLng(currentPosition.latitude, currentPosition.longitude)
            : center,
        zoom: 15.0,
      ),

      styleString: styleString,

      compassEnabled: false,
      myLocationEnabled: false,
      zoomGesturesEnabled: true,
    );
  }
}
