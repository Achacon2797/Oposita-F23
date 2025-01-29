import 'package:flutter/material.dart';

class PreguntasNivelPage extends StatefulWidget {
  final int nivel;
  final List<Map<String, dynamic>> preguntas;

  const PreguntasNivelPage(
      {super.key, required this.nivel, required this.preguntas});

  @override
  // ignore: library_private_types_in_public_api
  _PreguntasNivelPageState createState() => _PreguntasNivelPageState();
}

class _PreguntasNivelPageState extends State<PreguntasNivelPage> {
  int preguntaActual = 0; // Para llevar el control de la pregunta actual
  bool _mostrarRespuesta = false; // Controlar si se muestra la respuesta

  @override
  void initState() {
    super.initState();
    preguntaActual =
        0; // Inicializamos para que comience desde la primera pregunta
    _mostrarRespuesta = false; // Inicializamos la respuesta oculta
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = widget.preguntas[preguntaActual];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel ${widget.nivel}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Cambiado de center a start
          crossAxisAlignment:
              CrossAxisAlignment.center, // Alineación horizontal centrada
          children: [
            const SizedBox(
                height:
                    20), // Reducido a 20px para mover la pregunta más arriba

            // Centrar la pregunta
            Center(
              child: Text(
                'Pregunta ${preguntaActual + 1}: ${pregunta['pregunta']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign:
                    TextAlign.center, // Asegurar que el texto también se centre
              ),
            ),
            const SizedBox(height: 50),

            // Botón para ver la respuesta
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mostrarRespuesta = !_mostrarRespuesta;
                });
              },
              child: Text(
                  _mostrarRespuesta ? "Ocultar respuesta" : "Ver respuesta"),
            ),

            // Mostrar la respuesta solo si mostrarRespuesta es verdadero
            if (_mostrarRespuesta) ...[
              const SizedBox(height: 10),
              Text(
                "Respuesta: ${pregunta['respuesta']}",
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
            ],

            // Botón de siguiente pregunta, solo habilitado si se ha visto la respuesta
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _mostrarRespuesta
                  ? () {
                      if (preguntaActual < widget.preguntas.length - 1) {
                        setState(() {
                          preguntaActual++;
                          _mostrarRespuesta = false; // Resetear la respuesta
                        });
                      } else {
                        // Aquí puedes manejar el caso cuando ya se han mostrado todas las preguntas
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("¡Has terminado todas las preguntas!")),
                        );
                        Navigator.pop(context);
                        // Opcional: Volver atrás o hacer otra acción
                      }
                    }
                  : null, // El botón solo estará habilitado si se ha mostrado la respuesta
              child: Text(
                preguntaActual == widget.preguntas.length - 1
                    ? "Finalizar"
                    : "Siguiente Pregunta",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
