import 'package:leak_guard/models/block_schedule.dart';
import 'package:leak_guard/models/flow.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/models/photographable.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/services/api_service.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:nsd/nsd.dart';

class CentralUnit implements Photographable {
  int? centralUnitID;
  String name;
  String? description;
  String? imagePath;
  String password = "admin";

  BlockSchedule blockSchedule = BlockSchedule.defaultSchedule();
  bool isBlocked = false;

  String addressIP;
  String addressMAC;

  String? wifiSSID = "";
  String? wifiPassword = "";
  bool isOnline = false;
  int? timezoneId = 37;

  bool isValveNO = true;
  int impulsesPerLiter = 1000;

  double flowRate = 0.0;

  bool chosen = false;

  final CustomApi _api = CustomApi();

  CentralUnit(
      {required this.name,
      required this.addressIP,
      required this.addressMAC,
      required this.password,
      required this.isValveNO,
      required this.impulsesPerLiter,
      this.timezoneId,
      this.description,
      this.imagePath,
      this.wifiSSID,
      this.wifiPassword});

  CentralUnit.fromService(Service service)
      : name = service.addresses == null
            ? "no_ip_addresses"
            : service.addresses!.first.address,
        password = "admin",
        addressIP = service.addresses == null
            ? "no_ip_addresses"
            : service.addresses!.first.address,
        addressMAC = MyStrings.noHost;

  List<LeakProbe> leakProbes = [];
  final _db = DatabaseService.instance;

  int leakProbeLowBatteryCount() {
    return leakProbes.where((probe) => probe.batteryLevel <= 20).length;
  }

  int leakProbesCount() {
    return leakProbes.length;
  }

  double? _cachedTodaysUsage;
  DateTime? _lastTodaysUsageUpdate;
  double? _cachedYesterdayUsage;
  DateTime? _lastYesterdayUsageDate;
  List<WaterUsageData>? _cachedWaterUsageData;

  void invalidateCache() {
    _cachedTodaysUsage = null;
    _lastTodaysUsageUpdate = null;
    _cachedYesterdayUsage = null;
    _lastYesterdayUsageDate = null;
    _cachedWaterUsageData = null;
  }

  static const _flowRateCacheDuration = Duration(minutes: 1);

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

