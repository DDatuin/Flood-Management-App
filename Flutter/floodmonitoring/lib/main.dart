import 'package:floodmonitoring/core/services/alert_service.dart';
import 'package:floodmonitoring/core/services/location_service.dart';
import 'package:floodmonitoring/core/services/sensor_service.dart';
import 'package:floodmonitoring/pages/flood_tips.dart';
import 'package:floodmonitoring/pages/info.dart';
import 'package:floodmonitoring/pages/map.dart';
import 'package:floodmonitoring/pages/recent_alert.dart';
import 'package:floodmonitoring/pages/rescue_call.dart';
import 'package:floodmonitoring/core/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final sensorService = SensorService();
  final locationService = LocationService();
  final alertService = AlertService();
  final appManager = AppManager();

  appManager.start();
  locationService.start();
  sensorService.start();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppManager>.value(value: appManager),
        ChangeNotifierProvider<SensorService>.value(value: sensorService),
        ChangeNotifierProvider<LocationService>.value(value: locationService),
        ChangeNotifierProvider<AlertService>.value(value: alertService),
      ],
      child: MaterialApp(
        initialRoute: '/map',
        routes: {
          '/map': (context) => MapScreen(),
          '/info': (context) => Info(),
          '/recent-alert': (context) => RecentAlert(),
          '/flood-tips': (context) => FloodTips(),
          '/rescue-call': (context) => RescueCall(),
        },
      ),
    ),
  );
}
