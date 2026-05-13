import 'package:floodmonitoring/utils/data_classes.dart';

String convertVehicle(VehicleType selectedVehicle) {
  String vehicleString = '';

  switch (selectedVehicle) {
    case VehicleType.pedestrian:
      vehicleString = 'foot-walking';
      break;
    case VehicleType.bicycle:
      vehicleString = 'cycling-road';
      break;
    case VehicleType.motorcycle:
      vehicleString = 'driving-car';
      break;
    case VehicleType.car:
      vehicleString = 'driving-car';
      break;
    case VehicleType.truck:
      vehicleString = 'driving-hgv';
      break;
  }

  return vehicleString;
}
