import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import 'estadisticas_model.dart';
import 'dart:async';
import 'tema_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Widget para mostrar el tiempo
class TimerWidget extends StatelessWidget {
  final Duration duration;

  const TimerWidget({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Tiempo: $minutes:$seconds',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

// ignore: camel_case_types
class Preguntas_Test extends StatefulWidget {
  final String nombre;
  final Map<String, TemaStats> temaProgress;

  const Preguntas_Test(
      {super.key, required this.nombre, required this.temaProgress});

  @override
  // ignore: library_private_types_in_public_api
  _PreguntasTestState createState() => _PreguntasTestState();
}

class _PreguntasTestState extends State<Preguntas_Test> {
  int? _respuestaSeleccionada;
  Map<String, dynamic>? preguntaActual;
  List<Map<String, dynamic>> preguntasTema = [];
  Set<int> preguntasVistas = {};
  bool respuestaComprobada = false;
  bool esCorrecto = false;
  List<bool> respuestasCorrectas = [];
  int? _indicePreguntaGuardada;

  int aciertosTema = 0;
  int fallosTema = 0;
  final estadisticas = EstadisticasModel();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // Guardar y cargar resultados (sin cambios)
  Future<void> _guardarResultados(int correctas, int incorrectas) async {
    final prefs = await SharedPreferences.getInstance();
    final fechasKey = 'fechas_${widget.nombre}';
    final correctasKey = 'correctas_${widget.nombre}';
    final incorrectasKey = 'incorrectas_${widget.nombre}';
    final ahora = DateTime.now().toString();

    List<String> fechas = prefs.getStringList(fechasKey) ?? [];
    fechas.add(ahora);
    await prefs.setStringList(fechasKey, fechas);

    List<String> correctasList = prefs.getStringList(correctasKey) ?? [];
    correctasList.add(correctas.toString());
    await prefs.setStringList(correctasKey, correctasList);

    List<String> incorrectasList = prefs.getStringList(incorrectasKey) ?? [];
    incorrectasList.add(incorrectas.toString());
    await prefs.setStringList(incorrectasKey, incorrectasList);
  }

  // Método para finalizar el test
  void finalizarTema() {
    bool todasCorrectas = verificarRespuestasCorrectas();
    String resultado = todasCorrectas ? "completado" : "incompleto";

    if (todasCorrectas) {
      widget.temaProgress[widget.nombre]?.temaIniciado = true;
      widget.temaProgress[widget.nombre]?.respuestasCorrectas =
          respuestasCorrectas;
    }

    _guardarResultados(
        aciertosTema, fallosTema); // Guarda la fecha y resultados
    _incrementarVecesRealizado(); // Incrementa veces realizado

    Navigator.pop(context, resultado);
  }

  bool verificarRespuestasCorrectas() {
    return respuestasCorrectas.isNotEmpty &&
        respuestasCorrectas.every((respuesta) => respuesta == true);
  }

  @override
  void initState() {
    super.initState();
    reiniciarProgresoTema(); // Asegura el reinicio en cada acceso
    _cargarPreguntas(); // Cargar preguntas completas después de reiniciar el progreso
    _startTimer(); // Inicia el temporizador
  }

  // Método para reiniciar el progreso
  void reiniciarProgresoTema() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(
        'indicePregunta_${widget.nombre}'); // Limpia el progreso guardado del tema en SharedPreferences
    setState(() {
      _indicePreguntaGuardada = 0; // Reinicia el índice a la primera pregunta
      preguntasVistas.clear(); // Limpia todas las preguntas vistas
      respuestasCorrectas = List<bool>.filled(
          preguntasTema.length, false); // Reinicia la lista de respuestas
      aciertosTema = 0; // Reinicia aciertos
      fallosTema = 0; // Reinicia fallos
    });
  }

  Future<void> _guardarProgresoPregunta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'indicePregunta_${widget.nombre}', _indicePreguntaGuardada ?? 0);
  }

