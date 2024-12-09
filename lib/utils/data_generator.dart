// ignore_for_file: avoid_print

import 'dart:math';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/models/flow.dart';
import 'package:leak_guard/services/app_data.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/strings.dart';

/// Service responsible for generating realistic test data for the LeakGuard application.
///
/// Data Generation Process:
/// 1. Groups:
///    - Creates predefined groups (e.g., Kitchen, Bathroom, etc.)
///    - Each group can contain 1-3 central units
///
/// 2. Central Units:
///    - Generated with unique MAC addresses and IP addresses
///    - Each central unit belongs to one or more groups
///    - Contains 0-3 randomly generated leak probes
///
/// 3. Flow Data Generation:
///    - Generates 8 months of data (6 months back + 2 months forward)
///    - 72 measurements per day (3 per hour, every 20 minutes)
///    - Flow rates are influenced by multiple factors:
///      a) Time of day patterns:
///         - Night (0-5): minimal usage (0-2 units)
///         - Morning peak (5-9): high usage (8-20 units)
///         - Day (9-17): moderate usage (3-10 units)
///         - Evening peak (17-22): elevated usage (6-15 units)
///         - Late night (22-24): low usage (1-5 units)
///      b) Day of week variations:
///         - Weekends: +30% usage
///         - Fridays: +10% usage
///         - Mondays: -10% usage
///      c) Seasonal patterns:
///         - Summer (Jun-Aug): +40-50% usage
///         - Winter (Dec-Feb): +20% usage
///         - Spring/Fall: baseline usage
///      d) Random events:
///         - 1% chance of leak simulation (3-5x normal flow)
///         - ±10% random noise for natural variations
///
/// Usage Example:
/// ```dart
/// await DataGenerator.generateTestData((status, progress) {
///   print('Status: $status');
///   print('Progress: ${progress * 100}%');
/// });
/// ```

class DataGenerator {
  static final _random = Random();
  static final _appData = AppData();
  static final _db = DatabaseService.instance;

  // Seasonal multipliers (relative to average)
  static const _seasonMultipliers = {
    // Winter (Dec-Feb)
    12: 1.2, 1: 1.2, 2: 1.2,
    // Spring (Mar-May)
    3: 1.0, 4: 1.0, 5: 1.0,
    // Summer (Jun-Aug)
    6: 1.4, 7: 1.5, 8: 1.4,
    // Fall (Sep-Nov)
    9: 1.0, 10: 1.0, 11: 1.1,
  };

  // Probability of leak for each hour (1%)
  static const _leakProbability = 0.01;
  // Flow multiplier during leak (3-5x normal flow)
  static double _getLeakMultiplier() => _getRandomDouble(3.0, 5.0);

  // Helper for generating random values
  static double _getRandomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  // Helper for generating MAC addresses
  static String _generateMacAddress() {
    return List.generate(
            6, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  // Generate flow rate based on multiple factors
  static double _generateFlowRate(DateTime timestamp) {
    final hour = timestamp.hour;
    final weekday = timestamp.weekday; // 1 = Monday, 7 = Sunday
    final month = timestamp.month;

    // Base flow based on hour
    double baseFlow = _getHourlyBaseFlow(hour);

    // Weekday multiplier
    double weekdayMultiplier = _getWeekdayMultiplier(weekday);

    // Seasonal multiplier
    double seasonMultiplier = _seasonMultipliers[month] ?? 1.0;

    // Calculate final flow
    double finalFlow = baseFlow * weekdayMultiplier * seasonMultiplier;

    // Add small random noise (±10%)
    finalFlow *= _getRandomDouble(0.9, 1.1);

    // Simulate leaks (1% chance)
    if (_random.nextDouble() < _leakProbability) {
      finalFlow *= _getLeakMultiplier();
    }

    return finalFlow;
  }

  // Base flow rate depending on hour
  static double _getHourlyBaseFlow(int hour) {
    if (hour >= 0 && hour < 5) {
      // Night - minimal usage
      return _getRandomDouble(0.0, 2.0);
    } else if (hour >= 5 && hour < 9) {
      // Morning peak (showers, breakfast)
      return _getRandomDouble(8.0, 20.0);
    } else if (hour >= 9 && hour < 17) {
      // Day - moderate usage
      return _getRandomDouble(3.0, 10.0);
    } else if (hour >= 17 && hour < 22) {
      // Evening peak (dinner, baths)
      return _getRandomDouble(6.0, 15.0);
    } else {
      // Late night - low usage
      return _getRandomDouble(1.0, 5.0);
    }
  }

  // Multiplier based on weekday
  static double _getWeekdayMultiplier(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
      case DateTime.sunday:
        // Weekends - higher usage
        return 1.3;
      case DateTime.friday:
        // Fridays - slightly elevated usage
        return 1.1;
      case DateTime.monday:
        // Mondays - slightly reduced usage
        return 0.9;
      default:
        // Regular workdays
        return 1.0;
    }
  }

  // Generate flow data with progress tracking
  static Future<void> _generateFlowData(int centralUnitId, String groupName,
      String unitName, void Function(String, double) onProgress) async {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final endDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    final totalDays = endDate.difference(startDate).inDays;
    int currentRecord = 0;
    final totalRecords = totalDays * 24 * 3;

    print('Generating flow data for $groupName - $unitName');
    print('Days: $totalDays, Total records: $totalRecords');

    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      for (int hour = 0; hour < 24; hour++) {
        for (int minute = 0; minute < 60; minute += 20) {
          final timestamp =
              DateTime(date.year, date.month, date.day, hour, minute);

          final flow = Flow(
            centralUnitID: centralUnitId,
            volume: _generateFlowRate(timestamp),
            date: timestamp,
          );
          await _db.addFlow(flow);

          currentRecord++;
          onProgress(
              'Group: $groupName\nUnit: $unitName\nRecords: $currentRecord/$totalRecords',
              currentRecord / totalRecords);

          if (currentRecord % 100 == 0) {
            print(
                '$groupName - $unitName: Generated $currentRecord/$totalRecords records');
          }
        }
      }
    }
  }

