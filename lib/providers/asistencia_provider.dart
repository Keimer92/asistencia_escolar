// lib/providers/asistencia_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/database_helper.dart';

class AsistenciaProvider with ChangeNotifier {
  List<Map<String, dynamic>> colegios = [];
  List<Map<String, dynamic>> grados = [];
  List<Map<String, dynamic>> secciones = [];
  List<Map<String, dynamic>> estudiantes = [];
  List<Map<String, dynamic>> globalGrados = [];
  List<Map<String, dynamic>> globalSecciones = [];
  int? selectedColegioId;
  int? selectedGradoId;
  int? selectedSeccionId;
  String selectedFecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String searchQuery = '';
  String? selectedSexoFilter;
  Map<String, int> estudiantesStats = {
    'Masculino': 0,
    'Femenino': 0,
    'Otro': 0,
    'No especificado': 0,
  };
  Map<int, String> estudiantesAsistencias = {};

  final dbHelper = DatabaseHelper.instance;

  Future<void> loadColegios() async {
    colegios = await dbHelper.getColegios();
    notifyListeners();
  }

  Future<void> loadGrados(int colegioId) async {
    selectedColegioId = colegioId;
    grados = await dbHelper.getGrados(colegioId);
    selectedGradoId = grados.isNotEmpty ? grados.first['id'] as int : null;
    secciones = [];
    selectedSeccionId = null;
    estudiantes = [];
    estudiantesStats = {
      'Masculino': 0,
      'Femenino': 0,
      'Otro': 0,
      'No especificado': 0,
    };
    estudiantesAsistencias = {};
    if (selectedGradoId != null) {
      await loadSecciones(selectedGradoId!);
    }
    notifyListeners();
  }

  Future<void> loadSecciones(int gradoId) async {
    selectedGradoId = gradoId;
    secciones = await dbHelper.getSecciones(gradoId);
    selectedSeccionId = null;
    estudiantes = [];
    estudiantesStats = {
      'Masculino': 0,
      'Femenino': 0,
      'Otro': 0,
      'No especificado': 0,
    };
    estudiantesAsistencias = {};
    notifyListeners();
  }

  Future<void> loadEstudiantes(int seccionId, String query,
      {String? sexo}) async {
    selectedSeccionId = seccionId;
    searchQuery = query;
    selectedSexoFilter = sexo;
    estudiantes = await dbHelper.getEstudiantes(seccionId, query, sexo);
    estudiantesStats = await dbHelper.getEstudiantesStatsBySexo(seccionId);
    estudiantesAsistencias = {
      for (var estudiante in estudiantes)
        estudiante['id'] as int:
            estudiante['tipo_asistencia']?.toString() ?? 'P'
    };
    notifyListeners();
  }

  Future<void> loadGlobalGrados() async {
    globalGrados = await dbHelper.getGlobalGrados();
    notifyListeners();
  }

  Future<void> loadGlobalSecciones() async {
    globalSecciones = await dbHelper.getGlobalSecciones();
    notifyListeners();
  }

  Future<void> updateColegioGradosAndSecciones(int colegioId,
      List<String> selectedGrados, List<String> selectedSecciones) async {
    await dbHelper.updateColegioGradosAndSecciones(
        colegioId, selectedGrados, selectedSecciones);
    await loadGrados(colegioId);
    notifyListeners();
  }

  Future<void> renameGlobalGrado(int id, String newNombre) async {
    final formattedNombre =
        RegExp(r'^\d+$').hasMatch(newNombre) ? '$newNombreº' : newNombre;
    await dbHelper.renameGlobalGrado(id, formattedNombre);
    await loadGlobalGrados();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }

  Future<void> renameGlobalSeccion(int id, String newNombre) async {
    await dbHelper.renameGlobalSeccion(id, newNombre);
    await loadGlobalSecciones();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }

  void updateFecha(DateTime fecha) {
    selectedFecha = DateFormat('yyyy-MM-dd').format(fecha);
    if (selectedSeccionId != null) {
      loadEstudiantes(selectedSeccionId!, searchQuery,
          sexo: selectedSexoFilter);
    }
    notifyListeners();
  }

  void updateAsistencia(int estudianteId, String tipoAsistencia) {
    estudiantesAsistencias[estudianteId] = tipoAsistencia;
    notifyListeners();
  }

  Future<void> guardarAsistencia() async {
    if (selectedSeccionId == null) return;
    for (var estudiante in estudiantes) {
      final tipoAsistencia = estudiantesAsistencias[estudiante['id']] ?? 'P';
      await dbHelper.insertAsistencia(
          estudiante['id'] as int, selectedFecha, tipoAsistencia);
    }
    estudiantesAsistencias.clear();
    await loadEstudiantes(selectedSeccionId!, searchQuery,
        sexo: selectedSexoFilter);
    notifyListeners();
  }

  Future<void> addColegio(String nombre) async {
    await dbHelper.insertColegio(nombre);
    await loadColegios();
  }

  Future<void> renameColegio(int id, String nombre) async {
    await dbHelper.updateColegio(id, nombre);
    await loadColegios();
  }

