import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'vehicle_gallery.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        license_plate TEXT NOT NULL UNIQUE,
        vin TEXT,
        mileage INTEGER,
        price REAL,
        status TEXT NOT NULL DEFAULT 'available',
        media_files TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final sampleVehicles = [
      {
        'make': 'Toyota',
        'model': 'Camry',
        'year': 2020,
        'license_plate': 'ABC-1234',
        'vin': '1HGBH41JXMN109186',
        'mileage': 45000,
        'price': 25000.0,
        'status': 'available',
        'media_files': 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=800,https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
        'created_at': now,
        'updated_at': now,
      },
      {
        'make': 'Honda',
        'model': 'Civic',
        'year': 2019,
        'license_plate': 'XYZ-5678',
        'vin': '2HGFC2F59JH542143',
        'mileage': 32000,
        'price': 22000.0,
        'status': 'available',
        'media_files': 'https://images.unsplash.com/photo-1606664515493-398d4d5a6a69?w=800,https://images.unsplash.com/photo-1619976420038-a2c793259d36?w=800',
        'created_at': now,
        'updated_at': now,
      },
      {
        'make': 'BMW',
        'model': 'X5',
        'year': 2021,
        'license_plate': 'BMW-9999',
        'vin': '5UXCR6C0XG091234',
        'mileage': 18000,
        'price': 65000.0,
        'status': 'in-use',
        'media_files': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800,https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=800',
        'created_at': now,
        'updated_at': now,
      },
      {
        'make': 'Tesla',
        'model': 'Model 3',
        'year': 2022,
        'license_plate': 'TSL-2022',
        'vin': '5YJ3E1EA2JF123456',
        'mileage': 12000,
        'price': 50000.0,
        'status': 'available',
        'media_files': 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800,https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800',
        'created_at': now,
        'updated_at': now,
      },
      {
        'make': 'Ford',
        'model': 'F-150',
        'year': 2020,
        'license_plate': 'FRD-1500',
        'vin': '1FTFW1ET5LFC12345',
        'mileage': 55000,
        'price': 35000.0,
        'status': 'maintenance',
        'media_files': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800,https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (var vehicle in sampleVehicles) {
      await db.insert('vehicles', vehicle);
    }
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  Future<Vehicle?> getVehicle(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'make LIKE ? OR model LIKE ? OR license_plate LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  Future<List<Vehicle>> filterVehiclesByMake(String make) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'make = ?',
      whereArgs: [make],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  Future<List<Vehicle>> filterVehiclesByYear(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'year = ?',
      whereArgs: [year],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getDistinctMakes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT make FROM vehicles ORDER BY make',
    );

    return maps.map((map) => map['make'] as String).toList();
  }

  Future<List<int>> getDistinctYears() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT year FROM vehicles ORDER BY year DESC',
    );

    return maps.map((map) => map['year'] as int).toList();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}