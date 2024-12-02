import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  final _permissionStreamController =
      StreamController<Map<Permission, bool>>.broadcast();
  Stream<Map<Permission, bool>> get permissionStream =>
      _permissionStreamController.stream;

  Map<Permission, bool> _permissionStatus = {};

  Future<void> initializePermissions() async {
    _permissionStatus = {
      Permission.location: await Permission.location.isGranted,
      Permission.camera: await Permission.camera.isGranted,
      Permission.storage: await Permission.storage.isGranted,
      Permission.photos: await Permission.photos.isGranted,
    };
    _permissionStreamController.add(_permissionStatus);
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;

    final result = await permission.request();
    _permissionStatus[permission] = result.isGranted;
    _permissionStreamController.add(_permissionStatus);

    if (!result.isGranted) {
      await AppSettings.openAppSettings(type: _getSettingsType(permission));
    }

    return result.isGranted;
  }

  AppSettingsType _getSettingsType(Permission permission) {
    switch (permission) {
      case Permission.location:
        return AppSettingsType.location;
      case Permission.camera:
        return AppSettingsType.settings;
      case Permission.storage:
        return AppSettingsType.internalStorage;
      case Permission.photos:
        return AppSettingsType.settings;
      default:
        return AppSettingsType.settings;
    }
  }

  Future<bool> checkLocationServices() async {
    if (!await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      await AppSettings.openAppSettings(type: AppSettingsType.location);
      return false;
    }
    return true;
  }

  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await checkLocationServices();
    if (!serviceEnabled) return false;
    return requestPermission(Permission.location);
  }

  Future<void> dispose() async {
    await _permissionStreamController.close();
  }
}
