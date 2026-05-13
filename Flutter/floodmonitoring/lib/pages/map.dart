import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:floodmonitoring/core/api_config.dart';
import 'package:floodmonitoring/core/app_manager.dart';
import 'package:floodmonitoring/core/services/alert_service.dart';
import 'package:floodmonitoring/core/services/category_parser.dart';
import 'package:floodmonitoring/core/services/location.dart';
import 'package:floodmonitoring/core/services/location_service.dart';
import 'package:floodmonitoring/core/services/sensor_service.dart';
import 'package:floodmonitoring/pages/map_utils/avoid_zone_checker.dart';
import 'package:floodmonitoring/pages/map_utils/location_smoother.dart';
import 'package:floodmonitoring/pages/map_utils/offset.dart';
import 'package:floodmonitoring/pages/map_utils/open_layers.dart';
import 'package:floodmonitoring/pages/map_utils/sensors_to_gjson.dart';
import 'package:floodmonitoring/pages/map_utils/vehicle_parser.dart';
import 'package:floodmonitoring/pages/widgets/components/map_settings_popup.dart';
import 'package:floodmonitoring/pages/widgets/components/search_popup.dart';
import 'package:floodmonitoring/pages/widgets/components/toast.dart';
import 'package:floodmonitoring/pages/widgets/components/vehicle_info_popup.dart';
import 'package:floodmonitoring/pages/widgets/flood_tips/flood_tips_parser.dart';
import 'package:floodmonitoring/pages/widgets/map/map_bottom_button.dart';
import 'package:floodmonitoring/pages/widgets/map/map_bottom_mode_bar.dart';
import 'package:floodmonitoring/pages/widgets/map/map_burger_menu.dart';
import 'package:floodmonitoring/pages/widgets/map/map_info_row.dart';
import 'package:floodmonitoring/pages/widgets/map/map_main_sheet.dart';
import 'package:floodmonitoring/pages/widgets/map/map_maplibre_map.dart';
import 'package:floodmonitoring/pages/widgets/map/map_side_buttons.dart';
import 'package:floodmonitoring/pages/widgets/map/map_small_card.dart';
import 'package:floodmonitoring/pages/widgets/map/map_status_row.dart';
import 'package:floodmonitoring/pages/widgets/map/map_vehicle_selection.dart';
import 'package:floodmonitoring/utils/colors.dart';
import 'package:floodmonitoring/utils/data_classes.dart';
import 'package:floodmonitoring/utils/object_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // CONST VARIABLES
  final LatLng _CENTER = const LatLng(14.600775714641369, 121.00852660400322);

  // ========================================
  // STATE / VARIABLES
  // ========================================

  //LISTENERS
  VoidCallback? _sensorListener;
  VoidCallback? _locationListener;

  //MAP VARIABLES
  late MapLibreMapController mapController;
  bool _mapReady = false;
  final _smoother = LocationSmoother();
  bool _isZoomedTilted = false;
  DateTime _lastAlertCheck = DateTime.now();

  MapStyleType _currentMapStyle = MapStyleType.liberty;
  OverlayType _currentOverlaySelected = OverlayType.none;

  //END==============

  //SENSOR DATA
  Map<String, dynamic> _latestSensorData = {};
  String _selectedSensorId = '';

  //WEATHER CARD VARIABLES
  String _temperature = '';
  String _iconCode = '';
  String _description = '';

  //LOCATION
  LatLng? _smoothedCurrentPosition;
  double _smoothedHeading = 0.0;

  //NAVIGATION
  LocationMode? _mode;
  LatLng? _startLocationCoords;
  LatLng? _endLocationCoords;
  String _startLocationName = '';
  String _endLocationName = '';
  Map<String, dynamic>? _endMarker;
  Map<String, dynamic>? _startMarker;
  LatLng? _tempPosition;
  String? _tempName;
  Map<String, dynamic>? _tempMarker;

  //VEHICLE TYPE
  VehicleType? _selectedVehicle;
  VehicleType? _tempSelectedVehicle;
  String _selectedVehicleType = '';

  /// Direction Sheet
  bool showDirectionSheet = false;
  double directionSheetHeight = 0;
  double directionDragOffset = 0;
  final GlobalKey directionKey = GlobalKey();

  /// Sensor Sheet
  bool showSensorSheet = false;
  double sensorSheetHeight = 0;
  double sensorDragOffset = 0;
  final GlobalKey sensorKey = GlobalKey();

  /// Pin Confirmation Sheet
  bool showPinConfirmationSheet = false;
  double pinConfirmationSheetHeight = 0;
  double pinConfirmationDragOffset = 0;
  final GlobalKey pinConfirmKey = GlobalKey();

  /// Reroute Confirmation Sheet
  bool showRerouteConfirmationSheet = false;
  double rerouteConfirmationSheetHeight = 0;
  double rerouteConfirmationDragOffset = 0;
  final GlobalKey rerouteConfirmKey = GlobalKey();

  /// Main Sheet
  bool showMainSheet = true;
  double mainSheetHeight = 0;
  double mainDragOffset = 0;
  final GlobalKey mainKey = GlobalKey();

  /// Alert and Routing
  bool insideAlertZone = false;
  bool nearAlertZone = false;
  bool normalRouting = true;

  /// Time
  LatLng? savedPinPosition;

  bool displayAlert = false;
  String? addressName;

  // ========================================
  // INITIALIZATION (initState)
  // ========================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncIfPossible();
    });
  }

  @override
  void dispose() {
    final locationService = context.read<LocationService>();
    final sensorService = context.read<SensorService>();

    if (_locationListener != null) {
      locationService.removeListener(_locationListener!);
    }
    if (_sensorListener != null) {
      sensorService.removeListener(_sensorListener!);
    }
    super.dispose();
  }

  // ========================================
  // STATE / VARIABLES
  // ========================================

  /// ----- MAP CONTROLLER FUNCTIONS -----

  /// ON MAP CREATED
  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;

    final nfBytes = await rootBundle.load('assets/images/marker_nf.png');
    final patvBytes = await rootBundle.load('assets/images/marker_patv.png');
    final nplvBytes = await rootBundle.load('assets/images/marker_nplv.png');
    final npatvBytes = await rootBundle.load('assets/images/marker_npatv.png');
    final pinBytes = await rootBundle.load(
      'assets/images/selected_location.png',
    );
    final userBytes = await rootBundle.load('assets/images/user_location.png');

    await mapController.addImage("nf", nfBytes.buffer.asUint8List());
    await mapController.addImage("patv", patvBytes.buffer.asUint8List());
    await mapController.addImage("nplv", nplvBytes.buffer.asUint8List());
    await mapController.addImage("npatv", npatvBytes.buffer.asUint8List());
    await mapController.addImage("location-pin", pinBytes.buffer.asUint8List());
    await mapController.addImage("user-icon", userBytes.buffer.asUint8List());

    await mapController.addSource(
      "sensor-source",
      GeojsonSourceProperties(
        data: {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [0.0, 0.0],
              },
              "properties": {"icon": "nf", "sensorId": "init"},
            },
          ],
        },
      ),
    );

    await mapController.addSource(
      "sensor-radius-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "user-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "route-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "temp-pin-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addLayer(
      "sensor-radius-source",
      "sensor-radius-layer",
      FillLayerProperties(
        fillColor: [
          "match",
          ["get", "icon"],

          "nf",
          "#00ff00",

          "patv",
          "#0000ff",

          "nplv",
          "#ffa500",

          "npatv",
          "#ff0000",

          "#888888",
        ],

        fillOpacity: 0.30,
      ),
    );

    await mapController.addLineLayer(
      "route-source",
      "route-layer-border",
      LineLayerProperties(
        lineColor: "#000000",
        lineWidth: 8,
        lineOpacity: 0.9,
        lineCap: "round",
        lineJoin: "round",
      ),
    );

    await mapController.addLineLayer(
      "route-source",
      "route-layer-main",
      LineLayerProperties(
        lineColor: "#1E90FF",
        lineWidth: 5,
        lineOpacity: 1.0,
        lineCap: "round",
        lineJoin: "round",
      ),
    );

    await mapController.addLayer(
      "sensor-source",
      "sensor-layer",
      SymbolLayerProperties(
        iconImage: ["get", "icon"],
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
    );

    await mapController.addLayer(
      "temp-pin-source",
      "temp-pin-layer",
      SymbolLayerProperties(
        iconImage: "location-pin",
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconAnchor: "bottom",
      ),
    );

    await mapController.addLayer(
      "user-source",
      "user-layer",
      SymbolLayerProperties(
        iconImage: "user-icon",
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconRotate: ["get", "rotation"],
        iconAnchor: "bottom",
      ),
    );
    _mapReady = true;
    _bindSensorListener();
    _bindLocationListener();
    _syncIfPossible();
  }

  Future<void> _syncSensorsToMap(Map rawData) async {
    final sensors = rawData.entries.map((entry) {
      final sensorId = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final latlong = data['latlong'] as List;

      return SensorMapVisuals(
        id: sensorId,
        lat: latlong[0],
        lng: latlong[1],
        radius: (data['radius'] ?? 20).toDouble(),
        status: data['flood_cat'] ?? 'unknown',
      );
    }).toList();

    final pointGeoJson = buildSensorPoints(sensors);
    final circleGeoJson = buildSensorCircles(sensors);

    mapController.setGeoJsonSource("sensor-source", pointGeoJson);
    mapController.setGeoJsonSource("sensor-radius-source", circleGeoJson);
  }

  void _bindSensorListener() {
    final sensorService = context.read<SensorService>();

    _sensorListener = () async {
      debugPrint("Sensor listener triggered");
      await _syncIfPossible();
    };

    sensorService.addListener(_sensorListener!);
  }

  Future<void> _syncIfPossible() async {
    if (!_mapReady) {
      return;
    }

    final sensorService = context.read<SensorService>();

    _latestSensorData = sensorService.latestSensorData;
    _temperature = sensorService.temperature;
    _iconCode = sensorService.iconCode;
    _description = sensorService.description;

    await _syncSensorsToMap(_latestSensorData);
  }

  void _bindLocationListener() {
    final locationService = context.read<LocationService>();

    _locationListener = () {
      final pos = locationService.currentPosition;
      final heading = locationService.smoothedHeading;
      if (pos == null || !_mapReady) return;

      _handleLocationUpdate(pos, heading);
    };

    locationService.addListener(_locationListener!);
  }

  void _handleLocationUpdate(Position position, double heading) {
    final rawLatLng = LatLng(position.latitude, position.longitude);
    _smoothedCurrentPosition = _smoother.smoothPosition(rawLatLng);
    _smoothedHeading = heading;

    _updateUserMarker(_smoothedCurrentPosition!, _smoothedHeading);
    // _handleRouting(smooth);
    _handleAlerts(_smoothedCurrentPosition!);
  }

  void _updateUserMarker(LatLng pos, double rotation) {
    mapController.setGeoJsonSource("user-source", {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [pos.longitude, pos.latitude],
          },
          "properties": {"rotation": rotation},
        },
      ],
    });
  }

  void _handleAlerts(LatLng userPos) {
    final now = DateTime.now();
    if (now.difference(_lastAlertCheck).inMilliseconds < 500) return;
    _lastAlertCheck = now;

    if (_selectedVehicle == null) return;

    final alertService = context.read<AlertService>();

    final avoidZones = buildAvoidZonesFromSensors(
      _latestSensorData,
      _selectedVehicle!,
    );

    final inside = isInsideAvoidZone(userPos, avoidZones);
    final near = isNearAvoidZone(userPos, avoidZones);

    alertService.evaluate(inside || near);
  }

  /// ON MAP TAP
  void _onMapTap(LatLng position) async {
    setState(() {
      showMainSheet = false;
    });

    final rawPoint = await mapController.toScreenLocation(position);

    final screenPoint = Point<double>(
      rawPoint.x.toDouble(),
      rawPoint.y.toDouble(),
    );

    final sensorFeatures = await mapController.queryRenderedFeatures(
      screenPoint,
      ["sensor-layer"],
      null,
    );

    if (sensorFeatures.isNotEmpty) {
      final firstSensorFeature = sensorFeatures.first;

      _selectedSensorId = firstSensorFeature["properties"]?["sensorId"];

      setState(() {
        final appManager = context.read<AppManager>();
        appManager.selectedSensorId = _selectedSensorId;
        showDirectionSheet = false;
        cancelPinSelection();
        showSensorSheet = true;
      });
      return;
    }
  }

  /// ----- SIDE BUTTON FUNCTIONS -----
  /// GO TO USER
  void _goToUser() {
    if (_smoothedCurrentPosition == null) return;

    final userLatLng = LatLng(
      _smoothedCurrentPosition!.latitude,
      _smoothedCurrentPosition!.longitude,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLatLng, zoom: 17, tilt: 0, bearing: 0),
      ),
    );
  }

  /// RESET CAMERA ORIENTATION
  void _resetOrientation() async {
    final pos = mapController.cameraPosition;
    if (pos == null) return;

    final target = pos.target;

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: pos.zoom, tilt: 0, bearing: 0),
      ),
    );

    _isZoomedTilted = !_isZoomedTilted;

    final newCamera = CameraPosition(
      target: target,
      zoom: _isZoomedTilted ? 18 : 17,
      tilt: _isZoomedTilted ? 80 : 0,
      bearing: 0,
    );

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(newCamera),
    );
  }

  /// ----- CANCEL PIN SELECTION -----
  void cancelPinSelection() {
    setState(() {
      _endLocationCoords = null;
      _startLocationCoords = null;
      _tempPosition = null;
      _endLocationName = "";
      _startLocationName = "";
      _tempName = null;
      _endMarker = {};
      _startMarker = {};
      _tempMarker = {};
      _mode = null;

      showPinConfirmationSheet = false;
    });

    _clearRoute();
    _clearTempPins();
  }

  void _clearRoute() {
    mapController.setGeoJsonSource("route-source", {
      "type": "FeatureCollection",
      "features": [],
    });
  }

  void _clearTempPins() {
    mapController.setGeoJsonSource("temp-pin-source", {
      "type": "FeatureCollection",
      "features": [],
    });
  }

  /// ----- BUILD AVOID ZONES FROM SENSORS -----
  List<Map<String, dynamic>> buildAvoidZonesFromSensors(
    Map<String, dynamic> rawSensors,
    VehicleType vehicle,
  ) {
    final zones = <Map<String, dynamic>>[];

    final allowed =
        VehicleDict.vehicleList[vehicle]?['passable_flood_cat']
            as List<FloodStatusLevels>?;

    if (allowed == null) return zones;

    rawSensors.forEach((sensorId, data) {
      final latlong = data['latlong'] as List<dynamic>?;
      final statusRaw = data['flood_cat'];

      if (latlong == null || statusRaw == null) return;

      final status = FloodStatusLevels.values.firstWhere(
        (e) => e.name == statusRaw,
        orElse: () => FloodStatusLevels.nf,
      );

      // If vehicle CANNOT pass this flood status → it's an avoid zone
      if (!allowed.contains(status)) {
        zones.add({
          "position": LatLng(latlong[0], latlong[1]),
          "radius": data['radius'] ?? 50.0,
          "status": status,
        });
      }
    });

    return zones;
  }

  /// ----- DRAW ROUTE -----
  void _drawRoute(LatLng start, LatLng end) async {
    final vehicleConverted = convertVehicle(_selectedVehicle!);

    final url = Uri.parse(ApiConfig.safeRoute).replace(
      queryParameters: {
        'start': '${start.longitude},${start.latitude}',
        'end': '${end.longitude},${end.latitude}',
        'vehicle': vehicleConverted,
      },
    );

    debugPrint("DRAW ROUTE CALLED");
    debugPrint("START: $start");
    debugPrint("END: $end");

    final response = await http.get(url);

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode != 200) {
      debugPrint("Route request failed");
      return;
    }

    final decoded = jsonDecode(response.body);

    if (decoded["success"] != true) {
      debugPrint("Invalid route response");
      return;
    }

    final routeGeometry = decoded["route"];

    final geojson = {
      "type": "FeatureCollection",
      "features": [
        {"type": "Feature", "geometry": routeGeometry, "properties": {}},
      ],
    };

    debugPrint(jsonEncode(geojson));

    await mapController.setGeoJsonSource("route-source", geojson);
  }

  /// ----- OPEN PLACE SEARCH -----
  Future<void> openPlaceSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PlaceSearchPopup(mode: _mode),
      ),
    );

    if (result == null) return;

    final LatLng? position = result['latLng'];
    final String name = result['name'];

    _handleTempLocation(position, name);
  }

  void _handleTempLocation(LatLng? position, String name) {
    if (position == null) return;

    setState(() {
      // TEMP ONLY
      _tempPosition = position;
      _tempName = name;

      _tempMarker = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [position.longitude, position.latitude],
        },
        "properties": {"type": "temp"},
      };

      showPinConfirmationSheet = true;
    });

    _handleDestinationCamera(position);
    _updateTempPin();
  }

  void _updateTempPin() {
    if (!_mapReady) return;

    final features = <Map<String, dynamic>>[];

    if (_tempMarker != null) {
      features.add(_tempMarker!);
    }

    final start = buildPointFeature(_startLocationCoords, "start");
    final end = buildPointFeature(_endLocationCoords, "end");

    if (start != null) features.add(start);
    if (end != null) features.add(end);

    mapController.setGeoJsonSource("temp-pin-source", {
      "type": "FeatureCollection",
      "features": features,
    });
  }

  void _updateRouteView() {
    if (_startLocationCoords != null && _endLocationCoords != null) {
      _fitBothEndsToView();
      _drawRoute(_startLocationCoords!, _endLocationCoords!);
    }
  }

  /// ----- HANDLE DESTINATION CAMERA -----
  void _handleDestinationCamera(LatLng position) {
    if (_startLocationCoords != null && _endLocationCoords != null) {
      _fitBothEndsToView();
      _drawRoute(_startLocationCoords!, _endLocationCoords!);
      return;
    }
    _singleZoomToArea(position);
  }

  void _fitBothEndsToView() {
    final start = _startLocationCoords!;
    final end = _endLocationCoords!;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(start.latitude, end.latitude),
        min(start.longitude, end.longitude),
      ),
      northeast: LatLng(
        max(start.latitude, end.latitude),
        max(start.longitude, end.longitude),
      ),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 120,
        top: 120,
        right: 120,
        bottom: 120,
      ),
    );
  }

  void _singleZoomToArea(LatLng position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  Future<void> _setupMapAssets() async {
    final nfBytes = await rootBundle.load('assets/images/marker_nf.png');
    final patvBytes = await rootBundle.load('assets/images/marker_patv.png');
    final nplvBytes = await rootBundle.load('assets/images/marker_nplv.png');
    final npatvBytes = await rootBundle.load('assets/images/marker_npatv.png');
    final pinBytes = await rootBundle.load(
      'assets/images/selected_location.png',
    );
    final userBytes = await rootBundle.load('assets/images/user_location.png');

    await mapController.addImage("nf", nfBytes.buffer.asUint8List());
    await mapController.addImage("patv", patvBytes.buffer.asUint8List());
    await mapController.addImage("nplv", nplvBytes.buffer.asUint8List());
    await mapController.addImage("npatv", npatvBytes.buffer.asUint8List());
    await mapController.addImage("location-pin", pinBytes.buffer.asUint8List());
    await mapController.addImage("user-icon", userBytes.buffer.asUint8List());
  }

  Future<void> _setupSourcesAndLayers() async {
    await mapController.addSource(
      "sensor-source",
      GeojsonSourceProperties(
        data: {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [0.0, 0.0],
              },
              "properties": {"icon": "nf", "sensorId": "init"},
            },
          ],
        },
      ),
    );

    await mapController.addSource(
      "sensor-radius-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "user-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "route-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addSource(
      "temp-pin-source",
      GeojsonSourceProperties(
        data: {"type": "FeatureCollection", "features": []},
      ),
    );

    await mapController.addLayer(
      "sensor-radius-source",
      "sensor-radius-layer",
      FillLayerProperties(
        fillColor: [
          "match",
          ["get", "icon"],

          "nf",
          "#00ff00",

          "patv",
          "#0000ff",

          "nplv",
          "#ffa500",

          "npatv",
          "#ff0000",

          "#888888",
        ],

        fillOpacity: 0.30,
      ),
    );

    await mapController.addLineLayer(
      "route-source",
      "route-layer-border",
      LineLayerProperties(
        lineColor: "#000000",
        lineWidth: 8,
        lineOpacity: 0.9,
        lineCap: "round",
        lineJoin: "round",
      ),
    );

    await mapController.addLineLayer(
      "route-source",
      "route-layer-main",
      LineLayerProperties(
        lineColor: "#1E90FF",
        lineWidth: 5,
        lineOpacity: 1.0,
        lineCap: "round",
        lineJoin: "round",
      ),
    );

    await mapController.addLayer(
      "sensor-source",
      "sensor-layer",
      SymbolLayerProperties(
        iconImage: ["get", "icon"],
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
    );

    await mapController.addLayer(
      "temp-pin-source",
      "temp-pin-layer",
      SymbolLayerProperties(
        iconImage: "location-pin",
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconAnchor: "bottom",
      ),
    );

    await mapController.addLayer(
      "user-source",
      "user-layer",
      SymbolLayerProperties(
        iconImage: "user-icon",
        iconSize: 1.0,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconRotate: ["get", "rotation"],
        iconAnchor: "bottom",
      ),
    );
  }

  Future<void> _onStyleLoaded() async {
    if (mapController == null) return;

    await _setupMapAssets();
    await _setupSourcesAndLayers();

    _restoreMarkers();
    _restoreRoute();
  }

  void _restoreRoute() {
    if (_startLocationCoords != null && _endLocationCoords != null) {
      _drawRoute(_startLocationCoords!, _endLocationCoords!);
    }
  }

  void _restoreMarkers() {
    _updateTempPin();
  }

  bool showFloodZones = false;

  // ========================================
  // BUILD / CORE UI
  // ========================================

  @override
  Widget build(BuildContext context) {
    final appManager = context.watch<AppManager>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// Map Background
          MapLibreMap(
            onMapCreated: (controller) {
              _onMapCreated(controller);

              if (_smoothedCurrentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _smoothedCurrentPosition!.latitude,
                        _smoothedCurrentPosition!.longitude,
                      ),
                      zoom: 17.0,
                    ),
                  ),
                );
              }
            },

            onStyleLoadedCallback: _onStyleLoaded,

            onMapClick: (point, latLng) {
              _onMapTap(latLng);
            },

            initialCameraPosition: CameraPosition(
              target: _smoothedCurrentPosition != null
                  ? LatLng(
                      _smoothedCurrentPosition!.latitude,
                      _smoothedCurrentPosition!.longitude,
                    )
                  : _CENTER,
              zoom: 15.0,
            ),

            styleString: MapStyles.styles[appManager.currentMapStyle]!,
            compassEnabled: false,
            myLocationEnabled: false,
            zoomGesturesEnabled: true,
          ),

          ///Side Buttons
          MapSideButtons(
            onGoToUser: _goToUser,
            onResetOrientation: _resetOrientation,
            onOpenLayers: () => openLayers(context, showMainSheet),
          ),

          ///Direction Details
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: showDirectionSheet
                ? directionDragOffset
                : -directionSheetHeight,
            height: directionSheetHeight == 0 ? null : directionSheetHeight,

            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  directionDragOffset -= details.delta.dy;
                  if (directionDragOffset > 0) directionDragOffset = 0;
                  if (directionDragOffset < -directionSheetHeight) {
                    directionDragOffset = -directionSheetHeight;
                  }
                });
              },
              onVerticalDragEnd: (details) {
                if (directionDragOffset < -directionSheetHeight / 2) {
                  setState(() {
                    showDirectionSheet = false;
                    directionDragOffset = 0;
                  });
                } else {
                  setState(() {
                    directionDragOffset = 0;
                  });
                }
              },

              child: Container(
                key: directionKey,
                decoration: BoxDecoration(
                  color: colorSheet,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),

                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox =
                            directionKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox != null) {
                          final newHeight = renderBox.size.height;
                          if (directionSheetHeight != newHeight) {
                            setState(() {
                              directionSheetHeight = newHeight;
                            });
                          }
                        }
                      });

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag Handle
                          Center(
                            child: Container(
                              width: 48,
                              height: 6,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          // Header
                          Row(
                            children: [
                              Icon(
                                Icons.alt_route_rounded,
                                size: 28,
                                color: colorPrimary,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Directions",
                                    style: TextStyle(
                                      fontFamily: 'AvenirNext',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: colorTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Choose your start and destination",
                                    style: TextStyle(
                                      fontFamily: 'AvenirNext',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: colorTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Location Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorPrimaryLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                // Current Location
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _mode = LocationMode.start;
                                    });
                                    openPlaceSearch();
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Icon(
                                          (_startLocationCoords == null)
                                              ? Icons.my_location
                                              : Icons.location_on,
                                          size: 20,
                                          color: (_startLocationCoords == null)
                                              ? colorPrimary
                                              : color_npatv,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _startLocationName.isNotEmpty
                                                ? _startLocationName
                                                : (_startLocationCoords != null
                                                      ? "${_startLocationCoords!.latitude.toStringAsFixed(5)}, ${_startLocationCoords!.longitude.toStringAsFixed(5)}"
                                                      : "Select Starting Location"),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'AvenirNext',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[500],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Divider(height: 1, color: Colors.grey.shade300),

                                // Destination
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _mode = LocationMode.end;
                                    });
                                    openPlaceSearch();
                                  },
                                  child: SizedBox(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 20,
                                          color: color_npatv,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _endLocationName.isNotEmpty
                                                ? _endLocationName
                                                : (_endLocationCoords != null
                                                      ? _endLocationCoords
                                                            .toString()
                                                      : "Select Destination"),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'AvenirNext',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[500],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          ///Sensor Details
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: showSensorSheet ? sensorDragOffset : -sensorSheetHeight,
            height: sensorSheetHeight == 0 ? null : sensorSheetHeight,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  sensorDragOffset -= details.delta.dy;
                  if (sensorDragOffset > 0) sensorDragOffset = 0;
                  if (sensorDragOffset < -sensorSheetHeight) {
                    sensorDragOffset = -sensorSheetHeight;
                  }
                });
              },
              onVerticalDragEnd: (details) {
                if (sensorDragOffset < -sensorSheetHeight / 2) {
                  setState(() {
                    showSensorSheet = false;
                    sensorDragOffset = 0;
                  });
                } else {
                  setState(() {
                    sensorDragOffset = 0;
                  });
                }
              },
              child: Container(
                key: sensorKey,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox =
                            sensorKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox != null) {
                          final newHeight = renderBox.size.height;
                          if (sensorSheetHeight != newHeight) {
                            setState(() {
                              sensorSheetHeight = newHeight;
                            });
                          }
                        }
                      });

                      final sensor = _selectedSensorId.isNotEmpty
                          ? _latestSensorData[_selectedSensorId]
                          : null;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DRAG HANDLE
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // HEADER
                          Row(
                            children: [
                              Icon(
                                Icons.sensors,
                                size: 32,
                                color: colorPrimaryMid,
                              ), // primary theme
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sensor Details",
                                      style: const TextStyle(
                                        fontFamily: 'AvenirNext',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "Tap for more information",
                                      style: TextStyle(
                                        fontFamily: 'AvenirNext',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // INFO CARD
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                infoRow(
                                  "Sensor ID",
                                  _selectedSensorId.isNotEmpty
                                      ? _selectedSensorId
                                      : "-",
                                ),
                                infoRow(
                                  "Coords",
                                  sensor?['latlong'] != null
                                      ? "${sensor?['latlong']}"
                                      : "-",
                                ),
                                infoRow(
                                  "Flood Height",
                                  sensor?['wlvl_now'] != null
                                      ? "${sensor?['wlvl_now']} cm"
                                      : "-",
                                ),
                                infoRow(
                                  "Forecast",
                                  sensor?['forecast'] != null
                                      ? "${sensor?['forecast']} cm"
                                      : "-",
                                ),
                                infoRow(
                                  "Distance",
                                  sensor?['distance'] != null
                                      ? "${sensor?['distance']} cm"
                                      : "-",
                                ),
                                statusRow(
                                  "Status",
                                  sensor?['flood_cat'] != null
                                      ? "${sensor?['flood_cat']}"
                                      : "-",
                                  sensor?['flood_cat'] != null
                                      ? FloodStatuses
                                            .floodStatuses[sensor?['flood_cat']]!['color']
                                      : color_nf,
                                  sensor?['flood_cat'] != null
                                      ? FloodStatuses
                                            .floodStatuses[sensor?['flood_cat']]!['icon']
                                      : "assets/images/sensor_location.png",
                                ),
                                infoRow(
                                  "Last Update",
                                  sensor?['datetime'] != null
                                      ? "${sensor?['datetime']}"
                                      : "-",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // PRIMARY BUTTON (modern, blue theme)
                          SizedBox(
                            width: double.infinity,
                            child: primaryButton(
                              text: "View Full Details",
                              onTap: () {
                                setState(() {
                                  // sensorViewInfo = selectedSensorId!;
                                });
                                Navigator.pushNamed(context, '/info');
                              },
                            ),
                          ),

                          const SizedBox(height: 40), // padding for safe bottom
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          ///Pin Confirmation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: showPinConfirmationSheet
                ? pinConfirmationDragOffset
                : -pinConfirmationSheetHeight,
            height: pinConfirmationSheetHeight == 0
                ? null
                : pinConfirmationSheetHeight,

            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  pinConfirmationDragOffset -= details.delta.dy;
                  if (pinConfirmationDragOffset > 0)
                    pinConfirmationDragOffset = 0;
                  if (pinConfirmationDragOffset < -pinConfirmationSheetHeight) {
                    pinConfirmationDragOffset = -pinConfirmationSheetHeight;
                  }
                });
              },
              onVerticalDragEnd: (details) {
                if (pinConfirmationDragOffset <
                    -pinConfirmationSheetHeight / 2) {
                  setState(() {
                    cancelPinSelection();
                    pinConfirmationDragOffset = 0;
                  });
                } else {
                  setState(() {
                    pinConfirmationDragOffset = 0;
                  });
                }
              },

              child: Container(
                key: pinConfirmKey,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox =
                            pinConfirmKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox != null) {
                          final newHeight = renderBox.size.height;
                          if (pinConfirmationSheetHeight != newHeight) {
                            setState(() {
                              pinConfirmationSheetHeight = newHeight;
                            });
                          }
                        }
                      });

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                size: 30,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Set Pin Location",
                                      style: TextStyle(
                                        fontFamily: 'AvenirNext',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: colorTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      "Tap Confirm to set new pin location.",
                                      style: TextStyle(
                                        fontFamily: 'AvenirNext',
                                        fontSize: 13,
                                        color: Colors
                                            .grey, // same as Reroute subtitle
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: secondaryButton(
                                  text: "CANCEL",
                                  onTap: () {
                                    cancelPinSelection();
                                    _goToUser();
                                    setState(() {
                                      showPinConfirmationSheet = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: primaryButton(
                                  text: "CONFIRM",
                                  onTap: () {
                                    setState(() {
                                      if (_mode == LocationMode.end) {
                                        _endLocationCoords = _tempPosition;
                                        _endLocationName = _tempName!;
                                        _endMarker = _tempMarker!;
                                      } else if (_mode == LocationMode.start) {
                                        _startLocationCoords = _tempPosition;
                                        _startLocationName = _tempName!;
                                        _startMarker = _tempMarker!;
                                      }

                                      showPinConfirmationSheet = false;

                                      _updateTempPin();
                                      _updateRouteView();

                                      _tempPosition = null;
                                      _tempName = null;
                                      _tempMarker = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          ///Reroute Confirmation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: showRerouteConfirmationSheet
                ? rerouteConfirmationDragOffset
                : -rerouteConfirmationSheetHeight,

            height: rerouteConfirmationSheetHeight == 0
                ? null
                : rerouteConfirmationSheetHeight,

            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  rerouteConfirmationDragOffset -= details.delta.dy;

                  if (rerouteConfirmationDragOffset > 0)
                    rerouteConfirmationDragOffset = 0;
                  if (rerouteConfirmationDragOffset <
                      -rerouteConfirmationSheetHeight) {
                    rerouteConfirmationDragOffset =
                        -rerouteConfirmationSheetHeight;
                  }
                });
              },

              onVerticalDragEnd: (details) {
                if (rerouteConfirmationDragOffset <
                    -rerouteConfirmationSheetHeight / 2) {
                  setState(() {
                    showRerouteConfirmationSheet = false;
                    rerouteConfirmationDragOffset = 0;
                  });
                } else {
                  setState(() {
                    rerouteConfirmationDragOffset = 0;
                  });
                }
              },

              child: Container(
                key: rerouteConfirmKey,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox =
                            rerouteConfirmKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox != null) {
                          final newHeight = renderBox.size.height;
                          if (rerouteConfirmationSheetHeight != newHeight) {
                            setState(() {
                              rerouteConfirmationSheetHeight = newHeight;
                            });
                          }
                        }
                      });

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Icon(
                                Icons.alt_route_rounded,
                                size: 30,
                                color: colorPrimaryMid,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (_endLocationCoords != null &&
                                              _endLocationCoords != "null")
                                          ? "Route Adjustment"
                                          : "Create Reroute",
                                      style: const TextStyle(
                                        fontFamily: 'AvenirNext',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: colorTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      (_endLocationCoords != null &&
                                              _endLocationCoords != "null")
                                          ? "Confirm to generate a safer alternate path."
                                          : "Confirm to select destination to reroute",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: secondaryButton(
                                  text: "IGNORE",
                                  onTap: () {
                                    setState(() {
                                      showRerouteConfirmationSheet = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: primaryButton(
                                  text: "REROUTE",
                                  onTap: () {
                                    final hasValidPin =
                                        _endLocationCoords != null &&
                                        _endLocationCoords != "null";
                                    print("hasValidPin: $hasValidPin");
                                    setState(() {
                                      normalRouting = false;
                                      showRerouteConfirmationSheet = false;
                                    });

                                    if (!hasValidPin) {
                                      setState(() {
                                        _mode = LocationMode.end;
                                      });
                                      openPlaceSearch();
                                    } else {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _drawRoute(
                                              LatLng(
                                                _smoothedCurrentPosition!
                                                    .latitude,
                                                _smoothedCurrentPosition!
                                                    .longitude,
                                              ),
                                              _endLocationCoords!,
                                            );
                                          });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          ///Bottom Button
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Row(
              children: [
                bottomButton(
                  onTap: () {
                    setState(() {
                      showSensorSheet = false;
                      showPinConfirmationSheet = false;
                      showRerouteConfirmationSheet = false;
                      cancelPinSelection();
                      showDirectionSheet = !showDirectionSheet;
                    });
                  },
                  label: 'Directions',
                  imagePath: 'assets/images/icons/pin.png',
                  iconColor: (showDirectionSheet)
                      ? colorPrimaryMid
                      : colorPrimaryDeep,
                ),
                bottomButton(
                  onTap: () {
                    if (nearAlertZone) {
                      setState(() {
                        showSensorSheet = false;
                        showDirectionSheet = false;
                        showPinConfirmationSheet = false;
                        cancelPinSelection();
                        showRerouteConfirmationSheet =
                            !showRerouteConfirmationSheet;
                      });
                    }
                  },
                  label: 'Alerts',
                  imagePath: 'assets/images/icons/exclamation.png',
                  iconColor: (showRerouteConfirmationSheet)
                      ? colorPrimaryMid
                      : (displayAlert)
                      ? Colors.red
                      : colorPrimaryDeep,
                  buttonColor: (showRerouteConfirmationSheet)
                      ? Colors.white
                      : (displayAlert)
                      ? colorAlertBg
                      : Colors.white,
                ),
              ],
            ),
          ),

          ///Burger menu
          MapBurgerMenuButton(
            showMainSheet: showMainSheet,
            onTap: () {
              setState(() {
                showDirectionSheet = false;
                showSensorSheet = false;
                showPinConfirmationSheet = false;
                showRerouteConfirmationSheet = false;

                showMainSheet = true;
                _tempSelectedVehicle = _selectedVehicle;
                cancelPinSelection();
              });
            },
          ),

          ///Banner
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: showMainSheet ? 20 : -200,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showMainSheet ? 1 : 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueAccent.shade400,
                      Colors.lightBlue.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Flood Update\nin Your Zone',
                            style: TextStyle(
                              fontFamily: 'AvenirNext',
                              fontSize: 22,
                              fontWeight: FontWeight.w700, // Bold
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Stay alert, stay safe',
                            style: TextStyle(
                              fontFamily: 'AvenirNext',
                              fontSize: 15,
                              fontWeight: FontWeight.w500, // Medium
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Image
                    Image.asset(
                      'assets/images/Flood-amico.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Main Sheet
          if (showMainSheet)
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.45, 0.95],
              builder: (context, scrollController) {
                return GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (appManager.selectedVehicle != null) {
                      scrollController.jumpTo(
                        scrollController.offset - details.delta.dy,
                      );
                    }
                  },
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      if (appManager.selectedVehicle != null &&
                          notification.extent <= 0.25) {
                        setState(() => showMainSheet = false);
                      }
                      return true;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // clean white background
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 50,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // HEADER
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.directions_car_filled,
                                        size: 34,
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Pick a Vehicle",
                                              style: TextStyle(
                                                fontFamily: 'AvenirNext',
                                                fontSize: 20,
                                                fontWeight:
                                                    FontWeight.w700, // Bold
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "Choose from the options below",
                                              style: TextStyle(
                                                fontFamily: 'AvenirNext',
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w400, // Regular
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),

                                  // VEHICLE SELECTION
                                  SizedBox(
                                    height: 140,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          vehicleSelection(
                                            name: 'Pedestrian',
                                            imagePath:
                                                VehicleDict
                                                    .vehicleList[VehicleType
                                                    .pedestrian]!['icon-url'],
                                            highlightColor: Colors.blueAccent,
                                            onTap: () {
                                              setState(() {
                                                _tempSelectedVehicle =
                                                    _selectedVehicle;
                                                _selectedVehicle =
                                                    VehicleType.pedestrian;
                                              });

                                              VehicleInfoPopup.show(
                                                context,
                                                VehicleType.pedestrian,
                                                onConfirm: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        VehicleType.pedestrian;
                                                    appManager.selectedVehicle =
                                                        _selectedVehicle;
                                                    showMainSheet = false;
                                                    showDirectionSheet = true;
                                                    _goToUser();
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        _tempSelectedVehicle;
                                                  });
                                                },
                                              );
                                            },
                                          ),

                                          const SizedBox(width: 16),

                                          vehicleSelection(
                                            name: 'Bicycle',
                                            imagePath:
                                                VehicleDict
                                                    .vehicleList[VehicleType
                                                    .bicycle]!['icon-url'],
                                            highlightColor: Colors.blueAccent,
                                            onTap: () {
                                              setState(() {
                                                _tempSelectedVehicle =
                                                    _selectedVehicle;
                                                _selectedVehicle =
                                                    VehicleType.bicycle;
                                              });

                                              VehicleInfoPopup.show(
                                                context,
                                                VehicleType.bicycle,
                                                onConfirm: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        VehicleType.bicycle;
                                                    showMainSheet = false;
                                                    showDirectionSheet = true;
                                                    _goToUser();
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        _tempSelectedVehicle;
                                                  });
                                                },
                                              );
                                            },
                                          ),

                                          const SizedBox(width: 16),

                                          vehicleSelection(
                                            name: 'Motorcycle',
                                            imagePath:
                                                VehicleDict
                                                    .vehicleList[VehicleType
                                                    .motorcycle]!['icon-url'],
                                            highlightColor: Colors.blueAccent,
                                            onTap: () {
                                              setState(() {
                                                _tempSelectedVehicle =
                                                    _selectedVehicle;
                                                _selectedVehicle =
                                                    VehicleType.motorcycle;
                                              });

                                              VehicleInfoPopup.show(
                                                context,
                                                VehicleType.motorcycle,
                                                onConfirm: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        VehicleType.motorcycle;
                                                    showMainSheet = false;
                                                    showDirectionSheet = true;
                                                    _goToUser();
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        _tempSelectedVehicle;
                                                  });
                                                },
                                              );
                                            },
                                          ),

                                          const SizedBox(width: 16),

                                          vehicleSelection(
                                            name: 'Car',
                                            imagePath:
                                                VehicleDict
                                                    .vehicleList[VehicleType
                                                    .car]!['icon-url'],
                                            highlightColor: Colors.blueAccent,
                                            onTap: () {
                                              setState(() {
                                                _tempSelectedVehicle =
                                                    _selectedVehicle;
                                                _selectedVehicle =
                                                    VehicleType.car;
                                              });

                                              VehicleInfoPopup.show(
                                                context,
                                                VehicleType.car,
                                                onConfirm: () {
                                                  setState(() {
                                                    appManager.selectedVehicle =
                                                        VehicleType.car;
                                                    showMainSheet = false;
                                                    showDirectionSheet = true;
                                                    _goToUser();
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        _tempSelectedVehicle;
                                                  });
                                                },
                                              );
                                            },
                                          ),

                                          const SizedBox(width: 16),

                                          vehicleSelection(
                                            name: 'Truck',
                                            imagePath:
                                                VehicleDict
                                                    .vehicleList[VehicleType
                                                    .truck]!['icon-url'],
                                            highlightColor: Colors.blueAccent,
                                            onTap: () {
                                              setState(() {
                                                _tempSelectedVehicle =
                                                    _selectedVehicle;
                                                _selectedVehicle =
                                                    VehicleType.truck;
                                              });

                                              VehicleInfoPopup.show(
                                                context,
                                                VehicleType.truck,
                                                onConfirm: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        VehicleType.truck;
                                                    showMainSheet = false;
                                                    showDirectionSheet = true;
                                                    _goToUser();
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _selectedVehicle =
                                                        _tempSelectedVehicle;
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // RELATED SECTION
                                  const Text(
                                    'Related',
                                    style: TextStyle(
                                      fontFamily: 'AvenirNext',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600, // Demi
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // WEATHER CARD
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            if (_iconCode.isNotEmpty)
                                              Image.asset(
                                                'assets/images/weather/${_iconCode}.png',
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.contain,
                                              )
                                            else
                                              SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              _temperature.isNotEmpty
                                                  ? '${_temperature}°C'
                                                  : '--°C',
                                              style: const TextStyle(
                                                fontFamily: 'AvenirNext',
                                                color: Colors.blueAccent,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              _description.isNotEmpty
                                                  ? _description
                                                  : 'Loading...',
                                              style: const TextStyle(
                                                fontFamily: 'AvenirNext',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // BOTTOM CARDS
                                  Row(
                                    children: [
                                      // LEFT BIG CARD
                                      Expanded(
                                        flex: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/recent-alert',
                                            );
                                          },
                                          child: Container(
                                            height: 120,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Image.asset(
                                                    'assets/images/3d-images/bell-3d.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                const Text(
                                                  "Recent Alerts",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'AvenirNext',
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // RIGHT COLUMN
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/flood-tips',
                                                );
                                              },
                                              child: smallCard(
                                                color: Colors
                                                    .lightBlueAccent
                                                    .shade100,
                                                image:
                                                    'assets/images/3d-images/rescue-3d.png',
                                                text: "Flood Tips",
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/rescue-call',
                                                );
                                              },
                                              child: smallCard(
                                                color:
                                                    Colors.blueAccent.shade100,
                                                image:
                                                    'assets/images/3d-images/help-3d.png',
                                                text: "Rescue Call",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    indent: 20,
                                    endIndent: 20,
                                  ),
                                  const SizedBox(height: 30),

                                  primaryButton(
                                    text: "Clear Route",
                                    onTap: () {
                                      setState(() {
                                        _endLocationCoords = null;
                                        _startLocationCoords = null;
                                        _tempPosition = null;
                                        _endLocationName = "";
                                        _startLocationName = "";
                                        _tempName = null;
                                        _endMarker = {};
                                        _startMarker = {};
                                        _tempMarker = {};
                                        _mode = null;
                                        _clearRoute();
                                        _clearTempPins();
                                        showMainSheet = false;
                                        showDirectionSheet = true;

                                        _goToUser();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  primaryButton2(
                                    text: "Leave Navigation",
                                    onTap: () {
                                      SystemNavigator.pop();
                                    },
                                  ),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          Consumer<AlertService>(
            builder: (context, alertService, _) {
              if (alertService.nearAlertZone && alertService.toastShown) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showNearFloodAlertToast(context);
                });
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
