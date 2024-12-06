import 'package:leak_guard/models/photographable.dart';

class LeakProbe implements Photographable {
  int? leakProbeID;
  int? centralUnitID;
  String name;
  List<int> stmId;
  int address;
  int batteryLevel = 100;
  bool _blocked = false;

  bool get blocked => !_blocked;

  set blocked(bool value) {
    _blocked = value;
  }

  String? description;
  String? imagePath;

  LeakProbe({
    required this.name,
    required this.centralUnitID,
    required this.stmId,
    required this.address,
    this.description,
    this.imagePath,
  }) {
    if (stmId.length != 3) {
      throw ArgumentError('stmId must be a 3-element list');
    }
  }

  @override
  String toString() {
    return 'LeakProbe($name, $centralUnitID, $stmId, $address, $batteryLevel, $blocked)';
  }

  @override
  String? getPhoto() => imagePath;

  @override
  void setPhoto(String? path) {
    imagePath = path;
  }
}
