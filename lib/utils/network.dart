import 'package:network_info_plus/network_info_plus.dart';

class CustomNetwork {
  static Future<String?> getWifiName() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiName();
  }

  static Future<String?> getWifiBSSID() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiBSSID();
  }

  static Future<String?> getWifiIP() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiIP();
  }

  static Future<String?> getWifiIPv6() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiIPv6();
  }

  static Future<String?> getWifiSubmask() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiSubmask();
  }

  static Future<String?> getWifiBroadcast() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiBroadcast();
  }

  static Future<String?> getWifiGatewayIP() async {
    NetworkInfo info = NetworkInfo();
    return info.getWifiGatewayIP();
  }
}
