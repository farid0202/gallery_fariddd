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

  // Ubah versi database menjadi 2
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  // Fungsi untuk membuat database baru
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const blobType = 'BLOB';
    const intType = 'INTEGER';

    // Membuat tabel images dengan kolom is_favorite
    await db.execute(''' 
    CREATE TABLE images ( 
      id $idType, 
      image $blobType, 
      date $textType,
      is_favorite $intType DEFAULT 0
    )''');
  }

  // Fungsi untuk menangani pembaruan skema jika versi database lebih tinggi
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Jika versi sebelumnya < 2, tambahkan kolom is_favorite
      await db.execute('''
        ALTER TABLE images ADD COLUMN is_favorite INTEGER DEFAULT 0;
      ''');
    }
  }

  // Fungsi untuk menyisipkan gambar ke dalam database
  Future<int> insertImage(File imageFile, DateTime date, {bool isFavorite = false}) async {
    final db = await instance.database;
    final imageBytes = await imageFile.readAsBytes();
    final dateString = date.toIso8601String();

    return await db.insert('images', {
      'image': imageBytes,
      'date': dateString,
      'is_favorite': isFavorite ? 1 : 0,
    });
  }

  // Fungsi untuk menghapus gambar berdasarkan ID
  Future<int> deleteImage(int id) async {
    final db = await instance.database;
    return await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fungsi untuk mengambil semua gambar
  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await instance.database;
    return await db.query('images');
  }

  // Fungsi untuk mengambil gambar favorit (is_favorite = 1)
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.query(
      'images',
      where: 'is_favorite = ?',
      whereArgs: [1], // Mengambil gambar dengan is_favorite = 1
    );
  }

  // Fungsi untuk mengambil gambar berdasarkan ID
  Future<Map<String, dynamic>?> getImageById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Fungsi untuk memperbarui status gambar sebagai favorit
  Future<int> updateFavoriteStatus(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'images',
      {'is_favorite': isFavorite ? 1 : 0}, // Menandai gambar sebagai favorit
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}