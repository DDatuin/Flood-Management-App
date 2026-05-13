class ApiConfig {
  static const String baseUrl =
      'https://fdwdjangobackend-production.up.railway.app';

  static const String latestData = '$baseUrl/api/latest-data/';

  static const String locationSearch = '$baseUrl/api/location-search';

  static const String sensorHistory = '$baseUrl/api/get-history';

  static const String safeRoute = '$baseUrl/api/get-route';
}
