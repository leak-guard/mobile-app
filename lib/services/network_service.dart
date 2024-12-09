import 'dart:async';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/wifi_network.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nsd/nsd.dart';
import 'package:wifi_scan/wifi_scan.dart';

import 'package:permission_handler/permission_handler.dart' as ph;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal() {
    _initializeNetworkInfo();
  }

  final _networkInfo = NetworkInfo();
  Discovery? _discovery;

  AppData _appData = AppData();
  final _db = DatabaseService.instance;

  List<WifiNetwork> availableWifiNetworks = [];
  List<CentralUnit> discoveredCentralUnits = [];
  String? currentWifiName;
  bool isSearchingWifi = false;
  bool isSearchingServices = false;
  bool permissionGranted = true;
  String? fcmToken;

  final _wifiStreamController = StreamController<List<WifiNetwork>>.broadcast();
  final _centralUnitsStreamController =
      StreamController<List<CentralUnit>>.broadcast();

  Stream<List<WifiNetwork>> get wifiStream => _wifiStreamController.stream;
  Stream<List<CentralUnit>> get centralUnitsStream =>
      _centralUnitsStreamController.stream;

  Future<void> _initializeNetworkInfo() async {
    await scanWifiNetworks();
    print('Current WiFi network: $currentWifiName');
    startServiceDiscovery();
  }

  Future<void> getCurrentWifiName() async {
    currentWifiName = await _networkInfo.getWifiName();
    currentWifiName = currentWifiName?.replaceAll('"', '');
  }

  Future<void> scanWifiNetworks() async {
    isSearchingWifi = true;
    _wifiStreamController.add(availableWifiNetworks);
    try {
      permissionGranted =
          await PermissionsService().requestPermission(ph.Permission.location);
      if (!permissionGranted) {
        throw Exception('Location services are required for WiFi scanning');
      }

      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        throw Exception(_getErrorMessage(can));
      }

      await getCurrentWifiName();

      final result = await WiFiScan.instance.startScan();
      if (!result) {
        throw Exception('Failed to start WiFi scan');
      }

      final accessPoints = await WiFiScan.instance.getScannedResults();

      availableWifiNetworks = accessPoints
          .map((ap) => WifiNetwork.fromWiFiAccessPoint(ap))
          .where((network) => network.ssid.isNotEmpty)
          .toSet()
          .toList();

      availableWifiNetworks
          .sort((a, b) => b.signalStrength.compareTo(a.signalStrength));

      if (currentWifiName != null && currentWifiName!.isNotEmpty) {
        final currentIndex = availableWifiNetworks
            .indexWhere((network) => network.ssid == currentWifiName);
        if (currentIndex != -1) {
          final current = availableWifiNetworks.removeAt(currentIndex);
          availableWifiNetworks.insert(0, current);
        }
      }

      _wifiStreamController.add(availableWifiNetworks);
    } catch (e) {
      print('Error scanning WiFi networks: $e');
    } finally {
      isSearchingWifi = false;
      _wifiStreamController.add(availableWifiNetworks);
    }
  }

  Future<void> startServiceDiscovery() async {
    if (_discovery != null) {
      await stopServiceDiscovery();
    }

    isSearchingServices = true;
    discoveredCentralUnits.clear();
    _centralUnitsStreamController.add(discoveredCentralUnits);

    try {
      _discovery = await startDiscovery(
        '_leakguard._tcp',
        autoResolve: true,
        ipLookupType: IpLookupType.v4,
      );

      _discovery?.addServiceListener((service, status) {
        print("found service: $service");
        if (status == ServiceStatus.found) {
          _handleFoundService(service);
        } else {
          _handleLostService(service);
        }
      });
    } catch (e) {
      print('Error starting service discovery: $e');
      isSearchingServices = false;
    }
  }

  String _getErrorMessage(CanStartScan status) {
    switch (status) {
      case CanStartScan.notSupported:
        return 'WiFi scanning is not supported on this device';
      case CanStartScan.noLocationPermissionRequired:
        return 'Location permission is required for WiFi scanning';
      case CanStartScan.noLocationPermissionDenied:
        return 'Location permission was denied';
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        return 'Location permission needs to be upgraded for better accuracy';
      case CanStartScan.noLocationServiceDisabled:
        return 'Please enable location services';
      default:
        return 'Unknown error occurred';
    }
  }

  void _handleFoundService(Service service) {
    print(service);
    CentralUnit foundCentralUnit = CentralUnit.fromService(service);

    if (!discoveredCentralUnits
        .any((cu) => _isSameCentralUnit(cu, foundCentralUnit))) {
      bool centralAlreadyInDatabase = false;
      foundCentralUnit.refreshStatus().then((success) {
        for (CentralUnit cu in _appData.centralUnits) {
          if (cu.addressMAC == foundCentralUnit.addressMAC) {
            centralAlreadyInDatabase = true;
            if (cu.addressIP != foundCentralUnit.addressIP) {
              cu.addressIP = foundCentralUnit.addressIP;
              cu.isOnline = true;
              _db.updateCentralUnit(cu);
            }
            break;
          }
        }
        if (!centralAlreadyInDatabase) {
          discoveredCentralUnits.add(foundCentralUnit);
          _centralUnitsStreamController.add(discoveredCentralUnits);
        }
      });
    }
  }

  void _handleLostService(Service service) {
    CentralUnit foundCentralUnit = CentralUnit.fromService(service);
    discoveredCentralUnits
        .removeWhere((s) => _isSameCentralUnit(s, foundCentralUnit));
    _centralUnitsStreamController.add(discoveredCentralUnits);
  }

  bool _isSameCentralUnit(CentralUnit a, CentralUnit b) =>
      a.addressIP == b.addressIP;

  Future<void> stopServiceDiscovery() async {
    if (_discovery != null) {
      await stopDiscovery(_discovery!);
      _discovery = null;
      isSearchingServices = false;
    }
  }

  Future<bool> requestLocationService() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.noLocationServiceDisabled) {
      final locationGranted =
          await PermissionsService().requestPermission(ph.Permission.location);
      if (!locationGranted) return false;
    }
    return true;
  }

  Future<void> dispose() async {
    await stopServiceDiscovery();
    await _wifiStreamController.close();
    await _centralUnitsStreamController.close();
  }
}
