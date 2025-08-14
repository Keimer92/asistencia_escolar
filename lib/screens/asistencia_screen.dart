// lib/screens/asistencia_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/asistencia_provider.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  _AsistenciaScreenState createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AsistenciaProvider>(context, listen: false);
    provider.loadColegios();
    _searchController.addListener(() {
      if (provider.selectedSeccionId != null) {
        provider.loadEstudiantes(
            provider.selectedSeccionId!, _searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AsistenciaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toma de Asistencia',
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
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Grado',
                prefixIcon: Icon(Icons.class_, color: Colors.teal),
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
              onChanged: (value) {
                if (value != null) {
                  provider.loadSecciones(value);
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
                prefixIcon: Icon(Icons.group, color: Colors.teal),
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
                  provider.loadEstudiantes(value, _searchController.text);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar Estudiante',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha: ${provider.selectedFecha}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.teal),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      provider.updateFecha(selectedDate);
                    }
                  },
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.estudiantes.length,
                itemBuilder: (context, index) {
                  final estudiante = provider.estudiantes[index];
                  final tipoAsistencia =
                      provider.estudiantesAsistencias[estudiante['id']] ?? 'P';
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            estudiante['nombre'] as String,
                            style: GoogleFonts.poppins(
                              color: tipoAsistencia == 'P'
                                  ? Colors.green
                                  : tipoAsistencia == 'A'
                                      ? Colors.redAccent
                                      : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${tipoAsistencia == 'P' ? 'Presente' : tipoAsistencia == 'A' ? 'Ausente' : 'Justificado'})',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'P',
                            label: Text('P'),
                            icon: Icon(Icons.check_circle, color: Colors.green),
                          ),
                          ButtonSegment(
                            value: 'A',
                            label: Text('A'),
                            icon: Icon(Icons.cancel, color: Colors.redAccent),
                          ),
                          ButtonSegment(
                            value: 'J',
                            label: Text('J'),
                            icon: Icon(Icons.info, color: Colors.orange),
                          ),
                        ],
                        selected: {tipoAsistencia},
                        onSelectionChanged: (newSelection) {
                          provider.updateAsistencia(
                              estudiante['id'] as int, newSelection.first);
                        },
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (500 + index * 50).ms)
                      .slideY(begin: 0.2, end: 0);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar Asistencia'),
              onPressed: provider.estudiantes.isNotEmpty
                  ? () {
                      provider.guardarAsistencia().then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Asistencia guardada',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 700.ms).scale(),
          ],
        ),
      ),
    );
  }
}
