import 'package:floodmonitoring/pages/widgets/map/map_bottom_button.dart';
import 'package:flutter/material.dart';

class MapBottomModeBar extends StatelessWidget {
  final bool showDirectionSheet;
  final bool showRerouteConfirmationSheet;
  final bool nearAlertZone;
  final bool displayAlert;

  final VoidCallback onToggleDirections;
  final VoidCallback onToggleAlerts;

  const MapBottomModeBar({
    super.key,
    required this.showDirectionSheet,
    required this.showRerouteConfirmationSheet,
    required this.nearAlertZone,
    required this.displayAlert,
    required this.onToggleDirections,
    required this.onToggleAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -5,
      left: 0,
      right: 0,
      child: Row(
        children: [
          bottomButton(
            onTap: onToggleDirections,
            label: 'Directions',
            imagePath: 'assets/images/icons/pin.png',
            iconColor: showDirectionSheet ? Colors.blue : Colors.grey,
          ),

          bottomButton(
            onTap: onToggleAlerts,
            label: 'Alerts',
            imagePath: 'assets/images/icons/exclamation.png',
            iconColor: showRerouteConfirmationSheet
                ? Colors.blue
                : (displayAlert ? Colors.red : Colors.grey),
            buttonColor: showRerouteConfirmationSheet
                ? Colors.white
                : (displayAlert ? Colors.red.shade100 : Colors.white),
          ),
        ],
      ),
    );
  }
}
