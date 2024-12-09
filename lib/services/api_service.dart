import 'dart:convert';
import 'dart:io';
import 'package:leak_guard/credentials.dart';
import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/flow.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/services/network_service.dart';
import 'package:leak_guard/utils/strings.dart';

class CustomApi {
  static final CustomApi _instance = CustomApi._internal();
  final HttpClient _client;
  final _networkService = NetworkService();

  factory CustomApi() {
    return _instance;
  }

  CustomApi._internal() : _client = HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 2);
  }

  Future<Map<String, dynamic>?> _makeRequest(
    String ip,
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    String user = Credentials.apiUser,
    String password = Credentials.apiPass,
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
          'Basic ${base64Encode(utf8.encode('$user:$password'))}');

      if (body != null) {
        request.headers.contentType = ContentType.json;
        String bodyString = jsonEncode(body);
        request.headers.contentLength = utf8.encode(bodyString).length;
        request.write(bodyString);
      }

      final response = await request.close();
      final content = await response.transform(utf8.decoder).join();

      print('$path: ${response.statusCode} $content');
      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 409) {
        if (content.isNotEmpty) {
          return jsonDecode(content);
        }
        return {"message": "Request successful"};
      }
      throw HttpException(
          'Request failed \nStatus code: ${response.statusCode}\nContent: $content');
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getConfig(String ip) async {
    return await _makeRequest(ip, '/config');
  }

  Future<bool> putConfig(String ip, Map<String, dynamic> config) async {
    final response =
        await _makeRequest(ip, '/config', method: 'PUT', body: config);
    return response != null;
  }

  Future<List<Flow>?> getRecentFlows(String ip, DateTime lastFlowDate) async {
    //TODO: If implemented remove next line
    ip = MyStrings.myIp;
    final fromTimestamp = lastFlowDate.millisecondsSinceEpoch ~/ 1000;
    final toTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final result =
        await _makeRequest(ip, '/water-usage/$fromTimestamp/$toTimestamp');
    if (result == null) return null;

    final Map<String, double> usages =
        Map<String, double>.from(result['usages']);
    if (usages.isEmpty) return [];

    return usages.entries
        .map((entry) => Flow(
              centralUnitID: null,
              volume: entry.value,
              date: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(entry.key) * 1000),
            ))
        .toList();
  }

  Future<(double, double)?> getWaterUsage(String ip) async {
    final result = await _makeRequest(ip, '/water-usage');
    if (result == null) return null;
    double flowRate = (result['flow_rate'] as int) / 1000.0;
    double todayVolume = (result['today_volume'] as int) / 1000.0;
    return (flowRate, todayVolume);
  }

  Future<List<LeakProbe>?> getLeakProbes(String ip) async {
    final result = await _makeRequest(ip, '/probe');
    if (result == null) return null;

    List<LeakProbe> probes = [];

    (result).forEach((address, data) {
      int batteryLevel = data['battery_level'] ?? -1;
      probes.add(LeakProbe(
        name: 'Probe $address',
        rssi: data['last_rssi'],
        centralUnitID: null,
        stmId: (data['id'] as List).cast<int>(),
        address: int.parse(address),
        batteryLevel: batteryLevel,
        isAlarmed: data['is_alerted'],
      ));
    });

    return probes;
  }

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

  Future<bool?> getWaterBlock(String ip) async {
    final result = await _makeRequest(ip, '/water-block');
    if (result == null) return null;
    return result['block'] == "active";
  }

  Future<bool?> getParingMode(String ip) async {
    final result = await _makeRequest(ip, '/probe/pair');
    if (result == null) return null;
    return result['pairing'];
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

  Future<BlockSchedule?> getWaterBlockSchedule(String ip) async {
    final response = await _makeRequest(ip, '/water-block/schedule');
    if (response == null) return null;

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
    return response != null;
  }

  Future<(int, int)?> getCriteria(String ip) async {
    final result = await _makeRequest(ip, '/criteria');
    if (result == null) return null;

    // Parse "T,1,30,|" format
    final parts = result['criteria'].toString().split(',');
    if (parts.length < 3) return null;

    int minimumFlowRate = int.tryParse(parts[1]) ?? 500;
    minimumFlowRate *= 10;
    int minimumTime = int.tryParse(parts[2]) ?? 300;

    return (minimumFlowRate, minimumTime);
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

  Future<Map<String, dynamic>?> getCriterion(String ip, String id) async {
    return await _makeRequest(ip, '/criteria/$id');
  }

  Future<(String, String)?> getCentralIdAndMac(String ip) async {
    final result = await _makeRequest(ip, '/me');
    if (result == null) return null;
    String id = result['id'] ?? '';
    String mac = result['mac'] ?? '';

    return (id, mac);
  }

  Future<bool> registerCentralUnit(String centralUnitID) async {
    String? fcmToken = _networkService.fcmToken;
    if (fcmToken == null) return false;

    final result = await _makeRequest(
      Credentials.elaticIP,
      "/register",
      method: 'POST',
      body: {
        "device_id": centralUnitID,
        "fcm_token": fcmToken,
      },
      user: Credentials.elasticUser,
      password: Credentials.elasticPass,
    );
    return result != null;
  }

  Future<bool> unRegisterCentralUnit(String centralUnitID) async {
    String? fcmToken = _networkService.fcmToken;
    if (fcmToken == null) return false;

    final result = await _makeRequest(
      Credentials.elaticIP,
      "/unregister",
      method: 'POST',
      body: {
        "device_id": centralUnitID,
        "fcm_token": fcmToken,
      },
      user: Credentials.elasticUser,
      password: Credentials.elasticPass,
    );
    return result != null;
  }
}
