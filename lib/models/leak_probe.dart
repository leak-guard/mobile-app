class LeakProbe {
  int? leakProbeID;
  int? centralUnitID;
  String name;
  bool leakDetected = false;
  bool lowBattery = false;
  String? description;
  String? imagePath;

  LeakProbe(
      {required this.name,
      required this.centralUnitID,
      this.description,
      this.imagePath});
}
