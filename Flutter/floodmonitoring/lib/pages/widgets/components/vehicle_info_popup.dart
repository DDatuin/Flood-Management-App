import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/utils/colors.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:floodmonitoring/utils/object_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleInfoPopup {
  static void show(
    BuildContext context,
    VehicleType vehicleType, {
    Function()? onConfirm,
    Function()? onCancel,
  }) {
    final data = VehicleDict.vehicleList[vehicleType];
    if (data == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String selectedVehicle = vehicleType.name;
        final appManager = context.read<AppManager>();

        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        selectedVehicle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // DESCRIPTION
                      Text(
                        data['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _levelRow(
                        "Passable Categories",
                        (data['passable_flood_cat'] as List<FloodStatusLevels>)
                            .map((e) => e.name.toUpperCase())
                            .join(", "),
                        Colors.green,
                      ),

                      _levelRow(
                        "Dangerous Categories",
                        FloodStatusLevels.values
                            .where(
                              (e) =>
                                  !(data['passable_flood_cat']
                                          as List<FloodStatusLevels>)
                                      .contains(e),
                            )
                            .map((e) => e.name.toUpperCase())
                            .join(", "),
                        Colors.red,
                      ),

                      const SizedBox(height: 20),

                      // VEHICLE TYPE SELECTION FOR BICYCLE
                      if (selectedVehicle == "bicycle") ...[
                        const Text(
                          "Select Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildSelectionCard(
                              label: "2 Wheels",
                              isSelected:
                                  appManager.selectedVehicleType == "2Wheels",
                              onTap: () {
                                setState(() {
                                  vehicleType = VehicleType.bicycle;
                                  appManager.selectedVehicleType = "2Wheels";
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildSelectionCard(
                              label: "3 Wheels",
                              isSelected:
                                  appManager.selectedVehicleType == "3Wheels",
                              onTap: () {
                                setState(() {
                                  vehicleType = VehicleType.bicycle;
                                  appManager.selectedVehicleType = "3Wheels";
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // VEHICLE TYPE SELECTION FOR BICYCLE
                      if (selectedVehicle == "motorcycle") ...[
                        const Text(
                          "Select Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildSelectionCard(
                              label: "Motorcycle",
                              isSelected:
                                  appManager.selectedVehicleType ==
                                  "Motorcycle",
                              onTap: () {
                                setState(() {
                                  vehicleType = VehicleType.motorcycle;
                                  appManager.selectedVehicleType = "Motorcycle";
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildSelectionCard(
                              label: "Tricycle",
                              isSelected:
                                  appManager.selectedVehicleType == "Tricycle",
                              onTap: () {
                                setState(() {
                                  vehicleType = VehicleType.motorcycle;
                                  appManager.selectedVehicleType = "Tricycle";
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // BUTTON ROW
                      Row(
                        children: [
                          Expanded(
                            child: secondaryButton(
                              text: "CANCEL",
                              onTap: () {
                                if (onCancel != null) onCancel();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: primaryButton(
                              text: "CONFIRM",
                              onTap: () {
                                if (onConfirm != null) onConfirm();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSelectionCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          decoration: BoxDecoration(
            color: colorBackground,
            // Using a slightly larger radius for the main card for a modern look
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorPrimaryMid : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // THE OUTER CONTAINER (The Radio Border)
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  // Using 100 instead of BoxShape.circle for smoother rendering
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? colorPrimaryMid : Colors.grey[400]!,
                    width: 1.8,
                  ),
                  color: Colors.white,
                ),
                child: Center(
                  // THE INNER DOT
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isSelected ? 10 : 0,
                    width: isSelected ? 10 : 0,
                    decoration: BoxDecoration(
                      color: colorPrimaryMid,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _levelRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
