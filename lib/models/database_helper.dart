// lib/models/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('asistencia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE colegios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE global_grados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE global_secciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE grados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        colegio_id INTEGER,
        FOREIGN KEY (colegio_id) REFERENCES colegios(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE secciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        grado_id INTEGER,
        FOREIGN KEY (grado_id) REFERENCES grados(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE estudiantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        seccion_id INTEGER,
        sexo TEXT,
        FOREIGN KEY (seccion_id) REFERENCES secciones(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE asistencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudiante_id INTEGER,
        fecha TEXT NOT NULL,
        tipo_asistencia TEXT NOT NULL,
        FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id)
      )
    ''');

    // Datos de ejemplo para grados y secciones globales
    for (int i = 1; i <= 6; i++) {
      await db.insert('global_grados', {'nombre': '$iº'});
    }
    await db.insert('global_secciones', {'nombre': 'A'});
    await db.insert('global_secciones', {'nombre': 'B'});

    // Datos de ejemplo para colegios
    await _insertColegioWithGradosAndSecciones(db, 'Colegio San Juan');
    await _insertColegioWithGradosAndSecciones(db, 'Colegio Santa María');
    // Estudiantes de ejemplo
    await db.insert('estudiantes',
        {'nombre': 'Juan Pérez', 'seccion_id': 1, 'sexo': 'Masculino'});
    await db.insert('estudiantes',
        {'nombre': 'María López', 'seccion_id': 1, 'sexo': 'Femenino'});
    await db.insert('estudiantes',
        {'nombre': 'Ana Gómez', 'seccion_id': 2, 'sexo': 'Femenino'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE asistencias_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          estudiante_id INTEGER,
          fecha TEXT NOT NULL,
          tipo_asistencia TEXT NOT NULL,
          FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id)
        )
      ''');
      await db.execute('''
        INSERT INTO asistencias_new (id, estudiante_id, fecha, tipo_asistencia)
        SELECT id, estudiante_id, fecha, CASE asistio WHEN 1 THEN 'P' ELSE 'A' END
        FROM asistencias
      ''');
      await db.execute('DROP TABLE asistencias');
      await db.execute('ALTER TABLE asistencias_new RENAME TO asistencias');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE estudiantes ADD COLUMN sexo TEXT');
    }
  }

  Future<void> _insertColegioWithGradosAndSecciones(
      Database db, String nombre) async {
    final colegioId = await db.insert('colegios', {'nombre': nombre});
    final globalGrados = await db.query('global_grados');
    final globalSecciones = await db.query('global_secciones');
    for (var grado in globalGrados) {
      final gradoId = await db.insert('grados', {
        'nombre': grado['nombre'] as String,
        'colegio_id': colegioId,
      });
      for (var seccion in globalSecciones) {
        await db.insert('secciones', {
          'nombre': seccion['nombre'] as String,
          'grado_id': gradoId,
        });
      }
    }
  }

  Future<void> insertColegio(String nombre) async {
    final db = await database;
    await _insertColegioWithGradosAndSecciones(db, nombre);
  }

  Future<List<Map<String, dynamic>>> getColegios() async {
    final db = await database;
    return await db.query('colegios');
  }

  Future<List<Map<String, dynamic>>> getGrados(int colegioId) async {
    final db = await database;
    return await db
        .query('grados', where: 'colegio_id = ?', whereArgs: [colegioId]);
  }

  Future<List<Map<String, dynamic>>> getSecciones(int gradoId) async {
    final db = await database;
    return await db
        .query('secciones', where: 'grado_id = ?', whereArgs: [gradoId]);
  }

  Future<List<Map<String, dynamic>>> getEstudiantes(
      int seccionId, String query, String? sexo) async {
    final db = await database;
    String whereClause = 'seccion_id = ? AND nombre LIKE ?';
    List<dynamic> whereArgs = [seccionId, '%$query%'];
    if (sexo != null && sexo != 'Todos') {
      whereClause += ' AND sexo = ?';
      whereArgs.add(sexo);
    }
    return await db.query('estudiantes',
        where: whereClause, whereArgs: whereArgs);
  }

  Future<Map<String, int>> getEstudiantesStatsBySexo(int seccionId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT sexo, COUNT(*) as count
      FROM estudiantes
      WHERE seccion_id = ?
      GROUP BY sexo
    ''', [seccionId]);
    Map<String, int> stats = {
      'Masculino': 0,
      'Femenino': 0,
      'Otro': 0,
      'No especificado': 0,
    };
    for (var row in result) {
      final sexo = row['sexo']?.toString() ?? 'No especificado';
      final count = row['count'] as int;
      stats[sexo] = count;
    }
    return stats;
  }

  Future<List<Map<String, dynamic>>> getGlobalGrados() async {
    final db = await database;
    return await db.query('global_grados');
  }

  Future<List<Map<String, dynamic>>> getGlobalSecciones() async {
    final db = await database;
    return await db.query('global_secciones');
  }

  Future<int> countEstudiantesByColegio(int colegioId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM estudiantes
      WHERE seccion_id IN (
        SELECT id FROM secciones
        WHERE grado_id IN (
          SELECT id FROM grados
          WHERE colegio_id = ?
        )
      )
    ''', [colegioId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countAsistenciasByColegio(int colegioId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM asistencias
      WHERE estudiante_id IN (
        SELECT id FROM estudiantes
        WHERE seccion_id IN (
          SELECT id FROM secciones
          WHERE grado_id IN (
            SELECT id FROM grados
            WHERE colegio_id = ?
          )
        )
      )
    ''', [colegioId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertGlobalGrado(String nombre) async {
    final db = await database;
    await db.insert('global_grados', {'nombre': nombre});
    final colegios = await getColegios();
    for (var colegio in colegios) {
      final gradoId = await db.insert('grados', {
        'nombre': nombre,
        'colegio_id': colegio['id'],
      });
      final globalSecciones = await getGlobalSecciones();
      for (var seccion in globalSecciones) {
        await db.insert('secciones', {
          'nombre': seccion['nombre'] as String,
          'grado_id': gradoId,
        });
      }
    }
  }

  Future<void> insertGlobalSeccion(String nombre) async {
    final db = await database;
    await db.insert('global_secciones', {'nombre': nombre});
    final colegios = await getColegios();
    for (var colegio in colegios) {
      final grados = await getGrados(colegio['id'] as int);
      for (var grado in grados) {
        await db.insert('secciones', {
          'nombre': nombre,
          'grado_id': grado['id'],
        });
      }
    }
  }

  Future<void> renameGlobalGrado(int id, String newNombre) async {
    final db = await database;
    final currentGrado =
        await db.query('global_grados', where: 'id = ?', whereArgs: [id]);
    if (currentGrado.isEmpty) return;
    final oldNombre = currentGrado[0]['nombre'] as String;
    await db.update('global_grados', {'nombre': newNombre},
        where: 'id = ?', whereArgs: [id]);
    final colegios = await getColegios();
    for (var colegio in colegios) {
      await db.update(
        'grados',
        {'nombre': newNombre},
        where: 'colegio_id = ? AND nombre = ?',
        whereArgs: [colegio['id'], oldNombre],
      );
    }
  }

  Future<void> renameGlobalSeccion(int id, String newNombre) async {
    final db = await database;
    final currentSeccion =
        await db.query('global_secciones', where: 'id = ?', whereArgs: [id]);
    if (currentSeccion.isEmpty) return;
    final oldNombre = currentSeccion[0]['nombre'] as String;
    await db.update('global_secciones', {'nombre': newNombre},
        where: 'id = ?', whereArgs: [id]);
    final colegios = await getColegios();
    for (var colegio in colegios) {
      final grados = await getGrados(colegio['id'] as int);
      for (var grado in grados) {
        await db.update(
          'secciones',
          {'nombre': newNombre},
          where: 'grado_id = ? AND nombre = ?',
          whereArgs: [grado['id'], oldNombre],
        );
      }
    }
  }

  Future<void> deleteGlobalGrado(int id, String nombre) async {
    final db = await database;
    await db.delete('global_grados', where: 'id = ?', whereArgs: [id]);
    final colegios = await getColegios();
    for (var colegio in colegios) {
      final grados = await db.query('grados',
          where: 'colegio_id = ? AND nombre = ?',
          whereArgs: [colegio['id'], nombre]);
      for (var grado in grados) {
        await db.delete('grados', where: 'id = ?', whereArgs: [grado['id']]);
        await db.delete('secciones',
            where: 'grado_id = ?', whereArgs: [grado['id']]);
        await db.delete('estudiantes',
            where:
                'seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?)',
            whereArgs: [grado['id']]);
        await db.delete('asistencias',
            where:
                'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?))',
            whereArgs: [grado['id']]);
      }
    }
  }

  Future<void> deleteGlobalSeccion(int id, String nombre) async {
    final db = await database;
    await db.delete('global_secciones', where: 'id = ?', whereArgs: [id]);
    final colegios = await getColegios();
    for (var colegio in colegios) {
      final grados = await getGrados(colegio['id'] as int);
      for (var grado in grados) {
        final secciones = await db.query('secciones',
            where: 'grado_id = ? AND nombre = ?',
            whereArgs: [grado['id'], nombre]);
        for (var seccion in secciones) {
          await db
              .delete('secciones', where: 'id = ?', whereArgs: [seccion['id']]);
          await db.delete('estudiantes',
              where: 'seccion_id = ?', whereArgs: [seccion['id']]);
          await db.delete('asistencias',
              where:
                  'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id = ?)',
              whereArgs: [seccion['id']]);
        }
      }
    }
  }

  Future<void> updateColegioGradosAndSecciones(int colegioId,
      List<String> selectedGrados, List<String> selectedSecciones) async {
    final db = await database;
    final grados = await getGrados(colegioId);
    for (var grado in grados) {
      await db
          .delete('secciones', where: 'grado_id = ?', whereArgs: [grado['id']]);
      await db.delete('grados', where: 'id = ?', whereArgs: [grado['id']]);
      await db.delete('estudiantes',
          where: 'seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?)',
          whereArgs: [grado['id']]);
      await db.delete('asistencias',
          where:
              'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?))',
          whereArgs: [grado['id']]);
    }
    for (var gradoNombre in selectedGrados) {
      final gradoId = await db.insert('grados', {
        'nombre': gradoNombre,
        'colegio_id': colegioId,
      });
      for (var seccionNombre in selectedSecciones) {
        await db.insert('secciones', {
          'nombre': seccionNombre,
          'grado_id': gradoId,
        });
      }
    }
  }

  Future<void> insertAsistencia(
      int estudianteId, String fecha, String tipoAsistencia) async {
    final db = await database;
    await db.delete('asistencias',
        where: 'estudiante_id = ? AND fecha = ?',
        whereArgs: [estudianteId, fecha]);
    await db.insert('asistencias', {
      'estudiante_id': estudianteId,
      'fecha': fecha,
      'tipo_asistencia': tipoAsistencia,
    });
  }

  Future<List<Map<String, dynamic>>> getAsistencias(
      int seccionId, String fecha) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT e.id, e.nombre, e.sexo, a.tipo_asistencia
      FROM estudiantes e
      LEFT JOIN asistencias a ON e.id = a.estudiante_id AND a.fecha = ?
      WHERE e.seccion_id = ?
    ''', [fecha, seccionId]);
  }

  Future<void> updateColegio(int id, String nombre) async {
    final db = await database;
    await db.update(
      'colegios',
      {'nombre': nombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteColegio(int id) async {
    final db = await database;
    await db.delete('colegios', where: 'id = ?', whereArgs: [id]);
    await db.delete('grados', where: 'colegio_id = ?', whereArgs: [id]);
    await db.delete('secciones',
        where: 'grado_id IN (SELECT id FROM grados WHERE colegio_id = ?)',
        whereArgs: [id]);
    await db.delete('estudiantes',
        where:
            'seccion_id IN (SELECT id FROM secciones WHERE grado_id IN (SELECT id FROM grados WHERE colegio_id = ?))',
        whereArgs: [id]);
    await db.delete('asistencias',
        where:
            'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id IN (SELECT id FROM secciones WHERE grado_id IN (SELECT id FROM grados WHERE colegio_id = ?)))',
        whereArgs: [id]);
  }

  Future<void> insertGrado(String nombre, int colegioId) async {
    final db = await database;
    final gradoId =
        await db.insert('grados', {'nombre': nombre, 'colegio_id': colegioId});
    final globalSecciones = await getGlobalSecciones();
    for (var seccion in globalSecciones) {
      await db.insert('secciones', {
        'nombre': seccion['nombre'] as String,
        'grado_id': gradoId,
      });
    }
  }

  Future<void> updateGrado(int id, String nombre) async {
    final db = await database;
    await db.update(
      'grados',
      {'nombre': nombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteGrado(int id) async {
    final db = await database;
    await db.delete('grados', where: 'id = ?', whereArgs: [id]);
    await db.delete('secciones', where: 'grado_id = ?', whereArgs: [id]);
    await db.delete('estudiantes',
        where: 'seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?)',
        whereArgs: [id]);
    await db.delete('asistencias',
        where:
            'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id IN (SELECT id FROM secciones WHERE grado_id = ?))',
        whereArgs: [id]);
  }

  Future<void> insertSeccion(String nombre, int gradoId) async {
    final db = await database;
    await db.insert('secciones', {'nombre': nombre, 'grado_id': gradoId});
  }

  Future<void> updateSeccion(int id, String nombre) async {
    final db = await database;
    await db.update(
      'secciones',
      {'nombre': nombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSeccion(int id) async {
    final db = await database;
    await db.delete('secciones', where: 'id = ?', whereArgs: [id]);
    await db.delete('estudiantes', where: 'seccion_id = ?', whereArgs: [id]);
    await db.delete('asistencias',
        where:
            'estudiante_id IN (SELECT id FROM estudiantes WHERE seccion_id = ?)',
        whereArgs: [id]);
  }

  Future<void> insertEstudiante(
      String nombre, int seccionId, String sexo) async {
    final db = await database;
    await db.insert('estudiantes', {
      'nombre': nombre,
      'seccion_id': seccionId,
      'sexo': sexo,
    });
  }

  Future<void> updateEstudiante(
      int id, String nombre, int seccionId, String sexo) async {
    final db = await database;
    await db.update(
      'estudiantes',
      {
        'nombre': nombre,
        'seccion_id': seccionId,
        'sexo': sexo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEstudiante(int id) async {
    final db = await database;
    await db.delete('estudiantes', where: 'id = ?', whereArgs: [id]);
    await db.delete('asistencias', where: 'estudiante_id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
