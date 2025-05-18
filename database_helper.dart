import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'home_screen.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB('gastos.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final path = join(await getDatabasesPath(), fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        categoria TEXT,
        monto REAL,
        fecha TEXT
      )
    ''');
  }

  Future<int> insertGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  Future<List<Gasto>> getGastos() async {
    final db = await database;
    final result = await db.query('gastos', orderBy: 'fecha DESC');
    return result.map((e) => Gasto.fromMap(e)).toList();
  }

  Future<int> updateGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> deleteGasto(int id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
