import 'package:appoposiciones/PreguntasNivelPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Repaso extends StatefulWidget {
  const Repaso({super.key});

  @override
  State<Repaso> createState() => _RepasoState();
}

class _RepasoState extends State<Repaso> {
  Map<int, List<Map<String, dynamic>>> preguntasPorNivel = {
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
  };

  List<Map<String, dynamic>> temas = [];

  @override
  void initState() {
    super.initState();
    _cargarTemas();
  }

  // Cargar los temas desde el archivo JSON
  Future<void> _cargarTemas() async {
    final String response = await DefaultAssetBundle.of(context)
        .loadString('assets/preguntas_desarrollo.json');
    final data = json.decode(response);
    setState(() {
      temas = List<Map<String, dynamic>>.from(data['temas']);
    });
  }

  // Cargar las preguntas calificadas y almacenarlas por nivel
  Future<void> _cargarPreguntasCalificadas(int nivel) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> preguntasCalificadas = [];

    for (var tema in temas) {
      String key = '${tema['tema']}_puntuaciones';
      List<String>? storedPuntuaciones = prefs.getStringList(key) ?? [];
      for (int i = 0; i < storedPuntuaciones.length; i++) {
        int calificacion = int.parse(storedPuntuaciones[i]);
        if (calificacion == nivel) {
          preguntasCalificadas.add({
            'pregunta': tema['preguntas'][i]['pregunta'],
            'respuesta': tema['preguntas'][i]['respuesta'],
            'calificacion': calificacion,
          });
        }
      }
    }

    setState(() {
      preguntasPorNivel[nivel] = preguntasCalificadas;
    });

    // Mostrar las preguntas del nivel seleccionado
    if (preguntasCalificadas.isNotEmpty) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => PreguntasNivelPage(
            nivel: nivel,
            preguntas: preguntasCalificadas,
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No hay preguntas calificadas para este nivel."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = 120;
    double cardWidth = 0.75;

    List<Map<String, dynamic>> niveles = [
      {
        'label': "Fácil",
        'nivel': 1,
        'estrellas': [Icons.star_border],
        'emoticono': Icons.child_care,
        'color': Colors.green,
      },
      {
        'label': "Medio-Fácil",
        'nivel': 2,
        'estrellas': [Icons.star_border, Icons.star_border],
        'emoticono': Icons.directions_walk,
        'color': Colors.lightBlue,
      },
      {
        'label': "Medio",
        'nivel': 3,
        'estrellas': [Icons.star_border, Icons.star_border, Icons.star_border],
        'emoticono': Icons.directions_car,
        'color': Colors.orange,
      },
      {
        'label': "Medio-Difícil",
        'nivel': 4,
        'estrellas': [
          Icons.star_border,
          Icons.star_border,
          Icons.star_border,
          Icons.star_border
        ],
        'emoticono': Icons.airplanemode_active,
        'color': Colors.red,
      },
      {
        'label': "Difícil",
        'nivel': 5,
        'estrellas': [
          Icons.star_border,
          Icons.star_border,
          Icons.star_border,
          Icons.star_border,
          Icons.star_border
        ],
        'emoticono': Icons.rocket_launch,
        'color': Colors.purple,
      },
    ];

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var nivel in niveles)
                  _nivelCard(
                    context,
                    nivel['label'],
                    nivel['nivel'],
                    nivel['estrellas'],
                    nivel['emoticono'],
                    nivel['color'],
                    cardHeight,
                    screenWidth,
                    cardWidth,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nivelCard(
      BuildContext context,
      String label,
      int nivel,
      List<IconData> estrellas,
      IconData emoticono,
      Color color,
      double cardHeight,
      double screenWidth,
      double cardWidth) {
    return SizedBox(
      width: screenWidth * cardWidth,
      height: cardHeight,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        color: color,
        child: InkWell(
          onTap: () {
            _cargarPreguntasCalificadas(nivel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: estrellas.map((estrella) {
                    return Icon(
                      estrella,
                      color: Colors.yellow,
                      size: 20,
                    );
                  }).toList(),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Icon(emoticono, color: Colors.yellow, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
