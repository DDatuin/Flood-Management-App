import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/pages/widgets/flood_tips/flood_tips_card.dart';
import 'package:floodmonitoring/utils/colors.dart';
import 'package:floodmonitoring/pages/widgets/components/custom_app_bar.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FloodTips extends StatefulWidget {
  const FloodTips({super.key});

  @override
  State<FloodTips> createState() => _FloodTipsState();
}

class _FloodTipsState extends State<FloodTips> {
  // ========================================
  // BUILD / CORE UI
  // ========================================

  VehicleType? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle =
        context.read<AppManager>().selectedVehicle ?? VehicleType.pedestrian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Flood Safety Tips",
        backgroundColor: colorPrimary,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          /// ----- VEHICLE SELECTION (Small buttons, scrollable) -----
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: VehicleType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final vehicle = VehicleType.values[index];
                bool isSelected = _selectedVehicle == vehicle;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVehicle = vehicle;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? colorPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? colorPrimary : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          VehicleDict.vehicleList[vehicle]!['icon-url'],
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.name,
                          style: TextStyle(
                            fontFamily: 'AvenirNext',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          /// ----- SELECTED VEHICLE CARD -----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: card(_selectedVehicle!),
            ),
          ),
        ],
      ),
    );
  }
}
