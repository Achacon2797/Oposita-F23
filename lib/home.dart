import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:appoposiciones/preguntas_test.dart';
import 'package:appoposiciones/preguntas_desarrollo.dart';
import 'theme.dart';
import 'configuracion.dart';
import 'tema_stats.dart';
import 'repaso.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appoposiciones/CambiarFotoDePerfil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Enum para representar el estado de progreso de cada tema en el temario
enum EstadoTemario { noEmpezado, empezado, completado }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  dynamic _imagenPerfil;

  final String _imagenPredeterminada =
      'assets/images/UsuarioPredeterminado.jpg';

  Map<String, bool> temasTerminados = {};

  // Carga el progreso de los temas guardado en SharedPreferences
  Future<void> cargarTemasTerminados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var tema in temasTemario) {
        // Itera sobre los temas de Temario y actualiza el mapa `temasTerminados`
        final nombreTema = tema['tema']!;
        temasTerminados[nombreTema] =
            prefs.getBool('temaTerminado_$nombreTema') ?? false;
      }
    });
  }

  // Verifica si todas las preguntas en un tema han sido respondidas correctamente
  bool allQuestionsCorrect(String tema) {
    // Lógica específica para verificar si todas las preguntas son correctas
    return true; // Cambia esto según tu lógica de validación
  }

  // Carga la imagen de perfil desde el almacenamiento local (SharedPreferences)
  Future<void> _cargarImagenPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String =
        prefs.getString('imagenPerfil'); // Cambia si usas otra clave

    if (base64String != null && kIsWeb) {
      // ignore: avoid_print
      print('Mostrando imagen en web'); // Agregar esta línea para depurar
      setState(() {
        _imagenPerfil = Image.memory(
          base64Decode(base64String),
          width: 100, // Ajustar este valor si la imagen no se muestra
          height: 100,
          fit: BoxFit.cover,
        );
      });
    } else {
      // Carga la ruta de la imagen en dispositivos móviles
      final path = prefs.getString('rutaImagenPerfil');
      if (path != null) {
        setState(() {
          _imagenPerfil = File(path); // Para Android/iOS
        });
      } else {
        // Si no hay imagen personalizada, usa la predeterminada
        setState(() {
          _imagenPerfil = Image.asset(
            _imagenPredeterminada,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarImagenPerfil(); // Carga imagen de perfil al iniciar la app
    _loadTemas();
    cargarTemasTerminados(); // Asegura que temas terminados carguen
  }

  // Carga progreso de archivo JSON (usado para persistencia)
  Future<void> _loadProgress() async {
    final file = await _getProgressFile();
    if (file != null && await file.exists()) {
      final data = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(data);

      // Restaura el progreso desde el archivo JSON
      jsonData['test']?.forEach((tema, stats) {
        temaProgressTest[tema] = TemaStats.fromJson(stats);
      });
      jsonData['desarrollo']?.forEach((tema, stats) {
        temaProgressDesarrollo[tema] = TemaStats.fromJson(stats);
      });
    } else {
      // ignore: avoid_print
      print("Progreso no cargado en web.");
    }
  }

  // Guarda el progreso en un archivo JSON (usado para persistencia)
  Future<void> _saveProgress() async {
    final file = await _getProgressFile();
    if (file != null) {
      final data = {
        'test': temaProgressTest
            .map((tema, stats) => MapEntry(tema, stats.toJson())),
        'desarrollo': temaProgressDesarrollo
            .map((tema, stats) => MapEntry(tema, stats.toJson())),
      };
      await file.writeAsString(json.encode(data));
    } else {
      // ignore: avoid_print
      print("Progreso no guardado en web.");
    }
  }

  // Obtiene el archivo donde se guardará el progreso de la aplicación
  Future<File?> _getProgressFile() async {
    if (kIsWeb) {
      // ignore: avoid_print
      print("Almacenamiento local no disponible en Web.");
      return null; // Retorna nulo en web para continuar
    }
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/temaProgress.json';
    return File(filePath);
  }

  int _currentIndex = 0; // Índice para gestionar la sección activa en la app

  // Mapas para almacenar el progreso de cada tema en Test y Temario
  Map<String, TemaStats> temaProgressTest = {};
  Map<String, TemaStats> temaProgressDesarrollo = {};

  // Listas para almacenar los datos de los temas en Test y Temario
  List<Map<String, String>> temasTest = [];
  List<Map<String, String>> temasTemario = [];

  // Carga los temas y el progreso desde los archivos JSON para Test y Temario
  Future<void> _loadTemas() async {
    await _loadProgress(); // Cargar progreso desde el almacenamiento local

    try {
      final String testData =
          await rootBundle.loadString('assets/preguntas_test.json');
      final Map<String, dynamic> testJson = json.decode(testData);

      // Extrae los temas de Test del archivo JSON y los guarda en la lista temasTest
      if (testJson.containsKey('temas') && testJson['temas'] is List) {
        temasTest =
            List<Map<String, String>>.from(testJson['temas'].map((tema) {
          return {
            "tema": tema['tema'].toString(),
            "titulo": tema['titulo'].toString(),
          };
        }));

        for (var tema in temasTest) {
          temaProgressTest.putIfAbsent(tema["tema"]!, () => TemaStats());
        }
      }
    } catch (e) {
      print("Error al cargar temas de preguntas_test.json: $e");
    }

    try {
      final String desarrolloData =
          await rootBundle.loadString('assets/preguntas_desarrollo.json');
      final Map<String, dynamic> desarrolloJson = json.decode(desarrolloData);

      // Extrae los temas de Desarrollo del archivo JSON y los guarda en la lista temasTemario
      if (desarrolloJson.containsKey('temas') &&
          desarrolloJson['temas'] is List) {
        temasTemario =
            List<Map<String, String>>.from(desarrolloJson['temas'].map((tema) {
          return {
            "tema": tema['tema'].toString(),
            "titulo": tema['titulo'].toString(),
          };
        }));

        for (var tema in temasTemario) {
          temaProgressDesarrollo.putIfAbsent(tema["tema"]!, () => TemaStats());
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error al cargar temas de preguntas_desarrollo.json: $e");
    }

    setState(() {}); // Refresca estado tras cargar temas y progreso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CambiarFotoDePerfil(),
                  ),
                ).then((_) {
                  _cargarImagenPerfil();
                });
              },
              child: FutureBuilder<Widget>(
                future: cargarImagenPerfil(width: 50, height: 50),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Icon(Icons.error, size: 50);
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[200], // Fondo de color claro (puedes cambiarlo)
                      shape: BoxShape.circle, // Mantén la forma circular
                    ),
                    padding: const EdgeInsets.all(
                        4.0), // Espacio alrededor de la imagen
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: snapshot.data,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8), // Espacio entre elementos
            Expanded(
              // Ocupa el espacio disponible
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fontSize = constraints.maxWidth * 0.08;
                  fontSize = fontSize.clamp(16, 24); // Límite de tamaño
                  return Text(
                    _currentIndex == 0
                        ? 'Preguntas Test'
                        : _currentIndex == 1
                            ? 'Preguntas de Desarrollo'
                            : _currentIndex == 2
                                ? 'Repaso'
                                : 'Configuración',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Evita desbordamiento
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 50),
              color: const Color.fromARGB(
                  255, 237, 145, 28), // Naranja definido aquí
              padding: const EdgeInsets.all(8.0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Configuracion()),
                ).then((_) {
                  _cargarImagenPerfil(); // Recarga imagen de perfil al volver a Home
                });
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),

      // Carga pantalla correspondiente según sección activa en BottomNavigationBar
      body: _currentIndex == 0
          ? _buildTemasScreen(context, temasTest, isTest: true)
          : _currentIndex == 1
              ? _buildTemasScreen(context, temasTemario, isTest: false)
              : _currentIndex == 2
                  ? Center(
                      child: _currentIndex == 2
                          ? const Repaso()
                          : const Configuracion())
                  : const Configuracion(),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: (MediaQuery.of(context).size.width * 0.1)
            .clamp(24.0, 48.0), // Entre 24 y 48
        selectedFontSize: (MediaQuery.of(context).size.width * 0.04)
            .clamp(12.0, 18.0), // Entre 12 y 18
        unselectedFontSize: (MediaQuery.of(context).size.width * 0.03)
            .clamp(10.0, 16.0), // Entre 10 y 16

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Temario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Repaso',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

// Construye pantalla selección de temas de Test o Temario
  Widget _buildTemasScreen(
      BuildContext context, List<Map<String, String>> temas,
      {required bool isTest}) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: temas.map((temaMap) {
          final tema = temaMap["tema"]!;
          final titulo = temaMap["titulo"]!;
          final displayText = "Tema $tema. $titulo";
          final emoji =
              isTest ? getEmojiForTest(tema) : getEmojiForTemario(tema);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FutureBuilder<ButtonStyle>(
              future: _getButtonStyle(tema, context, isTest: isTest),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  style: snapshot.data, // Usa el estilo obtenido
                  onPressed: () async {
                    final stats = isTest
                        ? temaProgressTest[tema]!
                        : temaProgressDesarrollo[tema]!;

                    if (!stats.temaIniciado) {
                      stats.temaIniciado = true;
                      stats.resetRespuestas(temaMap["preguntas"]?.length ?? 0);
                    }

                    stats.incrementarVecesRealizado();

                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => isTest
                            ? Preguntas_Test(
                                nombre: tema,
                                temaProgress: temaProgressTest,
                              )
                            : PreguntasDesarrollo(nombre: tema),
                      ),
                    );

                    setState(() {
                      if (resultado == 'completado') {
                        stats.temaIniciado = true;
                      }
                    });

                    _saveProgress(); // Guarda progreso tras cada apertura
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displayText,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Veces realizado: ${isTest ? temaProgressTest[tema]?.vecesRealizado ?? 0 : temaProgressDesarrollo[tema]?.vecesRealizado ?? 0}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      emoji,
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Devuelve el estilo del botón según el progreso del tema
  Future<ButtonStyle> _getButtonStyle(String tema, BuildContext context,
      {required bool isTest}) async {
    if (isTest) {
      final stats = temaProgressTest[tema];
      if (stats != null && stats.todasRespuestasCorrectas()) {
        return AppTheme.happyColor(context);
      } else if (stats != null && stats.temaIniciado) {
        return AppTheme.inProgressColor(context);
      } else {
        return AppTheme.notStartedColor(context);
      }
    } else {
      // Espera el estado de `obtenerEstadoTema` para decidir el color del botón
      final emojiState = await obtenerEstadoTema(tema);
      if (emojiState['finalizado'] == true) {
        // ignore: use_build_context_synchronously
        return AppTheme.happyColor(context); // Verde si el tema está finalizado
      } else if (emojiState['iniciado'] == true) {
        // ignore: use_build_context_synchronously
        return AppTheme.inProgressColor(context); // Amarillo si está iniciado
      } else {
        return AppTheme.notStartedColor(
            // ignore: use_build_context_synchronously
            context); // Color inicial si no está iniciado
      }
    }
  }

  // Función para obtener el emoji en función del progreso de un tema en TEST
  Widget getEmojiForTest(String tema) {
    final stats = temaProgressTest[tema];
    if (stats == null || !stats.temaIniciado) {
      return const SizedBox
          .shrink(); // No muestra nada si el tema no ha sido iniciado
    } else if (stats.temaIniciado && !stats.todasRespuestasCorrectas()) {
      return Image.asset('assets/images/emoji_neutral.png',
          width: 24, height: 24);
    } else {
      return Image.asset('assets/images/emoji_happy.png',
          width: 24, height: 24);
    }
  }

  // Función para obtener el emoji en función del progreso de un tema en TEMARIO
  Widget getEmojiForTemario(String tema) {
    return FutureBuilder<Map<String, bool>>(
      future: obtenerEstadoTema(tema),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        bool temaIniciado = snapshot.data?['iniciado'] ?? false;
        bool temaFinalizado = snapshot.data?['finalizado'] ?? false;

        if (!temaIniciado) {
          return const SizedBox
              .shrink(); // No muestra nada si el tema no ha sido iniciado
        } else if (temaIniciado && !temaFinalizado) {
          return Image.asset('assets/images/emoji_neutral.png',
              width: 24, height: 24);
        } else {
          return Image.asset('assets/images/emoji_happy.png',
              width: 24, height: 24);
        }
      },
    );
  }

  // Carga el estado de cada tema desde el almacenamiento local
  Future<bool> cargarTemaTerminado(String tema) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tema_$tema') ?? false;
  }
}
