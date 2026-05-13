import 'package:floodmonitoring/pages/widgets/flood_tips/flood_tips_bullet_link.dart';
import 'package:floodmonitoring/pages/widgets/flood_tips/flood_tips_parser.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';

Widget card(VehicleType selectedVehicle) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${selectedVehicle.name.toUpperCase()} Tips & Safety",
          style: const TextStyle(
            fontFamily: 'AvenirNext',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        parseBoldText(
          VehicleDict.vehicleList[selectedVehicle]!['vehicle_tips'],
        ),
        const SizedBox(height: 20),

        /// Illustration
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
            image: DecorationImage(
              image: AssetImage(
                VehicleDict.vehicleList[selectedVehicle]!['stock-url'],
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Always prioritize safety. If water levels are high, wait or take alternate routes. Flooded roads can hide deep potholes, debris, or strong currents that can easily endanger lives.",
          style: TextStyle(
            fontFamily: 'AvenirNext',
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        /// ----- USEFUL RESOURCES -----
        Text(
          "Useful Resources:",
          style: const TextStyle(
            fontFamily: 'AvenirNext',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bulletLink(
              "Check if your car can handle floods (MMDA Flood Gauge)",
              "https://www.autodeal.com.ph/articles/car-features/can-your-car-handle-flood-check-mmdas-flood-gauge-first",
            ),
            bulletLink(
              "MMDA Flood Guide for motorists",
              "https://philkotse.com/market-news/mmda-flood-guide-11003",
            ),
            bulletLink(
              "MMDA Flood Gauge System explained",
              "https://interaksyon.philstar.com/trends-spotlights/2024/09/04/282826/mmda-flood-gauge-system-travelers-motorists/",
            ),
          ],
        ),
      ],
    ),
  );
}
