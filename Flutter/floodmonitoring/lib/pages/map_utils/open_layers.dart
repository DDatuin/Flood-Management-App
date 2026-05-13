import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/pages/widgets/components/map_settings_popup.dart';
import 'package:floodmonitoring/pages/widgets/components/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void openLayers(BuildContext context, bool showMainSheet) {
  final appManager = context.read<AppManager>();

  if (showMainSheet && appManager.selectedVehicle == null) {
    showSelectVehicleToast(context);
    return;
  }

  showMapSettingsPopup(
    context,
    initialMapStyle: appManager.currentMapStyle,
    initialOverlay: appManager.currentOverlaySelected,
    onConfirm: (selectedMapType, selectedLayer) {
      appManager.currentMapStyle = selectedMapType;
      appManager.currentOverlaySelected = selectedLayer;
    },
  );
}
