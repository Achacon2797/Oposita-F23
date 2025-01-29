import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de importar esta biblioteca
import 'package:flutter/material.dart';
// Importar la biblioteca para formatear fechas

class TemaDetalleDesarrolloScreen extends StatelessWidget {
  final String tema;
  final Map<String, dynamic> data;

  const TemaDetalleDesarrolloScreen({
    super.key,
    required this.tema,
    required this.data,
  });

  Future<List<Map<String, dynamic>>> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final fechasKey =
        'fechas_desarrollo_$tema'; // Clave exclusiva para desarrollo
    final vecesKey = 'vecesRealizado_desarrollo_$tema';

    List<String> fechas = prefs.getStringList(fechasKey) ?? [];
    int vecesRealizado = prefs.getInt(vecesKey) ?? 0;

    List<Map<String, dynamic>> historial = [
      {
        'fecha': fechas.isNotEmpty ? fechas.last : 'Sin fecha registrada',
        'vecesRealizado': vecesRealizado,
      }
    ];

    return historial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tema: $tema',
          style: const TextStyle(
            fontFamily: 'Times New Roman',
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarHistorial(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final historial = snapshot.data ?? [];
          return ListView.builder(
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final entry = historial[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: const Color.fromARGB(255, 217, 227, 251),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha: ${entry['fecha']}',
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            color: Color.fromARGB(255, 68, 138, 255),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intentos realizados: ${entry['vecesRealizado']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Times New Roman',
                            color: Color.fromARGB(255, 68, 138, 255),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
