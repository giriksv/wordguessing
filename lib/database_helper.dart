import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'word_guessing.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bymode (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT,
        level INTEGER,
        points INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE byindex (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        index_level INTEGER,
        points INTEGER
      )
    ''');
  }

  Future<void> insertOrUpdateByMode(String mode, int level, int points) async {
    final db = await database;

    var result = await db.rawQuery('''
      SELECT * FROM bymode WHERE mode = ? AND level = ?
    ''', [mode, level]);

    if (result.isNotEmpty) {
      int currentPoints = (result[0]['points'] as int?) ?? 0;
      await db.update(
        'bymode',
        {'points': currentPoints + points},
        where: 'mode = ? AND level = ?',
        whereArgs: [mode, level],
      );
    } else {
      await db.insert('bymode', {
        'mode': mode,
        'level': level,
        'points': points,
      });
    }
  }

  Future<void> insertOrUpdateByIndex(int indexLevel, int points) async {
    final db = await database;

    var result = await db.rawQuery('''
      SELECT * FROM byindex WHERE index_level = ?
    ''', [indexLevel]);

    if (result.isNotEmpty) {
      int currentPoints = (result[0]['points'] as int?) ?? 0;
      await db.update(
        'byindex',
        {'points': currentPoints + points},
        where: 'index_level = ?',
        whereArgs: [indexLevel],
      );
    } else {
      await db.insert('byindex', {
        'index_level': indexLevel,
        'points': points,
      });
    }
  }

  Future<Map<String, int>> getTotalPoints() async {
    final db = await database;

    var byModeResult = await db.rawQuery('SELECT SUM(points) as total FROM bymode');
    var byIndexResult = await db.rawQuery('SELECT SUM(points) as total FROM byindex');

    int byModeTotal = byModeResult[0]['total'] as int? ?? 0;
    int byIndexTotal = byIndexResult[0]['total'] as int? ?? 0;

    return {
      'total': byModeTotal + byIndexTotal,
      'byModeTotal': byModeTotal,
      'byIndexTotal': byIndexTotal,
    };
  }

  Future<Map<String, int>> getPointsByMode() async {
    final db = await database;

    var easyResult = await db.rawQuery('SELECT SUM(points) as total FROM bymode WHERE mode = "easy"');
    var mediumResult = await db.rawQuery('SELECT SUM(points) as total FROM bymode WHERE mode = "medium"');
    var hardResult = await db.rawQuery('SELECT SUM(points) as total FROM bymode WHERE mode = "hard"');
    var fiveResult = await db.rawQuery('SELECT SUM(points) as total FROM byindex WHERE index_level = 5');
    var sixResult = await db.rawQuery('SELECT SUM(points) as total FROM byindex WHERE index_level = 6');
    var sevenResult = await db.rawQuery('SELECT SUM(points) as total FROM byindex WHERE index_level = 7');

    return {
      'easy': easyResult[0]['total'] as int? ?? 0,
      'medium': mediumResult[0]['total'] as int? ?? 0,
      'hard': hardResult[0]['total'] as int? ?? 0,
      'five': fiveResult[0]['total'] as int? ?? 0,
      'six': sixResult[0]['total'] as int? ?? 0,
      'seven': sevenResult[0]['total'] as int? ?? 0,
    };
  }
}
