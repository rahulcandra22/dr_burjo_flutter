import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/menu.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'burjo_pro.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE menu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER,
            description TEXT,  -- KOLOM BARU
            imagePath TEXT     -- KOLOM BARU
          )
        ''');
      },
    );
  }

  static Future<void> insertMenu(Menu menu) async {
    try {
      final database = await db;
      await database.insert(
        'menu',
        menu.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("Error Insert: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getMenus() async {
    try {
      final database = await db;
      return await database.query('menu', orderBy: 'id DESC');
    } catch (e) {
      debugPrint("Error Get Data: $e");
      return [];
    }
  }

  static Future<void> updateMenu(Menu menu) async {
    try {
      final database = await db;
      await database.update(
        'menu',
        menu.toMap(),
        where: 'id = ?',
        whereArgs: [menu.id],
      );
    } catch (e) {
      debugPrint("Error Update: $e");
    }
  }

  static Future<void> deleteMenu(int id) async {
    try {
      final database = await db;
      await database.delete(
        'menu',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
  }
}