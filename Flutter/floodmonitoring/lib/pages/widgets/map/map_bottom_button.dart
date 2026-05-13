import 'package:floodmonitoring/utils/colors.dart';
import 'package:flutter/material.dart';

Widget bottomButton({
  required VoidCallback onTap,
  required String imagePath,
  required String label,
  Color iconColor = colorPrimaryDeep,
  Color buttonColor = Colors.white,
}) {
  bool isPressed = false;
  return Expanded(
    child: InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        if (isPressed) return;
        isPressed = true;
        onTap();
        Future.delayed(const Duration(milliseconds: 350), () {
          isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ColorFiltered(
                key: ValueKey(iconColor),
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                child: Image.asset(
                  imagePath,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ),
  );
}
