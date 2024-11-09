import 'package:leak_guard/models/leak_probe.dart';

class CentralUnit {
  int? centralUnitID;
  String name;
  String addressIP;
  String addressMAC;
  String password = "admin";
  String? description;
  String? imagePath;
  bool isBlocked = false;
  List<LeakProbe> leakProbes = [];

  CentralUnit(
      {required this.name,
      required this.addressIP,
      required this.addressMAC,
      this.description,
      this.imagePath});

  @override
  String toString() {
    return "CentralUnit: $name, $addressIP, $addressMAC";
  }
}
