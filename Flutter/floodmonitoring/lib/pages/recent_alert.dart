import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/core/services/category_parser.dart';
import 'package:floodmonitoring/core/services/sensor_service.dart';
import 'package:floodmonitoring/pages/widgets/components/custom_app_bar.dart';
import 'package:floodmonitoring/utils/colors.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentAlert extends StatefulWidget {
  const RecentAlert({super.key});

  @override
  State<RecentAlert> createState() => _RecentAlertState();
}

class _RecentAlertState extends State<RecentAlert> {
  @override
  Widget build(BuildContext context) {
    final appManager = context.read<AppManager>();
    final sensorData = context.watch<SensorService>().latestSensorData;
    final vehicle = appManager.selectedVehicle;

    final alerts = sensorData.entries.map((entry) {
      final sensorId = entry.key;
      final data = entry.value;

      return {
        "id": sensorId,
        "location": "Sensor $sensorId",
        "status": parseFloodCat(data["flood_cat"]),
        "level": data["wlvl_now"]?.toString() ?? "-",
        "forecast": data["forecast"]?.toString() ?? "-",
        "latlong": data["latlong"]?.toString() ?? "-",
      };
    }).toList();

    final raw = VehicleDict.vehicleList[vehicle]?['passable_flood_cat'];
    final passable = (raw is List)
        ? raw.cast<FloodStatusLevels>()
        : <FloodStatusLevels>[];

    final activeAlerts = alerts.where((a) {
      final status = a['status'] as FloodStatusLevels;
      return !passable.contains(status);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Recent Alerts",
        backgroundColor: themeBlue,
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: activeAlerts.isEmpty
            ? Center(
                child: Text(
                  "No active alerts",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'AvenirNext',
                  ),
                ),
              )
            : ListView.builder(
                itemCount: activeAlerts.length,
                itemBuilder: (context, index) {
                  final alert = activeAlerts[index];
                  return _alertCard(alert);
                },
              ),
      ),
    );
  }

  // ========================================
  // UI WIDGETS
  // ========================================

  /// ----- ALERT CARD -----
  Widget _alertCard(Map<String, dynamic> alert) {
    final Color statusColor =
        FloodStatuses.floodStatuses[alert['status']]!['color'];
    final Widget statusIcon = Image.asset(
      FloodStatuses.floodStatuses[alert['status']]!['icon'],
      width: 28,
      height: 28,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['location'] ?? "-",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AvenirNext',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert['forecast'] ?? "-",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'AvenirNext',
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: statusIcon,
          ),
        ],
      ),
    );
  }
}