  Future<double?> getTodaysWaterUsage() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastTodaysUsageUpdate != null &&
        _lastTodaysUsageUpdate!.day != now.day) {
      _cachedTodaysUsage = null;
    }

    if (_cachedTodaysUsage != null &&
        _lastTodaysUsageUpdate != null &&
        now.difference(_lastTodaysUsageUpdate!) < _flowRateCacheDuration) {
      return _cachedTodaysUsage!;
    }

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

    if (_lastYesterdayUsageDate != null &&
        _lastYesterdayUsageDate!.day != now.day) {
      _cachedYesterdayUsage = null;
    }

    if (_cachedYesterdayUsage != null &&
        _lastYesterdayUsageDate?.day == now.day) {
      return _cachedYesterdayUsage!;
    }

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
          time,
          usage,
        ));
      }

      _cachedWaterUsageData = result;
      return result;
    }

    if (_cachedWaterUsageData!.last.date.hour != currentHour.hour) {
      final lastCachedHour = _cachedWaterUsageData!.last.date;

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
          lastCachedHour,
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
          time,
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
      currentHour,
      usage,
    );

    return _cachedWaterUsageData!;
  }

  @override
  String toString() {
    String result = "CentralUnit: $name, $addressIP, $addressMAC\n";
    String probes = "Probes:\n";
    for (var probe in leakProbes) {
      probes += "\t$probe\n";
    }

    result += probes;

    return result;
  }

  @override
  String? getPhoto() => imagePath;

  @override
  void setPhoto(String? path) {
    imagePath = path;
  }

  int detectedLeaksCount() {
    return leakProbes.where((probe) => probe.blocked).length;
  }

  Future<bool> refreshConfig() async {
    Map<String, dynamic>? data = await _api.getConfig(addressIP);
    if (data != null) {
      isValveNO = data['valve_type'] as String == "no";
      impulsesPerLiter = data['flow_meter_impulses'] as int;
      timezoneId = data['timezone_id'] as int;
      wifiSSID = data['ssid'] as String;
      wifiPassword = data['passphrase'] as String;
      isOnline = true;
      return true;
    } else {
      isOnline = false;
      return false;
    }
  }

  Future<bool> refreshMacAddress() async {
    final idAndMac = await _api.getCentralIdAndMac(addressIP);
    if (idAndMac == null) {
      isOnline = false;
      return false;
    }
    if (addressMAC != idAndMac.$2 &&
        addressMAC != MyStrings.noHost &&
        addressIP != MyStrings.mockIp) {
      print("XD");
      return false;
    }

    if (addressMAC == MyStrings.noHost) {
      addressMAC = idAndMac.$2;
    }

    isOnline = true;
    return true;
  }

  Future<bool> getBlockSchedule() async {
    final result = await _api.getWaterBlockSchedule(addressIP);
    if (result == null) {
      return false;
    }
    blockSchedule = result;
    return true;
  }

  Future<bool> refreshBlockStatus() async {
    bool? isBlockedResult = await _api.getWaterBlock(addressIP);
    if (isBlockedResult == null) {
      return false;
    }
    isBlocked = isBlockedResult;
    return true;
  }

  //TODO: Implement fetching data from API:
  // - Fetch Probes data for each central unit
  // - Get criteria

  //TODO: probably many request will kill the server - yes :)
  Future<bool> refreshData() async {
    const Duration delay = Duration(milliseconds: 400);
    if (!await refreshMacAddress()) return false;
    await Future.delayed(delay);
    if (!await refreshConfig()) return false;
    await Future.delayed(delay);
    if (!await getBlockSchedule()) return false;
    await Future.delayed(delay);
    if (!await refreshBlockStatus()) return false;
    await Future.delayed(delay);
    if (!await refreshFlowAndTodaysUsage()) return false;
    await Future.delayed(delay);
    if (!await getRecentFlows()) return false;
    await Future.delayed(delay);
    if (!await refreshProbes()) return false;
    return true;
  }

  List<Future<bool>> refreshStatus() {
    List<Future<bool>> futures = [];
    futures.add(refreshMacAddress());
    futures.add(refreshConfig());
    futures.add(refreshBlockStatus());

    return futures;
  }

  Future<bool> sendBlockSchedule(BlockSchedule blockSchedule) async {
    return _api.putWaterBlockSchedule(addressIP, blockSchedule.toJson());
  }

  Future<bool> refreshProbes() async {
    List<LeakProbe>? probes = await _api.getLeakProbes(addressIP);
    if (probes == null) {
      return false;
    }
    for (LeakProbe probe in probes) {
      probe.centralUnitID = centralUnitID;
      print(probe);
    } // TODO: CONTINUE HERE

    return true;
  }

  Future<bool> getRecentFlows() async {
    Flow? recentFlow = await _db.getLatestFlow(centralUnitID!);
    // TODO: Change here - ask whats the best history to fetch
    DateTime lastFlowDate =
        recentFlow?.date ?? DateTime.now().subtract(const Duration(days: 1));

    List<Flow>? flows = await _api.getRecentFlows(addressIP, lastFlowDate);
    if (flows == null) {
      return false;
    }
    if (flows.isEmpty) {
      return true;
    }

    for (var flow in flows) {
      flow.centralUnitID = centralUnitID;
    }
    print("zwieszam sie");
    await _db.addCentralUnitsFlows(centralUnitID!, flows);
    print("odwieszam sie");

    return true;
  }

  Future<bool> refreshFlowAndTodaysUsage() async {
    final result = await _api.getWaterUsage(addressIP);
    if (result != null) {
      isOnline = true;
      flowRate = result.$1;
      _cachedTodaysUsage = result.$2;
      _lastTodaysUsageUpdate = DateTime.now();
      return true;
    } else {
      isOnline = false;
      flowRate = 0.0;
      return false;
    }
  }

  Future<List<WaterUsageData>> getWaterUsageDataThisHour(int portions) async {
    final now = DateTime.now();
    final hourBegining = DateTime(now.year, now.month, now.day, now.hour);

    final flows = await _getFlowData(hourBegining, now);

    List<WaterUsageData> result = [];
    for (int i = 0; i < portions; i++) {
      final time = hourBegining.add(Duration(minutes: 60 * i ~/ portions));
      final hourFlows = flows
          .where((flow) =>
              flow.date.year == time.year &&
              flow.date.month == time.month &&
              flow.date.day == time.day &&
              flow.date.hour == time.hour &&
              (time.minute <= flow.date.minute &&
                  flow.date.minute < time.minute + 60 ~/ portions))
          .toList();

      final usage = hourFlows.isEmpty
          ? 0.0
          : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

      result.add(WaterUsageData(
        time,
        usage,
      ));
    }
    return result;
  }

  Future<List<WaterUsageData>> getWaterUsageDataThisDay(int portions) async {
    final now = DateTime.now();
    final dayBegining = DateTime(now.year, now.month, now.day);

    final flows = await _getFlowData(dayBegining, now);

    List<WaterUsageData> result = [];
    for (int i = 0; i < portions; i++) {
      final time = dayBegining.add(Duration(hours: 24 * i ~/ portions));
      final hourFlows = flows
          .where((flow) =>
              flow.date.year == time.year &&
              flow.date.month == time.month &&
              flow.date.day == time.day &&
              (time.hour <= flow.date.hour &&
                  flow.date.hour < time.hour + 24 ~/ portions))
          .toList();

      final usage = hourFlows.isEmpty
          ? 0.0
          : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

      result.add(WaterUsageData(
        time,
        usage,
      ));
    }
    return result;
  }

  Future<List<WaterUsageData>> getWaterUsageDataLastDays(int daysCount) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day - daysCount + 1);

    final flows = await _getFlowData(firstDay, now);

    List<WaterUsageData> result = [];
    for (int i = 0; i < daysCount; i++) {
      final time = firstDay.add(Duration(days: i));
      final hourFlows = flows
          .where((flow) =>
              flow.date.year == time.year &&
              flow.date.month == time.month &&
              flow.date.day == time.day)
          .toList();

      final usage = hourFlows.isEmpty
          ? 0.0
          : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

      result.add(WaterUsageData(
        time,
        usage,
      ));
    }
    return result;
  }

  Future<List<WaterUsageData>> getWaterUsageDataLastMonths(
      int monthsCount) async {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year, now.month - monthsCount + 1);

    final flows = await _getFlowData(firstMonth, now);

    List<WaterUsageData> result = [];
    for (int i = 0; i < monthsCount; i++) {
      final time = DateTime(firstMonth.year, firstMonth.month + i);
      final hourFlows = flows
          .where((flow) =>
              flow.date.year == time.year && flow.date.month == time.month)
          .toList();

      final usage = hourFlows.isEmpty
          ? 0.0
          : hourFlows.fold(0.0, (sum, flow) => sum + flow.volume.toDouble());

      result.add(WaterUsageData(
        time,
        usage,
      ));
    }
    return result;
  }
}
