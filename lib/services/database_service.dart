import 'package:leak_guard/models/group_central_relation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/leak_probe.dart';
import 'package:leak_guard/models/flow.dart';

/// A singleton service class that manages SQLite database operations for the LeakGuard application.
///
/// Database Structure:
/// - groups: Stores groups information
/// - central_units: Stores central unit devices information
/// - group_central: Junction table for many-to-many relationship between groups and central units
/// - leak_probes: Stores leak probe sensors information (one-to-many with central units)
/// - flows: Stores water flow measurements
///
/// The service provides:
/// 1. Database initialization with proper table structure and foreign key constraints
/// 2. CRUD operations for all entities:
///    - Groups (create, read, update, delete)
///    - Central Units (create, read, update, delete)
///    - Leak Probes (create, read, update, delete)
///    - Flow measurements (create, read, delete)
/// 3. Relationship management:
///    - Many-to-many relationship between Groups and Central Units
///    - One-to-many relationship between Central Units and Leak Probes
///    - One-to-many relationship between Central Units and Flow measurements
///
/// Special Features:
/// - Uses cascade deletion for maintaining referential integrity
/// - Stores timestamps as secondsSinceEpoch (millisSinceEpoch ~/1000) for flow measurements
/// - Provides date range queries for flow measurements
/// - Implements singleton pattern to ensure single database instance
///
/// Note: DateTime conversion for flow measurements:
/// - When storing: DateTime.millisecondsSinceEpoch ~/ 1000 (converts to seconds)
/// - When retrieving: DateTime.fromMillisecondsSinceEpoch(seconds * 1000)
///
/// Usage Example:
/// ```dart
/// final dbService = DatabaseService.instance;
/// final group = Group(name: 'Test Group');
/// final groupId = await dbService.addGroup(group);
/// ```

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  // Groups table
  final String _groupsTableName = "groups";
  final String _groupsGroupIDColumnName = "groupID";
  final String _groupsNameColumnName = "name";
  final String _groupsPositionColumnName = "position";
  final String _groupsDescriptionColumnName = "description";
  final String _groupsImagePathColumnName = "imagePath";

  // CentralUnits table
  final String _centralUnitsTableName = "central_units";
  final String _centralUnitsCentralUnitIDColumnName = "centralUnitID";
  final String _centralUnitsNameColumnName = "name";
  final String _centralUnitsAddressIPColumnName = "addressIP";
  final String _centralUnitsAddressMACColumnName = "addressMAC";
  final String _centralUnitsHardwareIDColumnName = "hardwareID";
  final String _centralUnitsIsValveNOColumnName = "isValveNO";
  final String _centralUnitsImpulsesPerLiterColumnName = "impulsesPerLiter";
  final String _centralUnitsPasswordColumnName = "password";
  final String _centralUnitsDescriptionColumnName = "description";
  final String _centralUnitsImagePathColumnName = "imagePath";

  // GroupCentral table (junction table for many-to-many)
  final String _groupCentralTableName = "group_central";
  final String _groupCentralGroupIDColumnName = "groupID";
  final String _groupCentralCentralUnitIDColumnName = "centralUnitID";

  // LeakProbes table
  final String _leakProbesTableName = "leak_probes";
  final String _leakProbesLeakProbeIDColumnName = "leakProbeID";
  final String _leakProbesCentralUnitIDColumnName = "centralUnitID";
  final String _leakProbesNameColumnName = "name";
  final String _leakProbesSTMID1ColumnName = "stmId1";
  final String _leakProbesSTMID2ColumnName = "stmId2";
  final String _leakProbesSTMID3ColumnName = "stmId3";
  final String _leakProbesAddressColumnName = "address";
  final String _leakProbesBatteryLevelColumnName = "batteryLevel";
  final String _leakProbesBlockedColumnName = "blocked";
  final String _leakProbesDescriptionColumnName = "description";
  final String _leakProbesImagePathColumnName = "imagePath";

  // Flows table
  final String _flowsTableName = "flows";
  final String _flowsFlowIDColumnName = "flowID";
  final String _flowsCentralUnitIDColumnName = "centralUnitID";
  final String _flowsVolumeColumnName = "volume";
  final String _flowsDateColumnName = "date";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    // Create groups table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_groupsTableName (
        $_groupsGroupIDColumnName INTEGER PRIMARY KEY,
        $_groupsNameColumnName TEXT NOT NULL,
        $_groupsPositionColumnName INTEGER NOT NULL DEFAULT 0,
        $_groupsDescriptionColumnName TEXT,
        $_groupsImagePathColumnName TEXT
      )
    ''');

    // Create central_units table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_centralUnitsTableName (
        $_centralUnitsCentralUnitIDColumnName INTEGER PRIMARY KEY,
        $_centralUnitsNameColumnName TEXT NOT NULL,
        $_centralUnitsAddressIPColumnName TEXT NOT NULL,
        $_centralUnitsAddressMACColumnName TEXT NOT NULL,
        $_centralUnitsPasswordColumnName TEXT NOT NULL,
        $_centralUnitsDescriptionColumnName TEXT,
        $_centralUnitsImagePathColumnName TEXT,
        $_centralUnitsIsValveNOColumnName INTEGER NOT NULL DEFAULT 0,
        $_centralUnitsImpulsesPerLiterColumnName INTEGER NOT NULL DEFAULT 1,
        $_centralUnitsHardwareIDColumnName TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Create group_central junction table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_groupCentralTableName (
        $_groupCentralGroupIDColumnName INTEGER NOT NULL,
        $_groupCentralCentralUnitIDColumnName INTEGER NOT NULL,
        PRIMARY KEY ($_groupCentralGroupIDColumnName, $_groupCentralCentralUnitIDColumnName),
        FOREIGN KEY ($_groupCentralGroupIDColumnName) 
          REFERENCES $_groupsTableName ($_groupsGroupIDColumnName) 
          ON DELETE CASCADE,
        FOREIGN KEY ($_groupCentralCentralUnitIDColumnName) 
          REFERENCES $_centralUnitsTableName ($_centralUnitsCentralUnitIDColumnName) 
          ON DELETE CASCADE
      )
    ''');
    // Create leak_probes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_leakProbesTableName (
        $_leakProbesLeakProbeIDColumnName INTEGER PRIMARY KEY,
        $_leakProbesCentralUnitIDColumnName INTEGER NOT NULL,
        $_leakProbesNameColumnName TEXT NOT NULL,
        $_leakProbesSTMID1ColumnName INTEGER NOT NULL,
        $_leakProbesSTMID2ColumnName INTEGER NOT NULL,
        $_leakProbesSTMID3ColumnName INTEGER NOT NULL,
        $_leakProbesAddressColumnName INTEGER NOT NULL,
        $_leakProbesBatteryLevelColumnName INTEGER NOT NULL DEFAULT 100,
        $_leakProbesBlockedColumnName INTEGER NOT NULL DEFAULT 0,
        $_leakProbesDescriptionColumnName TEXT,
        $_leakProbesImagePathColumnName TEXT,
        UNIQUE($_leakProbesCentralUnitIDColumnName, $_leakProbesSTMID1ColumnName, $_leakProbesSTMID2ColumnName, $_leakProbesSTMID3ColumnName),
        FOREIGN KEY ($_leakProbesCentralUnitIDColumnName) 
          REFERENCES $_centralUnitsTableName ($_centralUnitsCentralUnitIDColumnName) 
          ON DELETE CASCADE
      )
    ''');

    // Create flows table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_flowsTableName (
        $_flowsFlowIDColumnName INTEGER PRIMARY KEY,
        $_flowsCentralUnitIDColumnName INTEGER NOT NULL,
        $_flowsVolumeColumnName REAL NOT NULL,
        $_flowsDateColumnName INTEGER NOT NULL,
        FOREIGN KEY ($_flowsCentralUnitIDColumnName) 
          REFERENCES $_centralUnitsTableName ($_centralUnitsCentralUnitIDColumnName) 
          ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "leak_guard.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
    return database;
  }

  // Group CRUD operations
  Future<int> addGroup(Group group) async {
    final db = await database;
    final tableInfo = await db.rawQuery('PRAGMA table_info($_groupsTableName)');
    final hasPosition =
        tableInfo.any((col) => col['name'] == _groupsPositionColumnName);

    int nextPosition = 0;
    if (hasPosition) {
      nextPosition = (Sqflite.firstIntValue(await db.rawQuery(
                  'SELECT MAX($_groupsPositionColumnName) FROM $_groupsTableName')) ??
              -1) +
          1;
    }

    return await db.insert(
      _groupsTableName,
      {
        _groupsNameColumnName: group.name,
        _groupsPositionColumnName: nextPosition + 1,
        _groupsDescriptionColumnName: group.description,
        _groupsImagePathColumnName: group.imagePath,
      },
    );
  }

  Future<List<Group>> getGroups() async {
    final db = await database;
    final data = await db.query(
      _groupsTableName,
      orderBy: '$_groupsPositionColumnName ASC',
    );
    return data
        .map((e) => Group(name: e[_groupsNameColumnName] as String)
          ..groupdID = e[_groupsGroupIDColumnName] as int
          ..position = e[_groupsPositionColumnName] as int
          ..description = e[_groupsDescriptionColumnName] as String?
          ..imagePath = e[_groupsImagePathColumnName] as String?)
        .toList();
  }

  Future<Group?> getGroup(int groupID) async {
    final db = await database;
    final data = await db.query(
      _groupsTableName,
      where: '$_groupsGroupIDColumnName = ?',
      whereArgs: [groupID],
    );
    if (data.isEmpty) return null;
    return Group(name: data.first[_groupsNameColumnName] as String)
      ..groupdID = data.first[_groupsGroupIDColumnName] as int
      ..description = data.first[_groupsDescriptionColumnName] as String?
      ..imagePath = data.first[_groupsImagePathColumnName] as String?;
  }

  Future updateGroup(Group group) async {
    final db = await database;
    await db.update(
      _groupsTableName,
      {
        _groupsNameColumnName: group.name,
        _groupsDescriptionColumnName: group.description,
        _groupsImagePathColumnName: group.imagePath,
      },
      where: '$_groupsGroupIDColumnName = ?',
      whereArgs: [group.groupdID],
    );
  }

  Future deleteGroup(int groupID) async {
    final db = await database;
    await db.delete(
      _groupsTableName,
      where: '$_groupsGroupIDColumnName = ?',
      whereArgs: [groupID],
    );
  }

  Future swapGroupsPositions(int groupId1, int groupId2) async {
    final db = await database;

    await db.transaction((txn) async {
      final group1Data = await txn.query(
        _groupsTableName,
        columns: [_groupsPositionColumnName],
        where: '$_groupsGroupIDColumnName = ?',
        whereArgs: [groupId1],
      );

      final group2Data = await txn.query(
        _groupsTableName,
        columns: [_groupsPositionColumnName],
        where: '$_groupsGroupIDColumnName = ?',
        whereArgs: [groupId2],
      );

      if (group1Data.isEmpty || group2Data.isEmpty) return;

      final position1 = group1Data.first[_groupsPositionColumnName] as int;
      final position2 = group2Data.first[_groupsPositionColumnName] as int;

      await txn.update(
        _groupsTableName,
        {_groupsPositionColumnName: position2},
        where: '$_groupsGroupIDColumnName = ?',
        whereArgs: [groupId1],
      );

      await txn.update(
        _groupsTableName,
        {_groupsPositionColumnName: position1},
        where: '$_groupsGroupIDColumnName = ?',
        whereArgs: [groupId2],
      );
    });
  }

  Future resetGroupPositions() async {
    final db = await database;

    final groups = await db.query(
      _groupsTableName,
      orderBy: '$_groupsPositionColumnName ASC',
    );

    await db.transaction((txn) async {
      for (int i = 0; i < groups.length; i++) {
        await txn.update(
          _groupsTableName,
          {_groupsPositionColumnName: i},
          where: '$_groupsGroupIDColumnName = ?',
          whereArgs: [groups[i][_groupsGroupIDColumnName]],
        );
      }
    });
  }

  // CentralUnit CRUD operations
  Future<int> addCentralUnit(CentralUnit unit) async {
    final db = await database;
    return await db.insert(
      _centralUnitsTableName,
      {
        _centralUnitsNameColumnName: unit.name,
        _centralUnitsAddressIPColumnName: unit.addressIP,
        _centralUnitsAddressMACColumnName: unit.addressMAC,
        _centralUnitsPasswordColumnName: unit.password,
        _centralUnitsDescriptionColumnName: unit.description,
        _centralUnitsImagePathColumnName: unit.imagePath,
        _centralUnitsIsValveNOColumnName: unit.isValveNO ? 1 : 0,
        _centralUnitsImpulsesPerLiterColumnName: unit.impulsesPerLiter,
        _centralUnitsHardwareIDColumnName: unit.hardwareID,
      },
    );
  }

  Future<List<CentralUnit>> getCentralUnits() async {
    final db = await database;
    final data = await db.query(_centralUnitsTableName);
    return data
        .map((e) => CentralUnit(
              name: e[_centralUnitsNameColumnName] as String,
              addressIP: e[_centralUnitsAddressIPColumnName] as String,
              addressMAC: e[_centralUnitsAddressMACColumnName] as String,
              password: e[_centralUnitsPasswordColumnName] as String,
              isValveNO: (e[_centralUnitsIsValveNOColumnName] as int) == 1,
              impulsesPerLiter:
                  e[_centralUnitsImpulsesPerLiterColumnName] as int,
              description: e[_centralUnitsDescriptionColumnName] as String?,
              imagePath: e[_centralUnitsImagePathColumnName] as String?,
              hardwareID: e[_centralUnitsHardwareIDColumnName] as String,
            )..centralUnitID = e[_centralUnitsCentralUnitIDColumnName] as int)
        .toList();
  }

  Future<Map<int, CentralUnit>> getCentralUnitsAndIDs() async {
    final db = await database;
    final data = await db.query(_centralUnitsTableName);

    return data.fold<Map<int, CentralUnit>>({}, (map, e) {
      final unit = CentralUnit(
        name: e[_centralUnitsNameColumnName] as String,
        addressIP: e[_centralUnitsAddressIPColumnName] as String,
        addressMAC: e[_centralUnitsAddressMACColumnName] as String,
        password: e[_centralUnitsPasswordColumnName] as String,
        isValveNO: (e[_centralUnitsIsValveNOColumnName] as int) == 1,
        impulsesPerLiter: e[_centralUnitsImpulsesPerLiterColumnName] as int,
        description: e[_centralUnitsDescriptionColumnName] as String?,
        imagePath: e[_centralUnitsImagePathColumnName] as String?,
        hardwareID: e[_centralUnitsHardwareIDColumnName] as String,
      )..centralUnitID = e[_centralUnitsCentralUnitIDColumnName] as int;

      map[unit.centralUnitID!] = unit;
      return map;
    });
  }

  Future<List<CentralUnit>> getGroupCentralUnits(int groupID) async {
    final db = await database;
    final data = await db.rawQuery('''
      SELECT cu.* 
      FROM $_centralUnitsTableName cu
      INNER JOIN $_groupCentralTableName gc 
        ON cu.$_centralUnitsCentralUnitIDColumnName = gc.$_groupCentralCentralUnitIDColumnName
      WHERE gc.$_groupCentralGroupIDColumnName = ?
    ''', [groupID]);

    return data
        .map((e) => CentralUnit(
              name: e[_centralUnitsNameColumnName] as String,
              addressIP: e[_centralUnitsAddressIPColumnName] as String,
              addressMAC: e[_centralUnitsAddressMACColumnName] as String,
              password: e[_centralUnitsPasswordColumnName] as String,
              isValveNO: (e[_centralUnitsIsValveNOColumnName] as int) == 1,
              impulsesPerLiter:
                  e[_centralUnitsImpulsesPerLiterColumnName] as int,
              description: e[_centralUnitsDescriptionColumnName] as String?,
              imagePath: e[_centralUnitsImagePathColumnName] as String?,
              hardwareID: e[_centralUnitsHardwareIDColumnName] as String,
            )..centralUnitID = e[_centralUnitsCentralUnitIDColumnName] as int)
        .toList();
  }

  Future<List<int>> getGroupCentralUnitsIDs(int groupID) async {
    final db = await database;
    final data = await db.rawQuery('''
      SELECT cu.* 
      FROM $_centralUnitsTableName cu
      INNER JOIN $_groupCentralTableName gc 
        ON cu.$_centralUnitsCentralUnitIDColumnName = gc.$_groupCentralCentralUnitIDColumnName
      WHERE gc.$_groupCentralGroupIDColumnName = ?
    ''', [groupID]);

    return data
        .map((e) => e[_centralUnitsCentralUnitIDColumnName] as int)
        .toList();
  }

  Future<CentralUnit?> getCentralUnit(int centralUnitID) async {
    final db = await database;
    final data = await db.query(
      _centralUnitsTableName,
      where: '$_centralUnitsCentralUnitIDColumnName = ?',
      whereArgs: [centralUnitID],
    );
    if (data.isEmpty) return null;
    return CentralUnit(
      name: data.first[_centralUnitsNameColumnName] as String,
      addressIP: data.first[_centralUnitsAddressIPColumnName] as String,
      addressMAC: data.first[_centralUnitsAddressMACColumnName] as String,
      password: data.first[_centralUnitsPasswordColumnName] as String,
      isValveNO: (data.first[_centralUnitsIsValveNOColumnName] as int) == 1,
      impulsesPerLiter:
          data.first[_centralUnitsImpulsesPerLiterColumnName] as int,
      description: data.first[_centralUnitsDescriptionColumnName] as String?,
      imagePath: data.first[_centralUnitsImagePathColumnName] as String?,
      hardwareID: data.first[_centralUnitsHardwareIDColumnName] as String,
    )..centralUnitID = data.first[_centralUnitsCentralUnitIDColumnName] as int;
  }

  Future updateCentralUnit(CentralUnit unit) async {
    final db = await database;
    await db.update(
      _centralUnitsTableName,
      {
        _centralUnitsNameColumnName: unit.name,
        _centralUnitsAddressIPColumnName: unit.addressIP,
        _centralUnitsAddressMACColumnName: unit.addressMAC,
        _centralUnitsPasswordColumnName: unit.password,
        _centralUnitsIsValveNOColumnName: unit.isValveNO ? 1 : 0,
        _centralUnitsImpulsesPerLiterColumnName: unit.impulsesPerLiter,
        _centralUnitsDescriptionColumnName: unit.description,
        _centralUnitsImagePathColumnName: unit.imagePath,
        _centralUnitsHardwareIDColumnName: unit.hardwareID,
      },
      where: '$_centralUnitsCentralUnitIDColumnName = ?',
      whereArgs: [unit.centralUnitID],
    );
  }

  Future deleteCentralUnit(int centralUnitID) async {
    final db = await database;
    await db.delete(
      _centralUnitsTableName,
      where: '$_centralUnitsCentralUnitIDColumnName = ?',
      whereArgs: [centralUnitID],
    );
  }

  // Group-CentralUnit relationship operations
  Future addCentralUnitToGroup(int groupID, int centralUnitID) async {
    final db = await database;
    await db.insert(
      _groupCentralTableName,
      {
        _groupCentralGroupIDColumnName: groupID,
        _groupCentralCentralUnitIDColumnName: centralUnitID,
      },
    );
  }

  Future removeCentralUnitFromGroup(int groupID, int centralUnitID) async {
    final db = await database;
    await db.delete(
      _groupCentralTableName,
      where:
          '$_groupCentralGroupIDColumnName = ? AND $_groupCentralCentralUnitIDColumnName = ?',
      whereArgs: [groupID, centralUnitID],
    );
  }

  Future<List<GroupCentralRelation>> getAllGroupCentralRelations() async {
    final db = await database;
    final data = await db.query(_groupCentralTableName);
    return data
        .map((e) => GroupCentralRelation(
              groupId: e[_groupCentralGroupIDColumnName] as int,
              centralUnitId: e[_groupCentralCentralUnitIDColumnName] as int,
            ))
        .toList();
  }

  // LeakProbe CRUD operations
  Future<int> addLeakProbe(LeakProbe probe) async {
    final db = await database;
    return await db.insert(
      _leakProbesTableName,
      {
        _leakProbesCentralUnitIDColumnName: probe.centralUnitID,
        _leakProbesNameColumnName: probe.name,
        _leakProbesSTMID1ColumnName: probe.stmId[0],
        _leakProbesSTMID2ColumnName: probe.stmId[1],
        _leakProbesSTMID3ColumnName: probe.stmId[2],
        _leakProbesAddressColumnName: probe.address,
        _leakProbesBatteryLevelColumnName: probe.batteryLevel,
        _leakProbesBlockedColumnName: probe.isAlarmed ? 1 : 0,
        _leakProbesDescriptionColumnName: probe.description,
        _leakProbesImagePathColumnName: probe.imagePath,
      },
    );
  }

  LeakProbe _mapToLeakProbe(Map<String, dynamic> data) {
    return LeakProbe(
      name: data[_leakProbesNameColumnName] as String,
      centralUnitID: data[_leakProbesCentralUnitIDColumnName] as int,
      stmId: [
        data[_leakProbesSTMID1ColumnName] as int,
        data[_leakProbesSTMID2ColumnName] as int,
        data[_leakProbesSTMID3ColumnName] as int,
      ],
      address: data[_leakProbesAddressColumnName] as int,
      description: data[_leakProbesDescriptionColumnName] as String?,
      imagePath: data[_leakProbesImagePathColumnName] as String?,
    )
      ..leakProbeID = data[_leakProbesLeakProbeIDColumnName] as int
      ..batteryLevel = data[_leakProbesBatteryLevelColumnName] as int
      ..isAlarmed = (data[_leakProbesBlockedColumnName] as int) == 1;
  }

  Future<List<LeakProbe>> getCentralUnitLeakProbes(int centralUnitID) async {
    final db = await database;
    final data = await db.query(
      _leakProbesTableName,
      where: '$_leakProbesCentralUnitIDColumnName = ?',
      whereArgs: [centralUnitID],
    );
    return data.map(_mapToLeakProbe).toList();
  }

  Future<List<LeakProbe>> getAllLeakProbes() async {
    final db = await database;
    final data = await db.query(
      _leakProbesTableName,
      orderBy:
          '$_leakProbesCentralUnitIDColumnName ASC, $_leakProbesNameColumnName ASC',
    );
    return data.map(_mapToLeakProbe).toList();
  }

  Future<LeakProbe?> getLeakProbe(int leakProbeID) async {
    final db = await database;
    final data = await db.query(
      _leakProbesTableName,
      where: '$_leakProbesLeakProbeIDColumnName = ?',
      whereArgs: [leakProbeID],
    );
    if (data.isEmpty) return null;
    return _mapToLeakProbe(data.first);
  }

  Future updateLeakProbe(LeakProbe probe) async {
    final db = await database;
    await db.update(
      _leakProbesTableName,
      {
        _leakProbesNameColumnName: probe.name,
        _leakProbesAddressColumnName: probe.address,
        _leakProbesBatteryLevelColumnName: probe.batteryLevel,
        _leakProbesBlockedColumnName: probe.isAlarmed ? 1 : 0,
        _leakProbesDescriptionColumnName: probe.description,
        _leakProbesImagePathColumnName: probe.imagePath,
      },
      where: '$_leakProbesLeakProbeIDColumnName = ?',
      whereArgs: [probe.leakProbeID],
    );
  }

  Future deleteLeakProbe(int leakProbeID) async {
    final db = await database;
    await db.delete(
      _leakProbesTableName,
      where: '$_leakProbesLeakProbeIDColumnName = ?',
      whereArgs: [leakProbeID],
    );
  }

  Future updateLeakProbeStatus(
      int leakProbeID, int batteryLevel, bool blocked) async {
    final db = await database;
    await db.update(
      _leakProbesTableName,
      {
        _leakProbesBatteryLevelColumnName: batteryLevel,
        _leakProbesBlockedColumnName: blocked ? 1 : 0,
      },
      where: '$_leakProbesLeakProbeIDColumnName = ?',
      whereArgs: [leakProbeID],
    );
  }

  // Flow CRUD operations
  Future<int> addFlow(Flow flow) async {
    final db = await database;
    return await db.insert(
      _flowsTableName,
      {
        _flowsCentralUnitIDColumnName: flow.centralUnitID,
        _flowsVolumeColumnName: flow.volume,
        _flowsDateColumnName: flow.unixTime(),
      },
    );
  }

  Future<List<Flow>> getCentralUnitFlows(int centralUnitID) async {
    final db = await database;
    final data = await db.query(
      _flowsTableName,
      where: '$_flowsCentralUnitIDColumnName = ?',
      whereArgs: [centralUnitID],
      orderBy: '$_flowsDateColumnName DESC',
    );
    return data
        .map((e) => Flow(
              centralUnitID: e[_flowsCentralUnitIDColumnName] as int,
              volume: e[_flowsVolumeColumnName] as num,
              date: DateTime.fromMillisecondsSinceEpoch(
                  (e[_flowsDateColumnName] as int) * 1000),
            )..flowID = e[_flowsFlowIDColumnName] as int)
        .toList();
  }

  Future<List<Flow>> getCentralUnitFlowsBetweenDates(
    int centralUnitID,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final data = await db.query(
      _flowsTableName,
      where:
          '$_flowsCentralUnitIDColumnName = ? AND $_flowsDateColumnName BETWEEN ? AND ?',
      whereArgs: [
        centralUnitID,
        startDate.millisecondsSinceEpoch ~/ 1000,
        endDate.millisecondsSinceEpoch ~/ 1000
      ],
      orderBy: '$_flowsDateColumnName DESC',
    );
    return data
        .map((e) => Flow(
              centralUnitID: e[_flowsCentralUnitIDColumnName] as int,
              volume: e[_flowsVolumeColumnName] as num,
              date: DateTime.fromMillisecondsSinceEpoch(
                  (e[_flowsDateColumnName] as int) * 1000),
            )..flowID = e[_flowsFlowIDColumnName] as int)
        .toList();
  }

  Future deleteFlow(int flowID) async {
    final db = await database;
    await db.delete(
      _flowsTableName,
      where: '$_flowsFlowIDColumnName = ?',
      whereArgs: [flowID],
    );
  }

  Future<Flow?> getLatestFlow(int centralUnitID) async {
    final db = await database;
    final data = await db.query(
      _flowsTableName,
      where: '$_flowsCentralUnitIDColumnName = ?',
      whereArgs: [centralUnitID],
      orderBy: '$_flowsDateColumnName DESC',
      limit: 1,
    );

    if (data.isEmpty) return null;

    return Flow(
      centralUnitID: data[0][_flowsCentralUnitIDColumnName] as int,
      volume: data[0][_flowsVolumeColumnName] as num,
      date: DateTime.fromMillisecondsSinceEpoch(
          (data[0][_flowsDateColumnName] as int) * 1000),
    )..flowID = data[0][_flowsFlowIDColumnName] as int;
  }

  Future deleteFlowsFromDate(int centralUnitID, DateTime fromDate) async {
    final db = await database;
    await db.delete(
      _flowsTableName,
      where:
          '$_flowsCentralUnitIDColumnName = ? AND $_flowsDateColumnName >= ?',
      whereArgs: [centralUnitID, fromDate.millisecondsSinceEpoch ~/ 1000],
    );
  }

  Future addCentralUnitsFlows(int centralUnitID, List<Flow> flows) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final flow in flows) {
        batch.insert(
          _flowsTableName,
          {
            _flowsCentralUnitIDColumnName: centralUnitID,
            _flowsVolumeColumnName: flow.volume,
            _flowsDateColumnName: flow.unixTime(),
          },
        );
      }

      await batch.commit(noResult: true);
    });
  }

  // Additional utility methods
  Future clearDatabase() async {
    final db = await database;
    await db.delete(_flowsTableName);
    await db.delete(_leakProbesTableName);
    await db.delete(_groupCentralTableName);
    await db.delete(_centralUnitsTableName);
    await db.delete(_groupsTableName);
  }

  Future createDatabase() async {
    final db = await database;
    await _onCreate(db, 1);
  }
}
