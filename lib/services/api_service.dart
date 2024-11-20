import 'dart:convert';
import 'dart:io';

class CustomApi {
  static final CustomApi _instance = CustomApi._internal();
  final HttpClient _client;

  factory CustomApi() {
    return _instance;
  }

  CustomApi._internal() : _client = HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 5);
  }

  Future<(String?, bool)> getCentralMacAddress(String ip) async {
    try {
      final request = await _client.get(ip, 80, '/me');
      final response = await request.close();
      final content = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(content);
        return (data['mac'] as String, true);
      }
      return (null, false);
    } catch (e) {
      return (null, false);
    }
  }

  // Add other API methods following same pattern:
  // Future<(ReturnType?, bool)> methodName(params)...
}
