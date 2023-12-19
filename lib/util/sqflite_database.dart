// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';

// class Wallpaper {
//   // Your Wallpaper class definition here
// }

// class WallpaperStorage<T>  {
//   final String storageKey;
//   final T Function(Map<String, dynamic>) fromJson;
//   final Map<String, dynamic> Function(T) toJson;
//   final SharedPreferences prefs;

//   WallpaperStorage({
//     required this.storageKey,
//     required this.fromJson,
//     required this.toJson,
//     required this.prefs,
//   });

//   Future<String?> getEmail() async {
//     return prefs.getString('userEmail');
//   }

//   Future<String?> getName() async {
//     return prefs.getString('userName');
//   }

//   Future<Database> _getDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'app_database.db');
//     return openDatabase(path, version: 1,
//         onCreate: (Database db, int version) async {
//       await db.execute('''
//           CREATE TABLE $storageKey (
//             id TEXT PRIMARY KEY,
//             jsonData TEXT
//           )
//         ''');
//     });
//   }

//   Future<void> storeData(T data, BuildContext context) async {
//     if (kDebugMode) {
//       print('Storing data...');
//     }
//     final dataList = await getDataList();

//     dataList.add(data);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Added Successfully In Favorites'),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     await backupData(storageKey, dataList);
//     if (kDebugMode) {
//       print('Data stored.');
//     }
//   }

//   Future<List<T>> getDataList() async {
//     if (kDebugMode) {
//       print('Getting data list...');
//     }

//     final db = await _getDatabase();
//     List<Map> maps = await db.query(storageKey);

//     if (maps.isNotEmpty) {
//       if (kDebugMode) {
//         print('Data retrieved.');
//       }
//       return maps.map((map) => fromJson(jsonDecode(map['jsonData']))).cast<T>().toList();
//     }

//     // Data doesn't exist, return an empty list
//     return [];
//   }

//   Future<void> backupData(String key, List<T> dataList) async {
//     if (kDebugMode) {
//       print('Backing up data...');
//     }
//     final email = await getEmail();
//     final name = await getName();
//     final db = await _getDatabase();

//     await db.transaction((txn) async {
//       await txn.delete(storageKey);
//       dataList.forEach((data) async {
//         await txn.insert(
//           storageKey,
//           {'id': uniqueId, 'jsonData': jsonEncode(toJson(data))},
//         );
//       });
//     });

//     if (kDebugMode) {
//       print('Data backed up successfully.');
//     }
//   }

//   Future<List<T>> restoreData() async {
//     try {
//       final email = await getEmail();
//       final name = await getName();
//       final db = await _getDatabase();

//       List<Map> maps = await db.query(
//         storageKey,
//         where: 'id = ?',
//         whereArgs: [email],
//       );

//       if (maps.isNotEmpty) {
//         return maps.map((map) => fromJson(jsonDecode(map['jsonData']))).cast<T>().toList();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error restoring data: $e');
//       }
//     }

//     return [];
//   }

//   Future<void> removeData(String dataId, BuildContext context) async {
//     if (kDebugMode) {
//       print('Removing data...');
//     }

//     final dataList = await getDataList();
//     dataList.removeWhere(( data) {
//       if (data is Wallpaper && data.id == dataId) {
//         return true;
//       }
//       return false;
//     });

//     final db = await _getDatabase();
//     await db.transaction((txn) async {
//       await txn.delete(storageKey);
//       dataList.forEach((data) async {
//         await txn.insert(
//           storageKey,
//           {'id': uniqueId, 'jsonData': jsonEncode(toJson(data))},
//         );
//       });
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Removed Successfully From Favorites'),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     if (kDebugMode) {
//       print('Data removed.');
//     }
//   }
// }
