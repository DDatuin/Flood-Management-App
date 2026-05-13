import 'dart:async';
import 'dart:convert';
import 'package:floodmonitoring/core/api_config.dart';
import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/core/services/sensor_service.dart';
import 'package:floodmonitoring/pages/widgets/info/info_app_bar.dart';
import 'package:floodmonitoring/pages/widgets/info/info_history_graph.dart';
import 'package:floodmonitoring/pages/widgets/info/info_live_measurements.dart';
import 'package:floodmonitoring/pages/widgets/info/info_sensor_details.dart';
import 'package:floodmonitoring/pages/widgets/info/info_weather.dart';
import 'package:floodmonitoring/pages/widgets/info/info_header.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  List<FlSpot> hourlyData = [];
  List<String> labels = ["", "", ""];

  @override
  void initState() {
    super.initState();

    final selectedSensorId = context.read<AppManager>().selectedSensorId;

    if (selectedSensorId.isEmpty) return;

    loadSensorHistoryView(selectedSensorId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ========================================
  // LOGIC / HELPER FUNCTIONS
  // ========================================

  /// ----- LOAD SENSOR HISTORY VIEW -----
  Future<void> loadSensorHistoryView(String sensorId) async {
    try {
      final url = Uri.parse(
        ApiConfig.sensorHistory,
      ).replace(queryParameters: {'id': sensorId});

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Search failed');
      }

      var data = jsonDecode(response.body);

      List<FlSpot> fetchedSpots = (data['hourlyData'] as List)
          .map((item) => FlSpot(item['x'].toDouble(), item['y'].toDouble()))
          .toList();

      setState(() {
        hourlyData = fetchedSpots;
        labels = List<String>.from(data['labels']);
      });

      print("History Loaded Successfully");
    } catch (e) {
      print("Error fetching sensor history: $e");
    }
  }

  // ========================================
  // BUILD / CORE UI
  // ========================================

  @override
  Widget build(BuildContext context) {
    final appManager = context.read<AppManager>();
    final sensorService = context.watch<SensorService>();
    String selectedSensorId = appManager.selectedSensorId;
    Map<String, dynamic> sensor =
        sensorService.latestSensorData[selectedSensorId];
    Map<String, dynamic> weather = {
      'temperature': sensor['temperature'],
      'condition': sensor['condition'],
      'pressure': sensor['pressure'],
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: customAppBar(context, "Sensor Information"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(sensor, selectedSensorId),
            const SizedBox(height: 12),
            liveMeasurements(sensor),
            const SizedBox(height: 12),
            sensorDetails(sensor),
            const SizedBox(height: 12),
            weatherSection(weather),
            const SizedBox(height: 12),
            historyGraph(hourlyData, labels),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
