import 'dart:convert';
import 'package:floodmonitoring/services/api_configs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> loadWeather(
  double latitude,
  double longitude,
) async {
  try {
    final uri = Uri.parse(ApiConfig.userWeather).replace(
      queryParameters: {
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      debugPrint("Weather request failed: ${res.statusCode}");
      return null;
    }

    final body = jsonDecode(res.body);

    if (body["success"] != true) {
      debugPrint("Backend error: ${body["error"] ?? body["message"]}");
      return null;
    }

    final data = body["data"];

    return {
      "temperature": data["temperature"].toString(),
      "description": data["description"].toString(),
      "pressure": data["pressure"].toString(),
      "iconCode": data["iconCode"].toString().replaceAll(
        RegExp(r'[a-zA-Z]'),
        '',
      ),
    };
  } catch (e) {
    debugPrint("Weather fetch exception: $e");
    return null;
  }
}
