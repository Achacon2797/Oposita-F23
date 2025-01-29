import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'estadisticas_model.dart';

class PreguntasDesarrollo extends StatefulWidget {
  final String nombre;

  const PreguntasDesarrollo({super.key, required this.nombre});

  @override
  // ignore: library_private_types_in_public_api
  _PreguntasDesarrolloState createState() => _PreguntasDesarrolloState();
}

Future<void> guardarTemaTerminado(String tema, bool valor) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tema_$tema', valor);
}

class _PreguntasDesarrolloState extends State<PreguntasDesarrollo> {
  bool temaTerminado = false;
  List<dynamic> preguntas = [];
  int preguntaActual = 0;
  bool mostrarRespuesta = false;
  List<int> puntuacionesPreguntas = [];

  @override
  void initState() {
    super.initState();
    guardarEstadoTema(
        widget.nombre, true, false); // Marcamos el tema como iniciado
    _cargarPreguntas();
  }

  Future<void> _cargarPreguntas() async {
    final String response =
        await rootBundle.loadString('assets/preguntas_desarrollo.json');
    final data = json.decode(response);

    setState(() {
      preguntas = data['temas'].firstWhere((tema) =>
          tema['tema'] == widget.nombre.replaceAll('Tema ', ''))['preguntas'];
      puntuacionesPreguntas = List.filled(preguntas.length, 0);
    });

    await _cargarPuntuaciones();
    await _recuperarUltimaPregunta();
  }

  Future<void> _cargarPuntuaciones() async {
    final prefs = await SharedPreferences.getInstance();
    String temaPuntuacionesKey = '${widget.nombre}_puntuaciones';
    List<String>? puntuacionesGuardadas =
        prefs.getStringList(temaPuntuacionesKey);

    setState(() {
      puntuacionesPreguntas =
          (puntuacionesGuardadas ?? []).map(int.parse).toList();
    });
  }

  Future<void> _guardarPuntuacionPregunta(int puntuacion) async {
    final prefs = await SharedPreferences.getInstance();
    String temaPuntuacionesKey = '${widget.nombre}_puntuaciones';

    puntuacionesPreguntas[preguntaActual] = puntuacion;
    await prefs.setStringList(
      temaPuntuacionesKey,
      puntuacionesPreguntas.map((p) => p.toString()).toList(),
    );
  }

  Future<void> _recuperarUltimaPregunta() async {
    final prefs = await SharedPreferences.getInstance();
    String temaPreguntaKey = '${widget.nombre}_ultima_pregunta';
    int ultimaPregunta = prefs.getInt(temaPreguntaKey) ?? 0;

    setState(() {
      preguntaActual = ultimaPregunta;
    });
  }

  Future<void> _guardarUltimaPregunta() async {
    final prefs = await SharedPreferences.getInstance();
    String temaPreguntaKey = '${widget.nombre}_ultima_pregunta';
    await prefs.setInt(temaPreguntaKey, preguntaActual);
  }

