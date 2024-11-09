class LeakProbe {
  int? leakProbeID;
  int? centralUnitID;
  String name;
  String? description;
  String? imagePath;

  LeakProbe(
      {required this.name,
      required this.centralUnitID,
      this.description,
      this.imagePath});
}
