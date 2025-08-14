// lib/screens/grados_secciones_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';

class GradosSeccionesScreen extends StatefulWidget {
  const GradosSeccionesScreen({super.key});

  @override
  _GradosSeccionesScreenState createState() => _GradosSeccionesScreenState();
}

class _GradosSeccionesScreenState extends State<GradosSeccionesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AsistenciaProvider>(context, listen: false);
    provider.loadColegios();
    provider.loadGlobalGrados();
    provider.loadGlobalSecciones();
  }

  void _showEditDialog(
      BuildContext context, AsistenciaProvider provider, int colegioId) {
    final selectedGrados =
        List<String>.from(provider.grados.map((g) => g['nombre'] as String));
    final selectedSecciones =
        List<String>.from(provider.secciones.map((s) => s['nombre'] as String));
    final allGrados =
        provider.globalGrados.map((g) => g['nombre'] as String).toList();
    final allSecciones =
        provider.globalSecciones.map((s) => s['nombre'] as String).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Editar Grados y Secciones',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grados',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: allGrados.map((grado) {
                    return ChoiceChip(
                      label: Text(grado, style: GoogleFonts.poppins()),
                      selected: selectedGrados.contains(grado),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedGrados.add(grado);
                          } else {
                            selectedGrados.remove(grado);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGrados.clear();
                          selectedGrados.addAll(allGrados);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Seleccionar todo',
                          style: GoogleFonts.poppins()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGrados.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Deseleccionar todo',
                          style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Secciones',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: allSecciones.map((seccion) {
                    return ChoiceChip(
                      label: Text(seccion, style: GoogleFonts.poppins()),
                      selected: selectedSecciones.contains(seccion),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSecciones.add(seccion);
                          } else {
                            selectedSecciones.remove(seccion);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSecciones.clear();
                          selectedSecciones.addAll(allSecciones);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Seleccionar todo',
                          style: GoogleFonts.poppins()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSecciones.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Deseleccionar todo',
                          style: GoogleFonts.poppins()),
                    ),
                  ],
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
                provider.updateColegioGradosAndSecciones(
                    colegioId, selectedGrados, selectedSecciones);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Grados y secciones actualizados',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
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
          'Grados y Secciones por Colegio',
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
              onChanged: (value) {
                if (value != null) {
                  provider.loadGrados(value);
                }
              },
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Expanded(
              child: provider.selectedColegioId == null
                  ? Center(
                      child: Text(
                        'Seleccione un colegio para ver los grados y secciones',
                        style: GoogleFonts.poppins(),
                      ),
                    )
                  : ListView(
                      children: [
                        Text(
                          'Grados',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        ...provider.grados.map((grado) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              title: Text(grado['nombre'] as String,
                                  style: GoogleFonts.poppins()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.teal),
                                    onPressed: () {
                                      final controller = TextEditingController(
                                          text: grado['nombre'] as String);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: Text('Editar Grado',
                                              style: GoogleFonts.poppins()),
                                          content: TextField(
                                            controller: controller,
                                            decoration: InputDecoration(
                                              labelText: 'Nombre del Grado',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
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
                                                if (controller
                                                    .text.isNotEmpty) {
                                                  provider.renameGrado(
                                                      grado['id'] as int,
                                                      controller.text);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Grado actualizado',
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                      backgroundColor:
                                                          Colors.teal,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text('Guardar',
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.teal)),
                                            ),
                                          ],
                                        ),
                                      );
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: Text('Eliminar Grado',
                                              style: GoogleFonts.poppins()),
                                          content: Text(
                                            '¿Estás seguro de eliminar el grado ${grado['nombre']}? Esto también eliminará sus secciones, estudiantes y asistencias.',
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
                                                provider.deleteGrado(
                                                    grado['id'] as int,
                                                    provider
                                                        .selectedColegioId!);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Grado eliminado',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor:
                                                        Colors.teal,
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
                              onExpansionChanged: (expanded) {
                                if (expanded) {
                                  provider.loadSecciones(grado['id'] as int);
                                }
                              },
                              children: provider.secciones
                                  .where((seccion) =>
                                      seccion['grado_id'] == grado['id'])
                                  .map((seccion) {
                                return ListTile(
                                  title: Text(seccion['nombre'] as String,
                                      style: GoogleFonts.poppins()),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.teal),
                                        onPressed: () {
                                          final controller =
                                              TextEditingController(
                                                  text: seccion['nombre']
                                                      as String);
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              title: Text('Editar Sección',
                                                  style: GoogleFonts.poppins()),
                                              content: TextField(
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Nombre de la Sección',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancelar',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.teal)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (controller
                                                        .text.isNotEmpty) {
                                                      provider.renameSeccion(
                                                          seccion['id'] as int,
                                                          controller.text);
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Sección actualizada',
                                                            style: GoogleFonts
                                                                .poppins(),
                                                          ),
                                                          backgroundColor:
                                                              Colors.teal,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text('Guardar',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.teal)),
                                                ),
                                              ],
                                            ),
                                          );
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              title: Text('Eliminar Sección',
                                                  style: GoogleFonts.poppins()),
                                              content: Text(
                                                '¿Estás seguro de eliminar la sección ${seccion['nombre']}? Esto también eliminará los estudiantes y asistencias asociados.',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancelar',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.teal)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    provider.deleteSeccion(
                                                        seccion['id'] as int,
                                                        grado['id'] as int);
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Sección eliminada',
                                                          style: GoogleFonts
                                                              .poppins(),
                                                        ),
                                                        backgroundColor:
                                                            Colors.teal,
                                                      ),
                                                    );
                                                  },
                                                  child: Text('Eliminar',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: Colors
                                                                  .redAccent)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0);
                        }).toList(),
                        const SizedBox(height: 16),
                        Text(
                          'Acciones',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Grados y Secciones'),
                          onPressed: provider.selectedColegioId != null
                              ? () => _showEditDialog(context, provider,
                                  provider.selectedColegioId!)
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 200.ms)
                            .scale(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Agregar Grado'),
                          onPressed: provider.selectedColegioId != null
                              ? () {
                                  final controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Text('Agregar Grado',
                                          style: GoogleFonts.poppins()),
                                      content: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Nombre del Grado',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
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
                                            if (controller.text.isNotEmpty) {
                                              provider.addGrado(controller.text,
                                                  provider.selectedColegioId!);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Grado agregado',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                  backgroundColor: Colors.teal,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Guardar',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.teal)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 300.ms)
                            .scale(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Agregar Sección'),
                          onPressed: provider.selectedGradoId != null
                              ? () {
                                  final controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Text('Agregar Sección',
                                          style: GoogleFonts.poppins()),
                                      content: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Nombre de la Sección',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
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
                                            if (controller.text.isNotEmpty) {
                                              provider.addSeccion(
                                                  controller.text,
                                                  provider.selectedGradoId!);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Sección agregada',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                  backgroundColor: Colors.teal,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Guardar',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.teal)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 400.ms)
                            .scale(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
