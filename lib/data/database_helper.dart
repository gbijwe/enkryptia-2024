import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // final dbPath = await getDatabasesPath();
    final directory = await getDatabasesPath();
    final path = join(directory, 'database.db');

    // Check if the database already exists
    final exists = await databaseExists(path);

    if (!exists) {
      // If not, copy it from the assets
      try {
        await Directory(dirname(path)).create(recursive: true);

        // Copy from assets
        final data = await rootBundle.load(path);
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint('Error copying database: $e');
      }
    }

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the locationHistory table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS locationHistory (
            salesperson_id STRING,
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lat REAL,
            long REAL,
            datetime TIMESTAMP,
            isSynced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> insertLocation(double lat, double long, String timestamp) async {
    final db = await database;
    final time = DateTime.parse(timestamp).toIso8601String();
    await db.insert(
      'locationHistory',
      {
        'salesperson_id': "MH31AB2308",
        'lat': lat,
        'long': long,
        'datetime': time,
      },
    );
  }
  
  Future<List<Map<String, dynamic>>> getLocationHistory() async {
    final db = await database;
    return await db.query('locationHistory', orderBy: 'datetime ASC');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLocations() async {
    final db = await database;
    final res = await db.query(
      'locationHistory',
      columns: ['salesperson_id', 'datetime', 'lat', 'long', 'isSynced'],
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    debugPrint("UNSYNCED LOCATIONS:");
    debugPrint(res.toString());
    return res;  
  }

  Future<void> updateLocationSyncStatus(String timestamp, int isSynced) async {
    final db = await database;
    debugPrint("Is Updating");
    debugPrint(timestamp);
    final time = DateTime.parse(timestamp).toIso8601String().substring(0, "2024-08-24T03:45:35.809342".length);
    debugPrint(time);
    final res = await db.rawUpdate(
      // 'locationHistory',
      // {'isSynced': isSynced},
      // where: 'timestamp = ?',
      // whereArgs: [timestamp],
      'UPDATE locationHistory SET isSynced = ? WHERE datetime = ?',
      [isSynced, time]
    );
    debugPrint("res");
    debugPrint(res.toString());
  }

}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'location_history.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE locationHistory(id INTEGER PRIMARY KEY, latitude REAL, longitude REAL, timestamp TEXT, isSynced INTEGER)',
//         );
//       },
//     );
//   }

//   Future<void> insertLocation(double latitude, double longitude, String timestamp, int isSynced) async {
//     final db = await database;
//     await db.insert(
//       'locationHistory',
//       {'latitude': latitude, 'longitude': longitude, 'timestamp': timestamp, 'isSynced': isSynced},
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> updateLocationSyncStatus(String timestamp, int isSynced) async {
//     final db = await database;
//     await db.update(
//       'locationHistory',
//       {'isSynced': isSynced},
//       where: 'timestamp = ?',
//       whereArgs: [timestamp],
//     );
//   }

//   Future<List<Map<String, dynamic>>> getLocationHistory() async {
//     final db = await database;
//     return await db.query('locationHistory');
//   }
// }