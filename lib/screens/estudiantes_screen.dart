// lib/screens/estudiantes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';

class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  _EstudiantesScreenState createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  String? _selectedSexo;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AsistenciaProvider>(context, listen: false);
    provider.loadColegios();
    _searchController.addListener(() {
      if (provider.selectedSeccionId != null) {
        provider.loadEstudiantes(
          provider.selectedSeccionId!,
          _searchController.text,
          sexo: provider.selectedSexoFilter,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  void _showAddEditEstudianteDialog(
      BuildContext context, AsistenciaProvider provider,
      {Map<String, dynamic>? estudiante}) {
    _nombreController.text =
        estudiante != null ? estudiante['nombre'] as String : '';
    _selectedSexo = estudiante != null ? estudiante['sexo'] as String? : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            estudiante == null ? 'Agregar Estudiante' : 'Renombrar Estudiante',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Estudiante',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedSexo,
                  items: ['Masculino', 'Femenino', 'Otro'].map((sexo) {
                    return DropdownMenuItem<String>(
                      value: sexo,
                      child: Text(sexo, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSexo = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                if (_nombreController.text.isNotEmpty &&
                    _selectedSexo != null &&
                    provider.selectedSeccionId != null) {
                  if (estudiante == null) {
                    provider.addEstudiante(_nombreController.text,
                        provider.selectedSeccionId!, _selectedSexo!);
                  } else {
                    provider.renameEstudiante(estudiante['id'] as int,
                        _nombreController.text, _selectedSexo!);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        estudiante == null
                            ? 'Estudiante agregado'
                            : 'Estudiante actualizado',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor, complete todos los campos y seleccione una sección',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('Guardar',
                  style: GoogleFonts.poppins(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEstudianteDetailsDialog(BuildContext context,
      AsistenciaProvider provider, Map<String, dynamic> estudiante) {
    int? selectedColegioId = provider.selectedColegioId;
    int? selectedGradoId = provider.selectedGradoId;
    int? selectedSeccionId = estudiante['seccion_id'] as int;
    String? selectedSexo = estudiante['sexo'] as String?;

    Future<void> loadGradosAndSecciones() async {
      if (selectedColegioId != null) {
        await provider.loadGrados(selectedColegioId!);
        if (provider.grados.isNotEmpty) {
          selectedGradoId = provider.grados.first['id'] as int;
          await provider.loadSecciones(selectedGradoId!);
          if (provider.secciones.isNotEmpty) {
            selectedSeccionId = provider.secciones.first['id'] as int;
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Cambiar Detalles de ${estudiante['nombre']}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Colegio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedColegioId,
                  items: provider.colegios.map((colegio) {
                    return DropdownMenuItem<int>(
                      value: colegio['id'] as int,
                      child: Text(colegio['nombre'] as String,
                          style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        selectedColegioId = value;
                        selectedGradoId = null;
                        selectedSeccionId = null;
                      });
                      await provider.loadGrados(value);
                      if (provider.grados.isNotEmpty) {
                        setState(() {
                          selectedGradoId = provider.grados.first['id'] as int;
                        });
                        await provider.loadSecciones(selectedGradoId!);
                        if (provider.secciones.isNotEmpty) {
                          setState(() {
                            selectedSeccionId =
                                provider.secciones.first['id'] as int;
                          });
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Grado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedGradoId,
                  items: provider.grados.map((grado) {
                    return DropdownMenuItem<int>(
                      value: grado['id'] as int,
                      child: Text(grado['nombre'] as String,
                          style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        selectedGradoId = value;
                        selectedSeccionId = null;
                      });
                      await provider.loadSecciones(value);
                      if (provider.secciones.isNotEmpty) {
                        setState(() {
                          selectedSeccionId =
                              provider.secciones.first['id'] as int;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Sección',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedSeccionId,
                  items: provider.secciones.map((seccion) {
                    return DropdownMenuItem<int>(
                      value: seccion['id'] as int,
                      child: Text(seccion['nombre'] as String,
                          style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSeccionId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedSexo,
                  items: ['Masculino', 'Femenino', 'Otro'].map((sexo) {
                    return DropdownMenuItem<String>(
                      value: sexo,
                      child: Text(sexo, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSexo = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                if (selectedSeccionId != null && selectedSexo != null) {
                  provider.updateEstudianteSeccion(estudiante['id'] as int,
                      selectedSeccionId!, selectedSexo!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Detalles del estudiante actualizados',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor, seleccione una sección y sexo',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('Guardar',
                  style: GoogleFonts.poppins(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AsistenciaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Estudiantes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Colegio',
                prefixIcon: Icon(Icons.school, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              value: provider.selectedColegioId,
              items: provider.colegios.map((colegio) {
                return DropdownMenuItem<int>(
                  value: colegio['id'] as int,
                  child: Text(colegio['nombre'] as String,
                      style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  await provider.loadGrados(value);
                }
              },
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Grado',
                prefixIcon: Icon(Icons.grade, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              value: provider.selectedGradoId,
              items: provider.grados.map((grado) {
                return DropdownMenuItem<int>(
                  value: grado['id'] as int,
                  child: Text(grado['nombre'] as String,
                      style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  await provider.loadSecciones(value);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Sección',
                prefixIcon: Icon(Icons.class_, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              value: provider.selectedSeccionId,
              items: provider.secciones.map((seccion) {
                return DropdownMenuItem<int>(
                  value: seccion['id'] as int,
                  child: Text(seccion['nombre'] as String,
                      style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.loadEstudiantes(value, _searchController.text,
                      sexo: provider.selectedSexoFilter);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filtrar por Sexo',
                prefixIcon: Icon(Icons.filter_alt, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              value: provider.selectedSexoFilter,
              items: ['Todos', 'Masculino', 'Femenino', 'Otro'].map((sexo) {
                return DropdownMenuItem<String>(
                  value: sexo == 'Todos' ? null : sexo,
                  child: Text(sexo, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                if (provider.selectedSeccionId != null) {
                  provider.loadEstudiantes(
                      provider.selectedSeccionId!, _searchController.text,
                      sexo: value);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 250.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Estudiante',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            if (provider.selectedSeccionId != null)
              Text(
                'Estadísticas: ${provider.estudiantesStats['Masculino']} Masculino, '
                '${provider.estudiantesStats['Femenino']} Femenino, '
                '${provider.estudiantesStats['Otro']} Otro, '
                '${provider.estudiantesStats['No especificado']} No especificado',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontStyle: FontStyle.italic),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 350.ms)
                  .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Expanded(
              child: provider.selectedSeccionId == null
                  ? Center(
                      child: Text(
                        'Seleccione una sección para ver los estudiantes',
                        style: GoogleFonts.poppins(),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.estudiantes.length,
                      itemBuilder: (context, index) {
                        final estudiante = provider.estudiantes[index];
                        final sexo =
                            estudiante['sexo']?.toString() ?? 'No especificado';
                        final iconColor = sexo == 'Masculino'
                            ? Colors.blue
                            : sexo == 'Femenino'
                                ? Colors.pink
                                : Colors.grey;
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person, color: iconColor),
                            title: Text(estudiante['nombre'] as String,
                                style: GoogleFonts.poppins()),
                            subtitle: Text(
                              'Sexo: $sexo',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.teal),
                                  onPressed: () => _showAddEditEstudianteDialog(
                                      context, provider,
                                      estudiante: estudiante),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        title: Text('Eliminar Estudiante',
                                            style: GoogleFonts.poppins()),
                                        content: Text(
                                          '¿Estás seguro de eliminar a ${estudiante['nombre']}? Esto también eliminará sus registros de asistencia.',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancelar',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.teal)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              provider.deleteEstudiante(
                                                  estudiante['id'] as int,
                                                  provider.selectedSeccionId!);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Estudiante eliminado',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                  backgroundColor: Colors.teal,
                                                ),
                                              );
                                            },
                                            child: Text('Eliminar',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.redAccent)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () => _showChangeEstudianteDetailsDialog(
                                context, provider, estudiante),
                          ),
                        )
                            .animate()
                            .fadeIn(
                                duration: 300.ms, delay: (200 + index * 50).ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle),
              label: const Text('Agregar Estudiante'),
              onPressed: provider.selectedSeccionId != null
                  ? () => _showAddEditEstudianteDialog(context, provider)
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 400.ms).scale(),
          ],
        ),
      ),
    );
  }
}
