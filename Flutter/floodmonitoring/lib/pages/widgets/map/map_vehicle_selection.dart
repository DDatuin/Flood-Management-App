import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';

Widget vehicleSelection({
  required String name,
  required String imagePath,
  required VoidCallback onTap,
  Color? highlightColor,
}) {
  final isSelected = false; // selectedVehicle == name;
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: colorBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueAccent.shade400,
                      Colors.lightBlue.shade300,
                    ],
                  )
                : null,
          ),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'AvenirNext',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blueAccent : Colors.black87,
          ),
        ),
      ],
    ),
  );
}
