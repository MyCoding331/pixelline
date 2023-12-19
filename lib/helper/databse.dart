// ignore_for_file: avoid_print

import 'dart:async';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WallpaperDatabaseHelper {
  static final WallpaperDatabaseHelper _instance =
      WallpaperDatabaseHelper.internal();
  factory WallpaperDatabaseHelper() => _instance;

  late Database _db;

  WallpaperDatabaseHelper.internal() {
    initDb();
  }

  Future<void> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'wallpaper.db');
    print('>>>>>> its intialiizing');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    print('>>>>>> its intialiized');
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE Wallpaper (
        intId INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT,
        url TEXT
      )
    ''');
  }

  Future<int> insertWallpaper(Wallpaper wallpaper) async {
    var dbClient = await db;
    var insert = await dbClient.insert('Wallpaper', wallpaper.toJson());
    print('the data is inserted on database ');
    print(insert);
    return insert;
  }

  Future<List<Wallpaper>> getWallpapers() async {
    var dbClient = await db;
    List list = await dbClient.query('Wallpaper');
    List<Wallpaper> wallpapers = [];
    for (int i = 0; i < list.length; i++) {
      wallpapers.add(Wallpaper.fromJson(list[i]));
    }
    print('wallpapers is ${wallpapers.toString()}');
    return wallpapers;
  }

  Future<int> deleteWallpaper(String id) async {
    var dbClient = await db;
    return await dbClient.delete('Wallpaper', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    await initDb(); // Ensure _db is initialized
    return _db;
  }
}
