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
    final path = join(await getDatabasesPath(), 'burjo_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE menu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insertMenu(Menu menu) async {
    final database = await db;
    return await database.insert(
      'menu', 
      menu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getMenus() async {
    final database = await db;
    return await database.query('menu', orderBy: 'id DESC');
  }

  static Future<int> updateMenu(Menu menu) async {
    final database = await db;
    return await database.update(
      'menu',
      menu.toMap(),
      where: 'id = ?',
      whereArgs: [menu.id],
    );
  }

  static Future<int> deleteMenu(int id) async {
    final database = await db;
    return await database.delete(
      'menu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}