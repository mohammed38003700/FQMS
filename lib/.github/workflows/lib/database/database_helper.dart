
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('fqms.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quality_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        department TEXT NOT NULL,
        product TEXT NOT NULL,
        test_name TEXT NOT NULL,
        result TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE deviations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        corrective_action TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('quality_records', data);
  }

  Future<List<Map<String, dynamic>>> getRecords() async {
    final db = await database;
    return await db.query(
      'quality_records',
      orderBy: 'id DESC',
    );
  }

  Future<int> insertDeviation(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('deviations', data);
  }

  Future<List<Map<String, dynamic>>> getDeviations() async {
    final db = await database;
    return await db.query(
      'deviations',
      orderBy: 'id DESC',
    );
  }
}
