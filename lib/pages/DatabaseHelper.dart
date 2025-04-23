import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path);
  }
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        imagePath TEXT
      )
    ''');
  }

  // Insert a new article
  Future<int> insertArticle(Map<String, dynamic> article) async {
    Database db = await database;
    return await db.insert('articles', article);
  }

  // Get all articles
  Future<List<Map<String, dynamic>>> getArticles() async {
    Database db = await database;
    return await db.query('articles');
  }

  // Update an article
  Future<int> updateArticle(Map<String, dynamic> article) async {
    Database db = await database;
    return await db.update(
      'articles',
      article,
      where: 'id = ?',
      whereArgs: [article['id']],
    );
  }

  // Delete an article
  Future<int> deleteArticle(int id) async {
    Database db = await database;
    return await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}