import 'dart:convert';
import 'dart:io';
import 'package:leak_guard/models/block_schedule.dart';
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

  Future<Map<String, dynamic>?> _makeRequest(
    String ip,
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    if (ip == MyStrings.mockIp) ip = MyStrings.myIp;

    int port = ip == MyStrings.myIp ? 8000 : 80;

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

      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 409) {
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

  Future<double?> getWaterUsage(String ip) async {
    final result = await _makeRequest(ip, '/water-usage');
    print(result);
    if (result == null) return null;
    return (result['flow_rate'] as int) / 1000.0;
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

  Future<double?> getWaterUsageToday(String ip) async {
    //TODO: If implemented remove next line
    ip = MyStrings.myIp;
    final result = await _makeRequest(ip, '/water-usage');
    print(result);
    if (result == null) return null;
    return (result['today_volume'] as int) / 1000.0;
  }

  // TODO: Probe endpoints, GET, PUT and DELETE

  // Probe pairing endpoints
  Future<bool> enterPairingMode(String ip) async {
    final response = await _makeRequest(
      ip,
      '/probe/pair/enter',
      method: 'POST',
    );
    return response != null;
  }

  Future<bool?> getParingMode(String ip) async {
    final response = await _makeRequest(
      ip,
      '/probe/pair',
      method: 'GET',
    );
    if (response == null) return null;

    return response['pairing'] as bool;
  }

  Future<bool> exitPairingMode(String ip) async {
    final response = await _makeRequest(
      ip,
      '/probe/pair/exit',
      method: 'POST',
    );
    return response != null;
  }

  Future<bool?> getWaterBlock(String ip) async {
    //TODO: If implemented remove next line
    ip = MyStrings.myIp;

    final result = await _makeRequest(ip, '/water-block');
    print(result);
    if (result == null) return null;
    return result['block'] == "active";
  }

  //TODO:
  Future<bool> postWaterBlock(String ip, Map<String, dynamic> blockData) async {
    final response = await _makeRequest(
      ip,
      '/water-block',
      method: 'POST',
      body: blockData,
    );
    return response != null;
  }

  Future<BlockSchedule?> getWaterBlockSchedule(String ip) async {
    final response = await _makeRequest(ip, '/water-block/schedule');
    if (response == null) return null;

    if (ip != MyStrings.mockIp) print(response);

    final schedule = BlockSchedule(
      sunday: BlockDay(
        enabled: response['sunday']['enabled'],
        hours: List<bool>.from(response['sunday']['hours']),
      ),
      monday: BlockDay(
        enabled: response['monday']['enabled'],
        hours: List<bool>.from(response['monday']['hours']),
      ),
      tuesday: BlockDay(
        enabled: response['tuesday']['enabled'],
        hours: List<bool>.from(response['tuesday']['hours']),
      ),
      wednesday: BlockDay(
        enabled: response['wednesday']['enabled'],
        hours: List<bool>.from(response['wednesday']['hours']),
      ),
      thursday: BlockDay(
        enabled: response['thursday']['enabled'],
        hours: List<bool>.from(response['thursday']['hours']),
      ),
      friday: BlockDay(
        enabled: response['friday']['enabled'],
        hours: List<bool>.from(response['friday']['hours']),
      ),
      saturday: BlockDay(
        enabled: response['saturday']['enabled'],
        hours: List<bool>.from(response['saturday']['hours']),
      ),
    );

    return schedule;
  }

  // TODO:
  Future<bool> putWaterBlockSchedule(
    String ip,
    Map<String, dynamic> scheduleData,
  ) async {
    final response = await _makeRequest(
      ip,
      '/water-block/schedule',
      method: 'PUT',
      body: scheduleData,
    );
    print(response);
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
    ip = ip == MyStrings.mockIp ? MyStrings.myIp : ip;

    try {
      final request = await _client.get(ip, port, '/me');
      final response = await request.close();
      final content = await response.transform(utf8.decoder).join();
      print(content);

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
