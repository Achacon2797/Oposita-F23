import 'package:flutter/material.dart';
import 'estadisticas_model.dart';
import 'temasdetalles.dart';

class Estadisticas extends StatefulWidget {
  const Estadisticas({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EstadisticasState createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  final estadisticas = EstadisticasModel();

  @override
  void initState() {
    super.initState();
    estadisticas.cargarTemasDesdeJSON().then((_) {
      estadisticas.cargarTemasDesarrolloDesdeJSON().then((_) {
        setState(() {}); // Actualizamos la UI después de cargar los temas
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtra los temas de Test que tienen al menos una realización
    final temasStats = estadisticas
        .obtenerEstadisticasPorTema()
        .entries
        .where((entry) => entry.value['vecesRealizado'] > 0)
        .toList();

    // Filtra los temas de Desarrollo que tienen al menos una realización
    final temasDesarrollo = estadisticas
        .obtenerEstadisticasDesarrollo()
        .entries
        .where((entry) => entry.value['vecesRealizado'] > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(
            color: Colors.black, // Color del texto
            fontFamily: 'Times New Roman', // Fuente de letra Times New Roman
          ),
        ),
        backgroundColor: Colors.white, // Fondo blanco para la AppBar
        iconTheme:
            const IconThemeData(color: Colors.black), // Color de los íconos
        elevation: 0, // Eliminar sombra de la AppBar
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Estadísticas Test',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          Flexible(
            child: temasStats.isEmpty
                ? const Center(
                    child: Text(
                      'No se ha realizado ningún test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: temasStats.length,
                    itemBuilder: (context, index) {
                      final entry = temasStats[index];
                      String temaConNumero = "Tema: ${entry.key}";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemaDetalleScreen(
                                tema: entry.key,
                                data: entry.value,
                                esDesarrollo: false, // Para test
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          color: const Color.fromARGB(255, 217, 227, 251),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              temaConNumero,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 68, 138, 255),
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Estadísticas Temario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          Expanded(
            child: temasDesarrollo.isEmpty
                ? const Center(
                    child: Text(
                      'No se ha realizado ningún temario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: temasDesarrollo.length,
                    itemBuilder: (context, index) {
                      final entry = temasDesarrollo[index];
                      String temaConNumero = "Tema: ${entry.key}";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TemaDetalleScreen(
                                      tema: entry.key,
                                      data: entry.value,
                                      esDesarrollo: true, // Para desarrollo
                                    )),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          color: const Color.fromARGB(255, 217, 227, 251),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              temaConNumero,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 68, 138, 255),
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
