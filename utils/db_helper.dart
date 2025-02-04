import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Singleton pattern to ensure a single instance of DBHelper
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  // Get the database, initialize it if it doesn't exist
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  // Initialize the database
  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'house_renting.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables when initializing the database
  FutureOr<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        isAdmin INTEGER
      )
    ''');

    // Houses table
    await db.execute('''
      CREATE TABLE houses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT,
        price REAL,
        description TEXT
      )
    ''');

    // Persons table
    await db.execute('''
      CREATE TABLE persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        age INTEGER,
        gender TEXT,
        email TEXT UNIQUE,
        occupation TEXT
      )
    ''');

    // Person-House relationship table
    await db.execute('''
      CREATE TABLE person_house (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personId INTEGER,
        houseId INTEGER,
        FOREIGN KEY(personId) REFERENCES persons(id),
        FOREIGN KEY(houseId) REFERENCES houses(id)
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'abukar',
      'password': 'admin123',
      'isAdmin': 1,
    });
  }

  // CRUD operations for users
  Future<int> insertUser(Map<String, dynamic> user) async {
    var dbClient = await db;
    return await dbClient.insert('users', user);
  }

  Future<List<Map>> getUsers() async {
    var dbClient = await db;
    return await dbClient.query('users');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    var dbClient = await db;
    return await dbClient.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> deleteUser(int id) async {
    var dbClient = await db;
    return await dbClient.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for houses
  Future<int> insertHouse(Map<String, dynamic> house) async {
    var dbClient = await db;
    return await dbClient.insert('houses', house);
  }

  Future<List<Map>> getHouses() async {
    var dbClient = await db;
    return await dbClient.query('houses');
  }

  Future<int> updateHouse(Map<String, dynamic> house) async {
    var dbClient = await db;
    return await dbClient.update('houses', house, where: 'id = ?', whereArgs: [house['id']]);
  }

  Future<int> deleteHouse(int id) async {
    var dbClient = await db;
    return await dbClient.delete('houses', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for persons
  Future<int> insertPerson(Map<String, dynamic> person) async {
    var dbClient = await db;
    return await dbClient.insert('persons', person);
  }

  Future<List<Map>> getPersons() async {
    var dbClient = await db;
    return await dbClient.query('persons');
  }

  Future<int> updatePerson(Map<String, dynamic> person) async {
    var dbClient = await db;
    return await dbClient.update('persons', person, where: 'id = ?', whereArgs: [person['id']]);
  }

  Future<int> deletePerson(int id) async {
    var dbClient = await db;
    return await dbClient.delete('persons', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for person-house relationships
  Future<int> insertPersonHouse(Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient.insert('person_house', data);
  }

  Future<List<Map>> getPersonHouse() async {
    var dbClient = await db;
    return await dbClient.rawQuery('''
      SELECT ph.id, p.name, h.address
      FROM person_house ph
      INNER JOIN persons p ON ph.personId = p.id
      INNER JOIN houses h ON ph.houseId = h.id
    ''');
  }

  Future<int> updatePersonHouse(Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient.update('person_house', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> deletePersonHouse(int id) async {
    var dbClient = await db;
    return await dbClient.delete('person_house', where: 'id = ?', whereArgs: [id]);
  }
}
