import 'dart:convert'; // Necesario para trabajar con json
import 'package:flutter/services.dart'; // Necesario para usar rootBundle
import 'package:shared_preferences/shared_preferences.dart';

class EstadisticasModel {
  static final EstadisticasModel _instance = EstadisticasModel._internal();

  int correctas = 0;
  int incorrectas = 0;
  Duration tiempoTotal = Duration.zero;

  // Estadísticas por tema
  Map<String, Map<String, dynamic>> temas = {};
  Map<String, Map<String, dynamic>> temasDesarrollo = {};

  factory EstadisticasModel() {
    return _instance;
  }

  EstadisticasModel._internal();

  Future<void> cargarTemasDesdeJSON() async {
    final String response =
        await rootBundle.loadString('assets/preguntas_test.json');
    final data = json.decode(response);

    for (int i = 0; i < data['temas'].length; i++) {
      var tema = data['temas'][i];
      String temaTitulo = tema['titulo'];

      temas[temaTitulo] ??= {
        'numero': i + 1,
        'vecesRealizado': 0,
        'correctas': 0,
        'incorrectas': 0,
        'ultimoDia': 'No disponible',
        'fechas': [],
        'respuestasCorrectas': [],
        'respuestasIncorrectas': [],
      };
    }
  }

  Future<void> cargarTemasDesarrolloDesdeJSON() async {
    final String response =
        await rootBundle.loadString('assets/preguntas_desarrollo.json');
    final data = json.decode(response);
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < data['temas'].length; i++) {
      var tema = data['temas'][i];
      String temaTitulo = tema['titulo'];

      // Cargar datos persistidos
      List<String> fechas = prefs.getStringList('fechas_$temaTitulo') ?? [];
      int vecesRealizado = prefs.getInt('vecesRealizado_$temaTitulo') ?? 0;

      temasDesarrollo[temaTitulo] ??= {
        'numero': i + 1,
        'vecesRealizado': vecesRealizado,
        'ultimoDia':
            fechas.isNotEmpty ? fechas.last.substring(0, 10) : 'No disponible',
        'fechas': fechas,
      };
    }
  }

  void incrementarCorrectas(String tema) {
    correctas++;
    _actualizarTema(tema, esCorrecta: true);
  }

  void incrementarIncorrectas(String tema) {
    incorrectas++;
    _actualizarTema(tema, esCorrecta: false);
  }

  void _actualizarTema(String tema, {required bool esCorrecta}) {
    if (!temas.containsKey(tema)) {
      temas[tema] = {
        'numero': temas.length + 1,
        'vecesRealizado': 0,
        'correctas': 0,
        'incorrectas': 0,
        'ultimoDia': 'No disponible',
        'fechas': [],
        'respuestasCorrectas': [],
        'respuestasIncorrectas': [],
      };
    }

    temas[tema]!['vecesRealizado'] += 1;
    temas[tema]!['correctas'] += esCorrecta ? 1 : 0;
    temas[tema]!['incorrectas'] += esCorrecta ? 0 : 1;
    temas[tema]!['ultimoDia'] = DateTime.now().toString().substring(0, 10);

    temas[tema]!['fechas']?.add(DateTime.now().toString().substring(0, 10));
    temas[tema]!['respuestasCorrectas']?.add(esCorrecta ? 1 : 0);
    temas[tema]!['respuestasIncorrectas']?.add(esCorrecta ? 0 : 1);
  }

  void incrementarRealizadoDesarrollo(String tema) {
    if (!temasDesarrollo.containsKey(tema)) {
      temasDesarrollo[tema] = {
        'numero': temasDesarrollo.length + 1,
        'vecesRealizado': 0,
        'ultimoDia': 'No disponible',
        'fechas': [],
      };
    }

    temasDesarrollo[tema]!['vecesRealizado'] += 1;
    temasDesarrollo[tema]!['ultimoDia'] =
        DateTime.now().toString().substring(0, 10);
    temasDesarrollo[tema]!['fechas']?.add(DateTime.now().toString());

    // Guardar persistencia
    guardarRealizacionDesarrollo(tema);
  }

  Future<void> guardarRealizacionDesarrollo(String tema) async {
    final prefs = await SharedPreferences.getInstance();

       // Claves únicas para desarrollo
    final fechasKey = 'desarrollo_fechas_$tema'; // Cambiar la clave
    final vecesKey = 'desarrollo_vecesRealizado_$tema'; // Cambiar la clave

    // Obtener y actualizar fechas
    List<String> fechas = prefs.getStringList(fechasKey) ?? [];
    fechas.add(DateTime.now().toString()); // Guarda la fecha y hora actual

    // Guardar los datos actualizados
    await prefs.setStringList(fechasKey, fechas);
    await prefs.setInt(
        vecesKey, fechas.length); // Actualiza las veces realizadas
  }

  Map<String, Map<String, dynamic>> obtenerEstadisticasPorTema() {
    return temas;
  }

  Map<String, Map<String, dynamic>> obtenerEstadisticasDesarrollo() {
    return temasDesarrollo;
  }
}
