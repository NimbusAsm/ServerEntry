import 'dart:convert';

import 'package:cherrilog/cherrilog.dart';
import 'package:http/http.dart' as http;
import 'package:server_entry_dashboard/data/api_config.dart';

class ApiResolver {
  /// Appends the API token (if configured) as a query parameter to the given URL.
  static String _appendToken(String url, ApiConfig config) {
    if (config.apiToken != null && config.apiToken!.isNotEmpty) {
      var separator = url.contains('?') ? '&' : '?';
      return '$url${separator}token=${Uri.encodeQueryComponent(config.apiToken!)}';
    }
    return url;
  }

  /// Performs a GET request with optional token injection.
  static Future<String?> get(String url, {ApiConfig? config}) async {
    if (config != null) url = _appendToken(url, config);

    debug('[GET] Requested: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var body = response.body;
      debug('[GET] [200] [OK] $body');
      return body;
    } else {
      debug('[GET] [${response.statusCode}] $url');
      return null;
    }
  }

  /// Performs a POST request with JSON body and optional token injection.
  static Future<String?> post(String url, {Map<String, dynamic>? body, ApiConfig? config}) async {
    if (config != null) url = _appendToken(url, config);

    debug('[POST] Requested: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var respBody = response.body;
      debug('[POST] [${response.statusCode}] $respBody');
      return respBody;
    } else {
      debug('[POST] [${response.statusCode}] $url');
      return null;
    }
  }

  static String urlBase(ApiConfig config) {
    var protocal = config.useHttps ? 'https' : 'http';
    return '$protocal://${config.host}${config.apiPath}';
  }

  late ApiConfig apiConfig = ApiConfig();

  HardwareStatusApiResolver hardwareStatus() => HardwareStatusApiResolver()..apiConfig = apiConfig;

  DockerApiResolver docker() => DockerApiResolver()..apiConfig = apiConfig;
}

class HardwareStatusApiResolver {
  late ApiConfig apiConfig = ApiConfig();

  Future<String?> get(String? token, {String range = 'all'}) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus?range=$range';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  Future<String?> processors(String? token, {String range = 'all'}) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/Processors?range=$range';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  Future<String?> cpuUsageHistory(String? token) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/CpuUsageHistory';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  Future<String?> memory(String? token, {String range = 'all'}) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/Memory?range=$range';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  Future<String?> diskUsageHistory(String? token) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/DiskUsageHistory';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }
}

class DockerApiResolver {
  late ApiConfig apiConfig = ApiConfig();

  /// GET /Api/V1/Docker — list containers
  Future<String?> listContainers({bool all = false}) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker?all=$all';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  /// GET /Api/V1/Docker/{id} — inspect container
  Future<String?> inspectContainer(String id) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker/$id';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  /// GET /Api/V1/Docker/{id}/logs — get container logs
  Future<String?> getContainerLogs(String id, {int tail = 100}) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker/$id/Logs?tail=$tail';
    return ApiResolver.get(apiUrl, config: apiConfig);
  }

  /// POST /Api/V1/Docker/{id}/start — start container
  Future<String?> startContainer(String id) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker/$id/Start';
    return ApiResolver.post(apiUrl, config: apiConfig);
  }

  /// POST /Api/V1/Docker/{id}/stop — stop container
  Future<String?> stopContainer(String id) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker/$id/Stop';
    return ApiResolver.post(apiUrl, config: apiConfig);
  }

  /// POST /Api/V1/Docker/{id}/restart — restart container
  Future<String?> restartContainer(String id) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/Docker/$id/Restart';
    return ApiResolver.post(apiUrl, config: apiConfig);
  }
}