  Future<void> deleteColegio(int id) async {
    await dbHelper.deleteColegio(id);
    await loadColegios();
    if (selectedColegioId == id) {
      selectedColegioId = null;
      grados = [];
      selectedGradoId = null;
      secciones = [];
      selectedSeccionId = null;
      estudiantes = [];
      estudiantesStats = {
        'Masculino': 0,
        'Femenino': 0,
        'Otro': 0,
        'No especificado': 0,
      };
      estudiantesAsistencias = {};
      notifyListeners();
    }
  }

  Future<void> addGrado(String nombre, int colegioId) async {
    final formattedNombre =
        RegExp(r'^\d+$').hasMatch(nombre) ? '$nombreº' : nombre;
    await dbHelper.insertGrado(formattedNombre, colegioId);
    if (selectedColegioId == colegioId) {
      await loadGrados(colegioId);
    }
  }

  Future<void> renameGrado(int id, String nombre) async {
    final formattedNombre =
        RegExp(r'^\d+$').hasMatch(nombre) ? '$nombreº' : nombre;
    await dbHelper.updateGrado(id, formattedNombre);
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
    }
  }

  Future<void> deleteGrado(int id, int colegioId) async {
    await dbHelper.deleteGrado(id);
    if (selectedColegioId == colegioId) {
      await loadGrados(colegioId);
      if (selectedGradoId == id) {
        selectedGradoId = null;
        secciones = [];
        selectedSeccionId = null;
        estudiantes = [];
        estudiantesStats = {
          'Masculino': 0,
          'Femenino': 0,
          'Otro': 0,
          'No especificado': 0,
        };
        estudiantesAsistencias = {};
        notifyListeners();
      }
    }
  }

  Future<void> addSeccion(String nombre, int gradoId) async {
    await dbHelper.insertSeccion(nombre, gradoId);
    if (selectedGradoId == gradoId) {
      await loadSecciones(gradoId);
    }
  }

  Future<void> renameSeccion(int id, String nombre) async {
    await dbHelper.updateSeccion(id, nombre);
    if (selectedGradoId != null) {
      await loadSecciones(selectedGradoId!);
    }
  }

  Future<void> deleteSeccion(int id, int gradoId) async {
    await dbHelper.deleteSeccion(id);
    if (selectedGradoId == gradoId) {
      await loadSecciones(gradoId);
      if (selectedSeccionId == id) {
        selectedSeccionId = null;
        estudiantes = [];
        estudiantesStats = {
          'Masculino': 0,
          'Femenino': 0,
          'Otro': 0,
          'No especificado': 0,
        };
        estudiantesAsistencias = {};
        notifyListeners();
      }
    }
  }

  Future<void> addEstudiante(String nombre, int seccionId, String sexo) async {
    await dbHelper.insertEstudiante(nombre, seccionId, sexo);
    if (selectedSeccionId == seccionId) {
      await loadEstudiantes(seccionId, searchQuery, sexo: selectedSexoFilter);
    }
  }

  Future<void> renameEstudiante(int id, String nombre, String sexo) async {
    if (selectedSeccionId == null) return;
    await dbHelper.updateEstudiante(id, nombre, selectedSeccionId!, sexo);
    await loadEstudiantes(selectedSeccionId!, searchQuery,
        sexo: selectedSexoFilter);
  }

  Future<void> updateEstudianteSeccion(
      int id, int newSeccionId, String sexo) async {
    if (estudiantes.isEmpty) return;
    final estudiante = estudiantes.firstWhere(
      (e) => e['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    if (estudiante.isEmpty) return;
    await dbHelper.updateEstudiante(
        id, estudiante['nombre'] as String, newSeccionId, sexo);
    if (selectedSeccionId != null) {
      await loadEstudiantes(selectedSeccionId!, searchQuery,
          sexo: selectedSexoFilter);
    }
  }

  Future<void> deleteEstudiante(int id, int seccionId) async {
    await dbHelper.deleteEstudiante(id);
    if (selectedSeccionId == seccionId) {
      await loadEstudiantes(seccionId, searchQuery, sexo: selectedSexoFilter);
    }
  }

  Future<void> addGlobalGrado(String nombre) async {
    final formattedNombre =
        RegExp(r'^\d+$').hasMatch(nombre) ? '$nombreº' : nombre;
    await dbHelper.insertGlobalGrado(formattedNombre);
    await loadGlobalGrados();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }

  Future<void> deleteGlobalGrado(int id, String nombre) async {
    await dbHelper.deleteGlobalGrado(id, nombre);
    await loadGlobalGrados();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }

  Future<void> addGlobalSeccion(String nombre) async {
    await dbHelper.insertGlobalSeccion(nombre);
    await loadGlobalSecciones();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }

  Future<void> deleteGlobalSeccion(int id, String nombre) async {
    await dbHelper.deleteGlobalSeccion(id, nombre);
    await loadGlobalSecciones();
    await loadColegios();
    if (selectedColegioId != null) {
      await loadGrados(selectedColegioId!);
      if (selectedGradoId != null) {
        await loadSecciones(selectedGradoId!);
        if (selectedSeccionId != null) {
          await loadEstudiantes(selectedSeccionId!, searchQuery,
              sexo: selectedSexoFilter);
        }
      }
    }
  }
}
