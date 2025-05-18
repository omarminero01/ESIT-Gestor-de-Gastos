import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'home_screen.dart'; // Usamos la clase Gasto

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'gastos.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gastos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descripcion TEXT,
            monto REAL,
            categoria TEXT,
            fecha TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertarGasto(Gasto gasto) async {
    final db = await getDatabase();
    return await db.insert('gastos', gasto.toMap());
  }

  static Future<List<Gasto>> obtenerGastos() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('gastos');
    return List.generate(maps.length, (i) => Gasto.fromMap(maps[i]));
  }

  static Future<int> actualizarGasto(Gasto gasto) async {
    final db = await getDatabase();
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  static Future<int> eliminarGasto(int id) async {
    final db = await getDatabase();
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
