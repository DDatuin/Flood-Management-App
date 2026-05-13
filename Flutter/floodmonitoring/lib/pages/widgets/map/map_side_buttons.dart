import 'package:flutter/material.dart';

class MapSideButtons extends StatelessWidget {
  final VoidCallback onGoToUser;
  final VoidCallback onResetOrientation;
  final VoidCallback onOpenLayers;

  const MapSideButtons({
    super.key,
    required this.onGoToUser,
    required this.onResetOrientation,
    required this.onOpenLayers,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 5,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          /// USER LOCATION BUTTON
          ElevatedButton(
            onPressed: onGoToUser,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.15),
              minimumSize: const Size(40, 40),
            ),

            child: Center(
              child: Image.asset(
                'assets/images/icons/crosshair.png',
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// RESET ORIENTATION BUTTON
          ElevatedButton(
            onPressed: onResetOrientation,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.15),
              minimumSize: const Size(40, 40),
            ),

            child: Center(
              child: Image.asset(
                'assets/images/icons/compass.png',
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// MAP LAYERS BUTTON
          // ElevatedButton(
          //   onPressed: onOpenLayers,

          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xFF4B7BEC),
          //     padding: EdgeInsets.zero,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     elevation: 3,
          //     shadowColor: Colors.black.withOpacity(0.15),
          //     minimumSize: const Size(40, 40),
          //   ),

          //   child: Center(
          //     child: ColorFiltered(
          //       colorFilter: const ColorFilter.mode(
          //         Colors.white,
          //         BlendMode.srcIn,
          //       ),

          //       child: Image.asset(
          //         'assets/images/icons/layer.png',
          //         width: 25,
          //         height: 25,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
