import 'package:cherrilog/cherrilog.dart';
import 'package:http/http.dart' as http;
import 'package:server_entry_dashboard/data/api_config.dart';

class ApiResolver {
  static Future<String?> get(String url) async {
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

  static String urlBase(ApiConfig config) {
    var protocal = config.useHttps ? 'https' : 'http';
    return '$protocal://${config.host}${config.apiPath}';
  }

  late ApiConfig apiConfig = ApiConfig();

  HardwareStatusApiResolver hardwareStatus() => HardwareStatusApiResolver()..apiConfig = apiConfig;
}

class HardwareStatusApiResolver {
  late ApiConfig apiConfig = ApiConfig();

  Future<String?> get(String? token) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/';
    return ApiResolver.get(apiUrl);
  }

  Future<String?> processors(String? token) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/Processors';
    return ApiResolver.get(apiUrl);
  }

  Future<String?> memoryInfo(String? token) {
    var apiUrl = '${ApiResolver.urlBase(apiConfig)}/HardwareStatus/Memory';
    return ApiResolver.get(apiUrl);
  }
}