  void _siguientePregunta() {
    if (puntuacionesPreguntas[preguntaActual] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Debes calificar esta pregunta antes de continuar!"),
        ),
      );
      return;
    }

    setState(() {
      preguntaActual++;
      mostrarRespuesta = false;
    });

    _guardarUltimaPregunta();
  }

  void _mostrarDialogoFinalizado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tema Finalizado"),
          content: const Text("¿Qué te gustaría hacer?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _reiniciarTema();
              },
              child: const Text("Reiniciar Tema"),
            ),
            TextButton(
              onPressed: () async {
                // Marca el tema como terminado
                await guardarEstadoTema(widget.nombre, true, true);

                // Registra la finalización en EstadisticasModel
                EstadisticasModel()
                    .incrementarRealizadoDesarrollo(widget.nombre);

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                _volverAlTemario();
              },
              child: const Text("Volver al Menú"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reiniciarTema() async {
    final prefs = await SharedPreferences.getInstance();
    String temaPuntuacionesKey = '${widget.nombre}_puntuaciones';

    // Elimina las puntuaciones guardadas para el tema actual
    await prefs.remove(temaPuntuacionesKey);
    await prefs.remove('${widget.nombre}_ultima_pregunta');

    // Establece el tema como no iniciado y no finalizado en SharedPreferences
    await guardarEstadoTema(widget.nombre, false, false);

    setState(() {
      preguntaActual = 0;
      puntuacionesPreguntas = List.filled(preguntas.length, 0);
    });

    // Regresa a la pantalla principal después de reiniciar el estado del tema
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _volverAlTemario() {
    _guardarUltimaPregunta();
    Navigator.pop(context);
  }

  bool _esUltimaPreguntaCalificada() {
    return puntuacionesPreguntas[preguntas.length - 1] > 0;
  }

  @override
  Widget build(BuildContext context) {
    if (preguntas.isEmpty) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56.0), // Altura personalizada
          child: AppBar(
            automaticallyImplyLeading: false, // Eliminar el icono de regreso
            title: Align(
              alignment: Alignment.center,
              child: Text('Tema ${widget.nombre.replaceAll("Tema ", "")}'),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (preguntaActual >= preguntas.length) {
      _mostrarDialogoFinalizado();
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56.0), // Altura personalizada
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Align(
              alignment: Alignment.center,
              child: Text('Tema ${widget.nombre.replaceAll("Tema ", "")}'),
            ),
          ),
        ),
        body: const Center(child: Text("¡Has terminado todas las preguntas!")),
      );
    }

    final pregunta = preguntas[preguntaActual];
    bool esPreguntaCalificada = puntuacionesPreguntas[preguntaActual] > 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text('Tema ${widget.nombre.replaceAll("Tema ", "")}'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            // Usamos Center aquí para alinear todo el contenido
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Se asegura que no ocupe más espacio del necesario
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centramos horizontalmente
              children: [
                Text(
                  "Pregunta ${preguntaActual + 1}: ${pregunta['pregunta']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centramos el texto
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mostrarRespuesta = !mostrarRespuesta;
                    });
                  },
                  child: Text(
                      mostrarRespuesta ? "Ocultar Respuesta" : "Ver Respuesta"),
                ),
                if (mostrarRespuesta) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Respuesta: ${pregunta['respuesta']}",
                    style:
                        const TextStyle(fontSize: 16, color: Colors.blueAccent),
                    textAlign: TextAlign.center, // Centramos el texto
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Selecciona un nivel de dificultad:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < puntuacionesPreguntas[preguntaActual]
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            puntuacionesPreguntas[preguntaActual] = index + 1;
                          });
                          _guardarPuntuacionPregunta(
                              puntuacionesPreguntas[preguntaActual]);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: esPreguntaCalificada
                      ? () {
                          if (preguntaActual == preguntas.length - 1) {
                            if (!_esUltimaPreguntaCalificada()) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    "¡Debes calificar la última pregunta antes de finalizar!"),
                              ));
                              return;
                            }
                            _mostrarDialogoFinalizado();
                          } else {
                            _siguientePregunta();
                          }
                        }
                      : null,
                  child: Text(preguntaActual == preguntas.length - 1
                      ? "Finalizar"
                      : "Siguiente Pregunta"),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pregunta ${preguntaActual + 1} de ${preguntas.length}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

Future<void> guardarEstadoTema(
    String tema, bool iniciado, bool finalizado) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tema_iniciado_$tema', iniciado);
  await prefs.setBool('tema_finalizado_$tema', finalizado);
}

Future<Map<String, bool>> obtenerEstadoTema(String tema) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool iniciado = prefs.getBool('tema_iniciado_$tema') ?? false;
  bool finalizado = prefs.getBool('tema_finalizado_$tema') ?? false;
  return {'iniciado': iniciado, 'finalizado': finalizado};
}
