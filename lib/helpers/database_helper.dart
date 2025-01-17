import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gallery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const blobType = 'BLOB';
    await db.execute(''' 
    CREATE TABLE images ( 
      id $idType, 
      image $blobType, 
      date $textType
    )''');
  }

  Future<int> insertImage(File imageFile, DateTime date) async {
    final db = await instance.database;
    final imageBytes = await imageFile.readAsBytes();
    final dateString = date.toIso8601String();

    return await db.insert('images', {
      'image': imageBytes,
      'date': dateString,
    });
  }

  // DatabaseHelper.dart

Future<int> deleteImage(int id) async {
  final db = await instance.database;
  return await db.delete(
    'images',
    where: 'id = ?',
    whereArgs: [id],
  );
}


  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await instance.database;
    return await db.query('images');
  }
}
