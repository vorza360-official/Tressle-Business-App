import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tressle_business/models/productModel.dart';
import 'package:tressle_business/models/serviceModel.dart';
import 'package:tressle_business/models/service_categoryModel.dart';
import 'package:tressle_business/models/staffModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shop_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE staff(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        designation TEXT NOT NULL,
        workingDays TEXT NOT NULL,
        workingHours TEXT NOT NULL,
        profilePicture TEXT,
        joiningDate TEXT NOT NULL,
        employeeId TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE service_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        duration TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES service_categories (id)
      )
    ''');
  }

  // Staff operations
  Future<int> insertStaff(Staff staff) async {
    final db = await database;
    return await db.insert('staff', staff.toMap());
  }

  Future<List<Staff>> getAllStaff() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('staff');
    return List.generate(maps.length, (i) => Staff.fromMap(maps[i]));
  }

  Future<void> updateStaff(Staff staff) async {
    final db = await database;
    await db.update('staff', staff.toMap(), where: 'id = ?', whereArgs: [staff.id]);
  }

  Future<void> deleteStaff(int id) async {
    final db = await database;
    await db.delete('staff', where: 'id = ?', whereArgs: [id]);
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Service Category operations
  Future<int> insertServiceCategory(ServiceCategory category) async {
    final db = await database;
    return await db.insert('service_categories', category.toMap());
  }

  Future<List<ServiceCategory>> getAllServiceCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('service_categories');
    return List.generate(maps.length, (i) => ServiceCategory.fromMap(maps[i]));
  }

  Future<void> updateServiceCategory(ServiceCategory category) async {
    final db = await database;
    await db.update('service_categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteServiceCategory(int id) async {
    final db = await database;
    await db.delete('service_categories', where: 'id = ?', whereArgs: [id]);
    await db.delete('services', where: 'categoryId = ?', whereArgs: [id]);
  }

  // Service operations
  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<Service>> getServicesByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<List<Service>> getAllServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('services');
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<void> updateService(Service service) async {
    final db = await database;
    await db.update('services', service.toMap(), where: 'id = ?', whereArgs: [service.id]);
  }

  Future<void> deleteService(int id) async {
    final db = await database;
    await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }
}