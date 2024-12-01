import 'package:wifi_scan/wifi_scan.dart';

class WifiNetwork {
  final String ssid;
  final int signalStrength;
  final String bssid;
  final bool isSecure;

  const WifiNetwork({
    required this.ssid,
    required this.signalStrength,
    required this.bssid,
    required this.isSecure,
  });

  SignalStrength get signalQuality {
    if (signalStrength >= -50) return SignalStrength.excellent;
    if (signalStrength >= -60) return SignalStrength.good;
    if (signalStrength >= -70) return SignalStrength.fair;
    return SignalStrength.poor;
  }

  factory WifiNetwork.fromWiFiAccessPoint(WiFiAccessPoint accessPoint) {
    return WifiNetwork(
      ssid: accessPoint.ssid,
      signalStrength: accessPoint.level,
      bssid: accessPoint.bssid,
      isSecure: accessPoint.capabilities.contains("WPA") ||
          accessPoint.capabilities.contains("WEP"),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiNetwork &&
          runtimeType == other.runtimeType &&
          bssid == other.bssid;

  @override
  int get hashCode => bssid.hashCode;
}

enum SignalStrength {
  excellent,
  good,
  fair,
  poor;

  String get label {
    switch (this) {
      case SignalStrength.excellent:
        return 'Excellent';
      case SignalStrength.good:
        return 'Good';
      case SignalStrength.fair:
        return 'Fair';
      case SignalStrength.poor:
        return 'Poor';
    }
  }
}
