import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Locat {
  final int? id;
  final double latitude;
  final double longitude;

  Locat({this.id, required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static Locat fromMap(Map<String, dynamic> map) {
    return Locat(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;

  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('locations.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
  }

  Future<int> insertLocation(Locat location) async {
    final db = await instance.database;
    return await db.insert('locations', location.toMap());
  }

  Future<List<Locat>> getLocations() async {
    final db = await instance.database;
    final result = await db.query('locations');
    return result.map((map) => Locat.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
