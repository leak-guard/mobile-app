import 'package:leak_guard/models/flow.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/services/database_service.dart';

class CentralUnit {
  int? centralUnitID;
  String name;
  String addressIP;
  String addressMAC;
  String password = "admin";
  bool isValveNO = true;
  int impulsesPerLiter = 1000;
  String? description;
  String? imagePath;

  CentralUnit(
      {required this.name,
      required this.addressIP,
      required this.addressMAC,
      required this.password,
      required this.isValveNO,
      required this.impulsesPerLiter,
      this.description,
      this.imagePath});

  bool isBlocked = false;
  bool chosen = false;
  List<LeakProbe> leakProbes = [];
  final _db = DatabaseService.instance;

  int leakProbeLowBatteryNumber() {
    return leakProbes.where((probe) => probe.batteryLevel <= 20).length;
  }

  int leakProbeNumber() {
    return leakProbes.length;
  }

  double? _cachedCurrentFlowRate;
  DateTime? _lastFlowRateUpdate;
  double? _cachedTodaysUsage;
  DateTime? _lastTodaysUsageUpdate;
  double? _cachedYesterdayUsage;
  DateTime? _lastYesterdayUsageDate;
  List<WaterUsageData>? _cachedWaterUsageData;

  void invalidateCache() {
    _cachedCurrentFlowRate = null;
    _lastFlowRateUpdate = null;
    _cachedTodaysUsage = null;
    _lastTodaysUsageUpdate = null;
    _cachedYesterdayUsage = null;
    _lastYesterdayUsageDate = null;
    _cachedWaterUsageData = null;
  }

  static const _flowRateCacheDuration = Duration(minutes: 1);

  //TODO: Implement API call to update central unit data
  Future<void> updateFlowInfo() async {
    // Mocked update
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<Flow>> _getFlowData(DateTime start, DateTime end) async {
    List<Flow> allFlows = [];
    if (centralUnitID != null) {
      allFlows = await _db.getCentralUnitFlowsBetweenDates(
        centralUnitID!,
        start,
        end,
      );
    }

    return allFlows;
  }

  Future<double> getCurrentFlowRate() async {
    if (isBlocked) {
      return 0.0;
    }

    if (_cachedCurrentFlowRate != null &&
        _lastFlowRateUpdate != null &&
        DateTime.now().difference(_lastFlowRateUpdate!) <
            _flowRateCacheDuration) {
      return _cachedCurrentFlowRate!;
    }

    // TODO: Implement API call to get current flow rate
    // Currently mocked with database data
    final now = DateTime.now();
    final flow = await _db.getLatestFlow(
        centralUnitID!, now.millisecondsSinceEpoch ~/ 1000);

    _cachedCurrentFlowRate = flow?.volume.toDouble() ?? 0.0;
    _lastFlowRateUpdate = now;

    return _cachedCurrentFlowRate!;
  }

  Future<double> getTodaysWaterUsage() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we need to reset cache for new day
    if (_lastTodaysUsageUpdate != null &&
        _lastTodaysUsageUpdate!.day != now.day) {
      _cachedTodaysUsage = null;
    }

    // If we have cached value and it's recent enough, use it
    if (_cachedTodaysUsage != null &&
        _lastTodaysUsageUpdate != null &&
        now.difference(_lastTodaysUsageUpdate!) < _flowRateCacheDuration) {
      return _cachedTodaysUsage!;
    }

    // Get latest data from database
    final flows = await _db.getCentralUnitFlowsBetweenDates(
      centralUnitID!,
      today,
      now,
    );

    double total = 0.0;
    if (flows.isNotEmpty) {
      total = flows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());
    }

    _cachedTodaysUsage = total;
    _lastTodaysUsageUpdate = now;

