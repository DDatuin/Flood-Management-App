import 'dart:async';
import 'dart:convert';
import 'package:floodmonitoring/services/api_configs.dart';
import 'package:floodmonitoring/services/global.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SensorService {
  final StreamController<void> _sensorStreamController =
      StreamController<void>.broadcast();
  Stream<void> get stream => _sensorStreamController.stream;

  bool _connected = false;
  bool get isConnected => _connected;
  StreamSubscription<String>? _subscription;

  SensorService._();
  static final SensorService instance = SensorService._();

  final Map<String, Map<String, dynamic>> sensors = {};

  void connect({
    Function()? onConnected,
    Function(dynamic error)? onError,
  }) async {
    debugPrint("CONNECT() CALLED");

    if (_connected) return;
    final request = http.Request("GET", Uri.parse(ApiConfig.sensorStream));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Unable to connect to SSE");
    }

    _connected = true;

    onConnected?.call();

    _subscription = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.startsWith("data: ")) {
              final jsonData = jsonDecode(line.substring(6));

              final parsed = parseSensors(jsonData["data"]);
              sensors
                ..clear()
                ..addAll(parsed);

              _sensorStreamController.add(null);
            }
          },
          onError: (exception) {
            debugPrint("SSE Error: $exception");
            _connected = false;
            onError?.call(exception);
          },
          onDone: () {
            debugPrint("SSE Closed");
            _connected = false;
          },
          cancelOnError: false,
        );
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _connected = false;
  }

  void dispose() {
    _sensorStreamController.close();
  }

  Future<void> loadInitialSensors() async {
    final sensorData = await _loadSensorsFromAPI();

    sensors
      ..clear()
      ..addAll(sensorData);

    _sensorStreamController.add(null);
  }

  Map<String, Map<String, dynamic>> parseSensors(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> tempSensors = {};

    data.forEach((sensorId, item) {
      final floodHeight = double.tryParse(item["wlvl_now"].toString()) ?? 0.0;
      final forecastHeight =
          double.tryParse(item["forecast"].toString()) ?? 0.0;

      final status = getStatusText(floodHeight);
      final forecastStatus = getStatusText(forecastHeight);

      tempSensors[sensorId] = {
        "position": LatLng(
          double.parse(item["latlong"][0].toString()),
          double.parse(item["latlong"][1].toString()),
        ),
        "radius": double.parse(item["radius"].toString()),
        "height": double.parse(item["ground_distance"].toString()),
        "location": item["location_name"].toString(),

        "sensorData": {
          "distance": 0.0,
          "floodHeight": floodHeight,
          "floodCatNow": item['flood_cat_now'].toString(),
          "forecast": forecastHeight,
          "floodForecastCat": item['flood_cat'].toString(),
          "status": (status.isNotEmpty) ? status : "Loading...",
          "forecastedStatus": (forecastStatus.isNotEmpty)
              ? forecastStatus
              : "Loading...",
          "lastUpdate": item['datetime'].toString(),
        },

        "weatherData": {
          "temperature": item['temperature'].toString(),
          "description": item['description'].toString(),
          "pressure": item['pressure'].toString(),
        },
      };
    });

    return tempSensors;
  }

  static String getStatusText(double floodHeightCm) {
    if (selectedVehicle.isEmpty) return "";

    final vehicleThreshold = vehicleFloodThresholds.firstWhere(
      (v) => v["vehicle"] == selectedVehicle,
      orElse: () => vehicleFloodThresholds[0],
    );

    if (floodHeightCm <= vehicleThreshold["safeRange_cm"][1]) {
      return 'Safe';
    } else if (floodHeightCm <= vehicleThreshold["warningRange_cm"][1]) {
      return 'Warning';
    } else {
      return 'Danger';
    }
  }

  void refreshStatuses() {
    sensors.forEach((_, sensor) {
      final sensorData = sensor["sensorData"];

      final floodHeight = (sensorData["floodHeight"] as num).toDouble();

      final forecast = (sensorData["forecast"] as num).toDouble();

      sensorData["status"] = getStatusText(floodHeight);

      sensorData["forecastedStatus"] = getStatusText(forecast);
    });

    _sensorStreamController.add(null);
  }

  Future<Map<String, Map<String, dynamic>>> _loadSensorsFromAPI() async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.latestData));

      if (res.statusCode != 200) {
        return {};
      }

      final response = jsonDecode(res.body);

      if (response["success"] != true) {
        return {};
      }

      return parseSensors(response["data"]);
    } catch (e) {
      debugPrint("Error fethcing sensors: $e");
      return {};
    }
  }
}
