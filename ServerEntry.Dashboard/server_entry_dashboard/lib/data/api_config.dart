class ApiConfig {
  late String host = '${Uri.base.host}:5111';

  late String apiPath = '/Api/V1';

  late bool useHttps = false;

  /// API token for mutating operations (POST/PUT/DELETE).
  /// When set, it will be appended as ?token= query parameter to all API requests.
  late String? apiToken;
}
