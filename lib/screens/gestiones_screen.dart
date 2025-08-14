// lib/screens/gestiones_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';
import 'grados_secciones_screen.dart';
import 'estudiantes_screen.dart';
import 'global_grados_secciones_screen.dart';

class GestionesScreen extends StatefulWidget {
  const GestionesScreen({super.key});

  @override
  _GestionesScreenState createState() => _GestionesScreenState();
}

class _GestionesScreenState extends State<GestionesScreen> {
  final TextEditingController _colegioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AsistenciaProvider>(context, listen: false).loadColegios();
  }

  @override
  void dispose() {
    _colegioController.dispose();
    super.dispose();
  }

  void _showAddEditColegioDialog(
      BuildContext context, AsistenciaProvider provider,
      {Map<String, dynamic>? colegio}) {
    _colegioController.text =
        colegio != null ? colegio['nombre'] as String : '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          colegio == null ? 'Agregar Colegio' : 'Editar Colegio',
          style: GoogleFonts.poppins(),
        ),
        content: TextField(
          controller: _colegioController,
          decoration: InputDecoration(
            labelText: 'Nombre del Colegio',
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
              if (_colegioController.text.isNotEmpty) {
                if (colegio == null) {
                  provider.addColegio(_colegioController.text);
                } else {
                  provider.renameColegio(
                      colegio['id'] as int, _colegioController.text);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      colegio == null
                          ? 'Colegio agregado'
                          : 'Colegio actualizado',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.teal,
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

  void _showDeleteColegioDialog(BuildContext context,
      AsistenciaProvider provider, Map<String, dynamic> colegio) async {
    final estudianteCount =
        await provider.dbHelper.countEstudiantesByColegio(colegio['id'] as int);
    final asistenciaCount =
        await provider.dbHelper.countAsistenciasByColegio(colegio['id'] as int);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Eliminar Colegio', style: GoogleFonts.poppins()),
        content: Text(
          '¿Estás seguro de eliminar ${colegio['nombre']}? '
          'Esta acción eliminará:\n'
          '- $estudianteCount estudiantes\n'
          '- $asistenciaCount registros de asistencia\n'
          'Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.poppins(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteColegio(colegio['id'] as int);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Colegio eliminado',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: Text('Eliminar',
                style: GoogleFonts.poppins(color: Colors.redAccent)),
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
          'Gestión de Colegios',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle),
              label: const Text('Agregar Colegio'),
              onPressed: () => _showAddEditColegioDialog(context, provider),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ).animate().fadeIn(duration: 300.ms).scale(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Grados y Secciones Globales'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const GlobalGradosSeccionesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.colegios.length,
                itemBuilder: (context, index) {
                  final colegio = provider.colegios[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(colegio['nombre'] as String,
                          style: GoogleFonts.poppins()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () => _showAddEditColegioDialog(
                                context, provider,
                                colegio: colegio),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _showDeleteColegioDialog(
                                context, provider, colegio),
                          ),
                        ],
                      ),
                      onTap: () {
                        provider.loadGrados(colegio['id'] as int);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GradosSeccionesScreen(),
                          ),
                        );
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (200 + index * 50).ms)
                      .slideY(begin: 0.2, end: 0);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('Gestión de Estudiantes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EstudiantesScreen()),
                );
              },
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