  // Generate leak probes for a central unit
  static Future<void> _generateLeakProbes(int centralUnitId) async {
    final probeCount = _random.nextInt(4); // 0 to 3 probes
    for (int i = 0; i < probeCount; i++) {
      final probe = LeakProbe(
        name: 'Probe ${i + 1} for unit $centralUnitId',
        centralUnitID: centralUnitId,
        stmId: [centralUnitId, i, i + centralUnitId],
        description: 'Test probe ${i + 1} description',
        imagePath: null,
        address: i,
      );
      probe.batteryLevel = Random().nextInt(100);
      await _db.addLeakProbe(probe);
    }
  }

  // Generate central units for a group with progress tracking
  static Future<void> _generateCentralUnits(
    int groupId,
    String groupName,
    void Function(String, double) onProgress,
  ) async {
    final unitCount = _random.nextInt(3) + 1;

    for (int i = 0; i < unitCount; i++) {
      final unitName = 'Unit ${i + 1} for group $groupId';
      onProgress('Creating $unitName for $groupName...', 0);

      final unit = CentralUnit(
        name: unitName,
        addressIP: MyStrings.mockIp,
        addressMAC: _generateMacAddress(),
        password: "admin",
        isValveNO: true,
        impulsesPerLiter: 1000,
        description: 'Test unit ${i + 1} description',
        imagePath: null,
        timezoneId: 37,
        isRegistered: false,
        isDeleted: false,
        hardwareID: '',
      );

      final centralUnitId = await _db.addCentralUnit(unit);
      await _db.addCentralUnitToGroup(groupId, centralUnitId);
      await _generateLeakProbes(centralUnitId);

      await _generateFlowData(
        centralUnitId,
        groupName,
        unitName,
        onProgress,
      );
    }
  }

  // Main function to generate test data with progress tracking
  static Future<void> generateTestData(
      void Function(String, double) onProgress) async {
    try {
      await _db.clearDatabase();
      _appData.clearData();
      onProgress('Clearing database...', 0);
      await Future.delayed(const Duration(milliseconds: 100));

      final groupNames = [
        'Group 1',
        'Group 2',
        'Group 3',
        // 'Duży salon',
        // 'Mały salon',
        // 'Kuchnia',
        // 'Sypialnia',
        // 'Łazienka',
        // 'Garaż',
        // 'Piwnica',
        // 'Taras',
        // 'Ogród'
      ];

      for (int i = 0; i < groupNames.length; i++) {
        final groupName = groupNames[i];
        onProgress('Creating group: $groupName...', i / groupNames.length);
        await Future.delayed(const Duration(milliseconds: 100));

        print('Generating data for $groupName...');
        final group = Group(name: groupName);
        final groupId = await _db.addGroup(group);

        await _generateCentralUnits(
          groupId,
          groupName,
          onProgress,
        );
      }

      onProgress(MyStrings.dataGenerationCompleted, 1.0);
      await Future.delayed(const Duration(milliseconds: 100));
      await _appData.loadData();
    } catch (e, stackTrace) {
      print('Error generating data: $e');
      print(stackTrace);
      onProgress('Error: $e', 1.0);
    }
  }
}
