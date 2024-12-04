import 'dart:convert';
import 'dart:io';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:leak_guard/utils/strings.dart';

// TODO: Make all endpoints return type, message if the request was successful or not

class CustomApi {
  static final CustomApi _instance = CustomApi._internal();
  final HttpClient _client;

  factory CustomApi() {
    return _instance;
  }

  CustomApi._internal() : _client = HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 2);
  }

  String _user = "root";
  String _password = "admin1";

  // TODO: make it return response
  Future<Map<String, dynamic>?> _makeRequest(
    String ip,
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    int port = ip == MyStrings.mockIp ? 8000 : 80;
    if (ip == "localhost") {
      return null;
    }

    try {
      late HttpClientRequest request;

      switch (method) {
        case 'GET':
          request = await _client.get(ip, port, path);
          break;
        case 'POST':
          request = await _client.post(ip, port, path);
          break;
        case 'PUT':
          request = await _client.put(ip, port, path);
          break;
        case 'DELETE':
          request = await _client.delete(ip, port, path);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      request.headers.set('Authorization',
          'Basic ${base64Encode(utf8.encode('$_user:$_password'))}');

      if (body != null) {
        request.headers.contentType = ContentType.json;
        String bodyString = jsonEncode(body);
        request.headers.contentLength = utf8.encode(bodyString).length;
        request.write(bodyString);
        print('Request body: $bodyString');
      }

      final response = await request.close();
      final content = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (content.isNotEmpty) {
          return jsonDecode(content);
        }
        return {"message": "Request successful"};
      }
      throw HttpException('Request failed with status: ${response.statusCode}');
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Config endpoints
  //TODO: Implement all the config endpoints
  Future<Map<String, dynamic>?> getConfig(String ip) async {
    return await _makeRequest(ip, '/config');
  }

  Future<bool> putConfig(String ip, Map<String, dynamic> config) async {
    final response =
        await _makeRequest(ip, '/config', method: 'PUT', body: config);
    return response != null;
  }

  // Water usage endpoints
  //TODO: Make it return double
  Future<Map<String, dynamic>?> getWaterUsage(String ip) async {
    return await _makeRequest(ip, '/water-usage');
  }

  //TODO: Make it return List<Flow>
  Future<Map<String, dynamic>?> getWaterUsageRange(
    String ip,
    DateTime fromTimestamp,
    DateTime toTimestamp,
  ) async {
    final path =
        '/water-usage/${fromTimestamp.millisecondsSinceEpoch}/${toTimestamp.millisecondsSinceEpoch}';
    return await _makeRequest(ip, path);
  }

  //TODO: Make it return double
  Future<Map<String, dynamic>?> getWaterUsageToday(String ip) async {
    return await _makeRequest(ip, '/water-usage/today');
  }

  // TODO: Probe endpoints, GET, PUT and DELETE

  // Probe pairing endpoints
  // TODO: 403 means already in paring mode.
  // TODO: if 403 return true <- already in pairing mode
  Future<bool> enterPairingMode(String ip) async {
    final response = await _makeRequest(
      ip,
      '/probe/pair/enter',
      method: 'POST',
    );
    return response != null;
  }

  Future<bool> exitPairingMode(String ip) async {
    final response = await _makeRequest(
      ip,
      '/probe/pair/exit',
      method: 'POST',
    );
    return response != null;
  }

  // TODO: Make it return bool
  Future<Map<String, dynamic>?> getWaterBlock(String ip) async {
    return await _makeRequest(ip, '/water-block');
  }

  Future<bool> postWaterBlock(String ip, Map<String, dynamic> blockData) async {
    final response = await _makeRequest(
      ip,
      '/water-block',
      method: 'POST',
      body: blockData,
    );
    return response != null;
  }

  // TODO: Make it return List<List<int>>
  Future<Map<String, dynamic>?> getWaterBlockSchedule(String ip) async {
    return await _makeRequest(ip, '/water-block/schedule');
  }

  Future<bool> postWaterBlockSchedule(
    String ip,
    Map<String, dynamic> scheduleData,
  ) async {
    final response = await _makeRequest(
      ip,
      '/water-block/schedule',
      method: 'POST',
      body: scheduleData,
    );
    return response != null;
  }

  // TODO: wait for documentation
  Future<Map<String, dynamic>?> getCriteria(String ip) async {
    return await _makeRequest(ip, '/criteria');
  }

  Future<bool> postCriteria(String ip, Map<String, dynamic> criteria) async {
    final response = await _makeRequest(
      ip,
      '/criteria',
      method: 'POST',
      body: criteria,
    );
    return response != null;
  }

  //TODO: Wait for documentation
  Future<Map<String, dynamic>?> getCriterion(String ip, String id) async {
    return await _makeRequest(ip, '/criteria/$id');
  }

  // MAC Address endpoint (already implemented)
  Future<String?> getCentralMacAddress(String ip) async {
    int port = ip == MyStrings.mockIp ? 8000 : 80;

    try {
      final request = await _client.get(ip, port, '/me');
      final response = await request.close();
      final content = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(content);
        return data['mac'] as String;
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