    return total;
  }

  Future<double> getYesterdayWaterUsage() async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final todayStart = DateTime(now.year, now.month, now.day);

    // Check if we need to reset cache for new day
    if (_lastYesterdayUsageDate != null &&
        _lastYesterdayUsageDate!.day != now.day) {
      _cachedYesterdayUsage = null;
    }

    // Return cached value if available and still valid
    if (_cachedYesterdayUsage != null &&
        _lastYesterdayUsageDate?.day == now.day) {
      return _cachedYesterdayUsage!;
    }

    // Get data from database
    final flows = await _db.getCentralUnitFlowsBetweenDates(
      centralUnitID!,
      yesterday,
      todayStart,
    );

    if (flows.isEmpty) {
      return 0.0;
    }

    _cachedYesterdayUsage =
        flows.fold(0.0, (sum, flow) => sum! + flow.volume.toDouble());
    _lastYesterdayUsageDate = now;

    return _cachedYesterdayUsage!;
  }

  Future<List<WaterUsageData>> getWaterUsageData(int hoursToFetch) async {
    final now = DateTime.now();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    if (_cachedWaterUsageData == null) {
      final startTime = currentHour.subtract(Duration(hours: hoursToFetch - 1));
      final flows = await _getFlowData(startTime, now);

      List<WaterUsageData> result = [];
      for (int i = hoursToFetch - 1; i >= 0; i--) {
        final time = currentHour.subtract(Duration(hours: i));
        final hourFlows = flows
            .where((flow) =>
                flow.date.year == time.year &&
                flow.date.month == time.month &&
                flow.date.day == time.day &&
                flow.date.hour == time.hour)
            .toList();

        final usage = hourFlows.isEmpty
            ? 0.0
            : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

        result.add(WaterUsageData(
          time.year,
          time.month,
          time.day,
          time.hour,
          time.minute,
          usage,
        ));
      }

      _cachedWaterUsageData = result;
      return result;
    }

    if (_cachedWaterUsageData!.last.hour != currentHour.hour) {
      final lastCachedHour = DateTime(
        _cachedWaterUsageData!.last.year,
        _cachedWaterUsageData!.last.month,
        _cachedWaterUsageData!.last.day,
        _cachedWaterUsageData!.last.hour,
      );

      final startTime = lastCachedHour;
      final flows = await _getFlowData(startTime, now);

      final lastHourFlows = flows
          .where((flow) =>
              flow.date.year == lastCachedHour.year &&
              flow.date.month == lastCachedHour.month &&
              flow.date.day == lastCachedHour.day &&
              flow.date.hour == lastCachedHour.hour)
          .toList();

      if (lastHourFlows.isNotEmpty) {
        final lastHourUsage = lastHourFlows.fold(
            0.0, (sum, flow) => sum + flow.volume.toDouble());
        _cachedWaterUsageData!.last = WaterUsageData(
          lastCachedHour.year,
          lastCachedHour.month,
          lastCachedHour.day,
          lastCachedHour.hour,
          now.minute,
          lastHourUsage,
        );
      }

      final hoursToAdd = currentHour.difference(lastCachedHour).inHours;
      for (int i = hoursToAdd; i > 0; i--) {
        final time = currentHour.subtract(Duration(hours: i - 1));
        final hourFlows = flows
            .where((flow) =>
                flow.date.year == time.year &&
                flow.date.month == time.month &&
                flow.date.day == time.day &&
                flow.date.hour == time.hour)
            .toList();

        final usage = hourFlows.isEmpty
            ? 0.0
            : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

        _cachedWaterUsageData!.add(WaterUsageData(
          time.year,
          time.month,
          time.day,
          time.hour,
          time.minute,
          usage,
        ));
      }

      while (_cachedWaterUsageData!.length > hoursToFetch) {
        _cachedWaterUsageData!.removeAt(0);
      }

      return _cachedWaterUsageData!;
    }

    final currentHourFlows = await _getFlowData(currentHour, now);
    final usage = currentHourFlows.isEmpty
        ? 0.0
        : currentHourFlows.fold(
            0.0, (sum, flow) => sum + flow.volume.toDouble());

    _cachedWaterUsageData!.last = WaterUsageData(
      currentHour.year,
      currentHour.month,
      currentHour.day,
      currentHour.hour,
      now.minute,
      usage,
    );

    return _cachedWaterUsageData!;
  }

  @override
  String toString() {
    String result = "CentralUnit: $name, $addressIP, $addressMAC\n";
    String probes = "Probes:\n";
    for (var probe in leakProbes) {
      probes += "\t" + probe.toString() + "\n";
    }

    result += probes;

    return result;
  }
}