  Future<void> _incrementarVecesRealizado() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'vecesRealizado_${widget.nombre}';
    final vecesRealizado = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, vecesRealizado + 1);
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed;
      });
    });
  }

  Future<void> _cargarPreguntas() async {
    final String response =
        await rootBundle.loadString('assets/preguntas_test.json');
    final data = json.decode(response);

    final temaNumero =
        int.tryParse(widget.nombre.replaceAll("Tema ", "")) ?? -1;

    final preguntas = data['temas'].firstWhere(
      (tema) => int.tryParse(tema['tema'].toString()) == temaNumero,
      orElse: () => null,
    )?['preguntas'];

    if (preguntas != null && preguntas.isNotEmpty) {
      setState(() {
        preguntasTema = List<Map<String, dynamic>>.from(preguntas);
        preguntasTema.shuffle(); // Baraja las preguntas al cargar el tema
        respuestasCorrectas = List<bool>.filled(preguntasTema.length, false);
        _siguientePregunta();
      });
    } else {
      setState(() {
        preguntaActual = null;
        respuestaComprobada = false;
      });
    }
  }

  void _siguientePregunta() {
    if (preguntasVistas.length == preguntasTema.length) {
      finalizarTema();
      return;
    }

    setState(() {
      int index;
      do {
        index = Random().nextInt(preguntasTema.length);
      } while (preguntasVistas.contains(index));

      preguntasVistas.add(index);
      preguntaActual = preguntasTema[index];
      _indicePreguntaGuardada = index;
      _guardarProgresoPregunta();
      respuestaComprobada = false;
      _respuestaSeleccionada = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el número del tema a partir del nombre
    final temaNumero =
        int.tryParse(widget.nombre.replaceAll("Tema ", "")) ?? -1;
    return Scaffold(
      appBar: AppBar(
        // Modificado para mostrar "Preguntas del Tema {número del tema}"
        title: Text('Preguntas del Tema $temaNumero'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            reiniciarProgresoTema(); // Reinicia el progreso al retroceder
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          child: Center(
            // Centrado vertical y horizontal
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra la columna
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centra los elementos
              children: <Widget>[
                TimerWidget(duration: _elapsedTime),
                const SizedBox(height: 20.0),
                if (preguntaActual != null)
                  Text(
                    preguntaActual!['pregunta'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    'No se encontraron preguntas para este tema.',
                    style: TextStyle(fontSize: 20, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 30.0),
                if (preguntaActual != null)
                  ...preguntaActual!['opciones'].map<Widget>((opcion) {
                    int index = preguntaActual!['opciones'].indexOf(opcion);
                    Color buttonColor = Colors.white;
                    if (respuestaComprobada) {
                      if (index == _respuestaSeleccionada) {
                        buttonColor = esCorrecto ? Colors.green : Colors.red;
                      } else if (!esCorrecto &&
                          opcion == preguntaActual!['respuesta_correcta']) {
                        buttonColor = Colors.green;
                      }
                    } else if (index == _respuestaSeleccionada) {
                      buttonColor = Colors.yellow;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onPressed: () {
                          setState(() {
                            if (!respuestaComprobada) {
                              _respuestaSeleccionada = index;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            opcion,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 40.0),
                if (!respuestaComprobada && preguntaActual != null)
                  ElevatedButton(
                    onPressed: _respuestaSeleccionada != null
                        ? () {
                            setState(() {
                              respuestaComprobada = true;
                              esCorrecto = preguntaActual!['opciones']
                                      [_respuestaSeleccionada!] ==
                                  preguntaActual!['respuesta_correcta'];

                              int preguntaIndex =
                                  preguntasTema.indexOf(preguntaActual!);
                              if (preguntaIndex != -1) {
                                respuestasCorrectas[preguntaIndex] = esCorrecto;
                              }

                              if (esCorrecto) {
                                estadisticas
                                    .incrementarCorrectas(widget.nombre);
                                aciertosTema++;
                              } else {
                                estadisticas
                                    .incrementarIncorrectas(widget.nombre);
                                fallosTema++;
                              }
                            });
                          }
                        : null,
                    child: const Text('Comprobar Respuesta'),
                  ),
                if (respuestaComprobada)
                  Column(
                    children: [
                      Text(
                        esCorrecto
                            ? '¡Correcto!'
                            : 'Incorrecto, intenta de nuevo.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: esCorrecto ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _siguientePregunta,
                        child: const Text('Siguiente Pregunta'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
