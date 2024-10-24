// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class SalesmanTripDatabaseHelper {
//   static final SalesmanTripDatabaseHelper _instance = SalesmanTripDatabaseHelper._internal();
//   factory SalesmanTripDatabaseHelper() => _instance;
//   static Database? _database;

//   SalesmanTripDatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     // final dbPath = await getDatabasesPath();
//     final directory = await getDatabasesPath();
//     final path = join(directory, 'database.db');

//     // Check if the database already exists
//     final exists = await databaseExists(path);

//     if (!exists) {
//       // If not, copy it from the assets
//       try {
//         await Directory(dirname(path)).create(recursive: true);

//         // Copy from assets
//         final data = await rootBundle.load(path);
//         final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

//         await File(path).writeAsBytes(bytes, flush: true);
//       } catch (e) {
//         debugPrint('Error copying database: $e');
//       }
//     }

//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         // Create the locationHistory table if it doesn't exist
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS Salesman_Trip_Database (
//             salesperson_id STRING,
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             start_lat REAL,
//             start_long REAL,
//             start_datetime TIMESTAMP,
//             end_lat REAL,
//             end_long REAL,
//             end_datetime TIMESTAMP,
//             total_time_spent TEXT
//           )
//         ''');
//       },
//     );
//   }

//   Future<void> insertStateLocation(double lat, double long, String timestamp) async {
//     final db = await database;
//     final time = DateTime.parse(timestamp).toIso8601String();
//     await db.insert(
//       'Salesman_Trip_Database',
//       {
//         'start_lat': lat,
//         'start_long': long,
//         'start_datetime': time,
//       },
//     );
//   }

//   Future<void> updateEndLocationAndCalculateTime(int id, double lat, double long, String endTimestamp) async {
//     final db = await database;
//     final endTime = DateTime.parse(endTimestamp).toIso8601String();

//     // Get the start time
//     final List<Map<String, dynamic>> result = await db.query(
//       'Salesman_Trip_Database',
//       columns: ['start_datetime'],
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (result.isNotEmpty) {
//       final startTime = DateTime.parse(result.first['start_datetime']);
//       final endTime = DateTime.parse(endTimestamp);
//       final duration = endTime.difference(startTime);

//       await db.update(
//         'Salesman_Trip_Database',
//         {
//           'end_datetime': endTime.toIso8601String(),
//           'total_time_spent': duration.toString(),
//         },
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//     }
//   }
  
//   Future<List<Map<String, dynamic>>> getSalesmanTripDatabase() async {
//     final db = await database;
//     return await db.query('Salesman_Trip_Database');
//   }

// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesmanTripDatabaseHelper {
  static final SalesmanTripDatabaseHelper _instance = SalesmanTripDatabaseHelper._internal();
  factory SalesmanTripDatabaseHelper() => _instance;
  SalesmanTripDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'salesman_trip_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE Salesman_Trip_Database(id INTEGER PRIMARY KEY, start_lat REAL, start_long REAL, start_datetime TEXT, end_datetime TEXT, total_time_spent TEXT)',
        );
      },
    );
  }


  Future<int> insertStateLocation(double lat, double long, String timestamp) async {
    final db = await database;
    final time = DateTime.parse(timestamp).toIso8601String();
    int id = await db.insert(
      'Salesman_Trip_Database',
      {
        'start_lat': lat,
        'start_long': long,
        'start_datetime': time,
      },
    );
    return id;
  }

  Future<void> updateEndLocationAndCalculateTime(int id, double lat, double long, String endTimestamp) async {
    final db = await database;
    final endTime = DateTime.parse(endTimestamp).toIso8601String();

    // Get the start time
    final List<Map<String, dynamic>> result = await db.query(
      'Salesman_Trip_Database',
      columns: ['start_datetime'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final startTime = DateTime.parse(result.first['start_datetime']);
      final endTime = DateTime.parse(endTimestamp);
      final duration = endTime.difference(startTime);

      await db.update(
        'Salesman_Trip_Database',
        {
          'end_datetime': endTime.toIso8601String(),
          'total_time_spent': duration.toString(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSalesmanTripDatabase() async {
    final db = await database;
    return await db.query('Salesman_Trip_Database');
  }
}