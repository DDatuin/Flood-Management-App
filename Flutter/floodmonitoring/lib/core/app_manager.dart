import 'dart:async';
import 'package:floodmonitoring/services/location.dart';
import 'package:floodmonitoring/services/weather.dart';
import 'package:geolocator/geolocator.dart';

class AppManager {
  static final AppManager _instance = AppManager._internal();

  factory AppManager() {
    return _instance;
  }

  AppManager._internal();

  //app-level-persistent data
  String temperature = '';
  String description = '';
  String iconCode = '';
  Position? currentPosition;

  //private members
  Timer? _backendPollingTimer;

  //public functions
  void start() {
    _startPollingBackend();
  }

  void stop() {
    _backendPollingTimer?.cancel();
  }

  void dispose() {
    stop();
  }

  Future<bool> updateLocationAndWeather() async {
    final position = await LocationService.getCurrentLocation();

    if (position == null) return false;

    currentPosition = position;

    final weather = await loadWeather(position.latitude, position.longitude);

    if (weather != null) {
      temperature = weather['temperature'].toString();
      description = weather['description'];
      iconCode = weather['iconCode'];
    }

    return true;
  }

  //private functions
  void _startPollingBackend() {
    _backendPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      //polling code for extracting latest sensor data from the django backend

      print("[APP_MANAGER] Polling backend...");
    });
  }
}
