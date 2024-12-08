import 'package:leak_guard/models/photographable.dart';

class LeakProbe implements Photographable {
  int? leakProbeID;
  int? centralUnitID;
  String name;
  List<int> stmId;
  int address;
  int batteryLevel;
  bool isAlarmed;

  String? description;
  String? imagePath;

  LeakProbe({
    required this.name,
    required this.centralUnitID,
    required this.stmId,
    required this.address,
    this.batteryLevel = 100,
    this.isAlarmed = false,
    this.description,
    this.imagePath,
  }) {
    if (stmId.length != 3) {
      throw ArgumentError('stmId must be a 3-element list');
    }
  }

  @override
  String toString() {
    return 'LeakProbe($name, $centralUnitID, $stmId, $address, $batteryLevel, $isAlarmed)';
  }

  @override
  String? getPhoto() => imagePath;

  @override
  void setPhoto(String? path) {
    imagePath = path;
  }

  bool isSameStmId(LeakProbe other) {
    if (other.stmId.length != stmId.length) {
      return false;
    }
    for (int i = 0; i < stmId.length; i++) {
      if (stmId[i] != other.stmId[i]) {
        return false;
      }
    }
    return true;
  }
}
