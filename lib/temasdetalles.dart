import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de importar esta biblioteca
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar la biblioteca para formatear fechas

class TemaDetalleScreen extends StatelessWidget {
  final String tema;
  final Map<String, dynamic> data;
  final bool esDesarrollo; // Añadido para diferenciar test y desarrollo

  const TemaDetalleScreen({
    super.key,
    required this.tema,
    required this.data,
    this.esDesarrollo =
        false, // Valor predeterminado para evitar errores en otras llamadas
  });

  Future<List<Map<String, dynamic>>> _cargarHistorial(
      {bool esDesarrollo = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Claves dinámicas según el tipo de datos
    final fechasKey = esDesarrollo ? 'desarrollo_fechas_$tema' : 'fechas_$tema';
    final vecesKey = esDesarrollo
        ? 'desarrollo_vecesRealizado_$tema'
        : 'vecesRealizado_$tema';

    // Obtener fechas y veces realizadas
    List<String> fechas = prefs.getStringList(fechasKey) ?? [];
    int vecesRealizado = prefs.getInt(vecesKey) ?? 0;

    // Si es un tema de desarrollo, no hay datos de correctas/incorrectas
    if (esDesarrollo) {
      List<Map<String, dynamic>> historial = [];
      for (int i = 0; i < fechas.length; i++) {
        historial.add({
          'fecha': fechas[i],
          'vecesRealizado': i + 1,
        });
      }
      return historial;
    }

    // Si es test, cargar datos adicionales (correctas/incorrectas)
    final correctasKey = 'correctas_$tema';
    final incorrectasKey = 'incorrectas_$tema';

    List<int> correctas =
        prefs.getStringList(correctasKey)?.map(int.parse).toList() ?? [];
    List<int> incorrectas =
        prefs.getStringList(incorrectasKey)?.map(int.parse).toList() ?? [];

    List<Map<String, dynamic>> historial = [];
    for (int i = 0; i < fechas.length; i++) {
      historial.add({
        'fecha': fechas[i],
        'vecesRealizado': i + 1,
        'correctas': correctas.length > i ? correctas[i] : 0,
        'incorrectas': incorrectas.length > i ? incorrectas[i] : 0,
      });
    }
    return historial;
  }

  @override
  Widget build(BuildContext context) {
    const customColor = Color.fromARGB(255, 68, 138, 255);
    const cardBackgroundColor =
        Color.fromARGB(255, 217, 227, 251); // Color para el fondo del card

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
        future: _cargarHistorial(
            esDesarrollo: esDesarrollo), // Pasar el valor de la propiedad
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final historial = snapshot.data ?? [];

          return ListView.builder(
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final entry = historial[index];

              // Formatear la fecha
              final fecha = DateTime.parse(entry['fecha']);
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(fecha);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: cardBackgroundColor, // Fondo personalizado
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha: $formattedDate', // Mostrar fecha formateada
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            color: customColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Veces realizado: ${entry['vecesRealizado']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Times New Roman',
                            color: customColor,
                          ),
                        ),
                        if (entry.containsKey('correctas') &&
                            entry.containsKey('incorrectas')) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Correctas: ${entry['correctas']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'Incorrectas: ${entry['incorrectas']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                            ],
                          ),
                        ],
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
