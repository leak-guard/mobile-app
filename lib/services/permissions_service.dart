import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal() {
    initializePermissions();
  }

  Map<Permission, bool> _permissionStatus = {};

  Future<void> initializePermissions() async {
    _permissionStatus = {
      Permission.location: await Permission.location.request().isGranted,
      Permission.camera: await Permission.camera.request().isGranted,
      Permission.storage: await Permission.storage.request().isGranted,
    };
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;

    PermissionStatus result = await permission.request();
    _permissionStatus[permission] = result.isGranted;

    if (!result.isGranted) {
      await AppSettings.openAppSettings();
    }
    result = await permission.request();
    _permissionStatus[permission] = result.isGranted;

    return result.isGranted;
  }
}
