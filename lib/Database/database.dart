import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('images.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE images(
      _id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      type TEXT,
      date TEXT,
      image TEXT)''');
  }

  Future<List<Map<String, dynamic>>> queryAllImages() async {
    final db = await instance.database;
    return await db.query('images');
  }

  Future<int> insertImage(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('images', row);
  }

  Future<int> updateImage(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['_id'];
    return await db.update('images', row, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> deleteImage(int id) async {
    final db = await instance.database;
    return await db.delete('images', where: '_id = ?', whereArgs: [id]);
  }
}
