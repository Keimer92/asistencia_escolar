// lib/screens/global_grados_secciones_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';

class GlobalGradosSeccionesScreen extends StatefulWidget {
  const GlobalGradosSeccionesScreen({super.key});

  @override
  _GlobalGradosSeccionesScreenState createState() =>
      _GlobalGradosSeccionesScreenState();
}

class _GlobalGradosSeccionesScreenState
    extends State<GlobalGradosSeccionesScreen> {
  final TextEditingController _gradoController = TextEditingController();
  final TextEditingController _seccionController = TextEditingController();
  final FocusNode _gradoFocusNode = FocusNode();
  final FocusNode _seccionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Cargar grados y secciones globales al iniciar la pantalla
    final provider = Provider.of<AsistenciaProvider>(context, listen: false);
    provider.loadGlobalGrados();
    provider.loadGlobalSecciones();
  }

  @override
  void dispose() {
    _gradoController.dispose();
    _seccionController.dispose();
    _gradoFocusNode.dispose();
    _seccionFocusNode.dispose();
    super.dispose();
  }

  void _showRenameDialog(
      BuildContext context, String type, int id, String currentNombre) {
    final controller = TextEditingController(text: currentNombre);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Renombrar $type', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              if (controller.text.isNotEmpty) {
                final provider =
                    Provider.of<AsistenciaProvider>(context, listen: false);
                if (type == 'Grado') {
                  provider.renameGlobalGrado(id, controller.text);
                } else {
                  provider.renameGlobalSeccion(id, controller.text);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$type renombrado',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Por favor, ingrese un nombre válido',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child:
                Text('Guardar', style: GoogleFonts.poppins(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AsistenciaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión Global de Grados y Secciones',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Grados Globales',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gradoController,
                      focusNode: _gradoFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del grado (ej. 1, 1º, 1º Nivel)',
                        prefixIcon: Icon(Icons.class_, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTap: () {
                        _gradoFocusNode.requestFocus();
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          provider.addGlobalGrado(value);
                          _gradoController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Grado global agregado',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Agregar'),
                    onPressed: () {
                      if (_gradoController.text.isNotEmpty) {
                        provider.addGlobalGrado(_gradoController.text);
                        _gradoController.clear();
                        _gradoFocusNode.unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Grado global agregado',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor, ingrese un nombre para el grado',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms).scale(),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.globalGrados.length,
                itemBuilder: (context, index) {
                  final grado = provider.globalGrados[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(grado['nombre'] as String,
                          style: GoogleFonts.poppins()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () {
                              _showRenameDialog(
                                  context,
                                  'Grado',
                                  grado['id'] as int,
                                  grado['nombre'] as String);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text('Eliminar Grado Global',
                                      style: GoogleFonts.poppins()),
                                  content: Text(
                                    '¿Estás seguro de eliminar este grado? Esto lo eliminará de todos los colegios, incluyendo secciones, estudiantes y asistencias asociadas.',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar',
                                          style: GoogleFonts.poppins(
                                              color: Colors.teal)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteGlobalGrado(
                                            grado['id'] as int,
                                            grado['nombre'] as String);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Grado global eliminado',
                                              style: GoogleFonts.poppins(),
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
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (300 + index * 50).ms)
                      .slideY(begin: 0.2, end: 0);
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Gestión de Secciones Globales',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _seccionController,
                      focusNode: _seccionFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la sección (ej. C)',
                        prefixIcon: Icon(Icons.group, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTap: () {
                        _seccionFocusNode.requestFocus();
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          provider.addGlobalSeccion(value);
                          _seccionController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sección global agregada',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Agregar'),
                    onPressed: () {
                      if (_seccionController.text.isNotEmpty) {
                        provider.addGlobalSeccion(_seccionController.text);
                        _seccionController.clear();
                        _seccionFocusNode.unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sección global agregada',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor, ingrese un nombre para la sección',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms).scale(),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.globalSecciones.length,
                itemBuilder: (context, index) {
                  final seccion = provider.globalSecciones[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(seccion['nombre'] as String,
                          style: GoogleFonts.poppins()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () {
                              _showRenameDialog(
                                  context,
                                  'Sección',
                                  seccion['id'] as int,
                                  seccion['nombre'] as String);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text('Eliminar Sección Global',
                                      style: GoogleFonts.poppins()),
                                  content: Text(
                                    '¿Estás seguro de eliminar esta sección? Esto la eliminará de todos los grados de todos los colegios, incluyendo estudiantes y asistencias asociadas.',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar',
                                          style: GoogleFonts.poppins(
                                              color: Colors.teal)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteGlobalSeccion(
                                            seccion['id'] as int,
                                            seccion['nombre'] as String);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Sección global eliminada',
                                              style: GoogleFonts.poppins(),
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
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (700 + index * 50).ms)
                      .slideY(begin: 0.2, end: 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
