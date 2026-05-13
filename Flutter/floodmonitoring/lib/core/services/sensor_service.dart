import 'dart:async';
import 'dart:convert';
import 'package:floodmonitoring/core/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorService extends ChangeNotifier {
  final String apiUrl = ApiConfig.latestData;

  Map<String, dynamic> latestSensorData = {};

  String temperature = '';
  String description = '';
  String iconCode = '';

  Timer? _timer;

  void start() {
    debugPrint("Sensor data initiated polling.");
    _poll();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _poll() async {
    debugPrint("Polling triggered");

    try {
      final res = await http.get(Uri.parse(apiUrl));

      debugPrint("STATUS CODE: ${res.statusCode}");
      debugPrint("BODY: ${res.body}");

      if (res.statusCode != 200) {
        debugPrint("Sensor data not retrieved.");
        return;
      }

      final decoded = jsonDecode(res.body);

      latestSensorData = decoded['forecasts'] ?? {};

      if (latestSensorData.isNotEmpty) {
        final firstSensor =
            latestSensorData.values.first as Map<String, dynamic>;

        temperature = firstSensor['temperature']?.toString() ?? '';
        description = firstSensor['description'] ?? '';
        iconCode = firstSensor['iconCode'] ?? '';
        debugPrint("""
          TEMPERATURE = ${temperature}, DESCRIPTION = ${description}, CODE = ${iconCode}
        """);
      }

      notifyListeners();

      debugPrint("Sensor data secured.");
    } catch (e, st) {
      debugPrint("ERROR: $e");
      debugPrint("$st");
    }
  }
}
