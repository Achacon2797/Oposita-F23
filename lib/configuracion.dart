import 'package:appoposiciones/login.dart';
import 'package:flutter/material.dart';
import 'CambiarNombreUsuario.dart';
import 'CambiarContrasena.dart';
import 'CambiarFotoDePerfil.dart';
import 'theme.dart';
import 'estadisticas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para decodificar base64
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart'; // Para obtener datos de Firestore

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables de estado
  String _nombreActual = "";
  dynamic _imagenPerfil; // Puede ser Image o File
  final String _imagenPredeterminada =
      'assets/images/UsuarioPredeterminado.jpg';

  @override
  void initState() {
    super.initState();
    _cargarNombreActual(); // Cargar el nombre al iniciar
    _cargarImagenPerfil(); // Cargar la imagen de perfil al iniciar
  }

  // Cargar la imagen de perfil desde SharedPreferences
  Future<void> _cargarImagenPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('imagenPerfil');
    if (base64String != null && kIsWeb) {
      // Para web
      setState(() {
        _imagenPerfil = Image.memory(
          base64Decode(base64String),
          width: 150, // Tamaño aumentado un 50%
          height: 150,
          fit: BoxFit.cover,
        );
      });
    } else if (base64String != null) {
      // Para móvil
      setState(() {
        _imagenPerfil = Image.memory(
          base64Decode(base64String),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      });
    } else {
      setState(() {
        // Imagen predeterminada
        _imagenPerfil = Image.asset(
          _imagenPredeterminada,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      });
    }
  }

  // Método para cargar el nombre actual desde Firebase Firestore
  Future<void> _cargarNombreActual() async {
    try {
      User? usuarioActual = _auth.currentUser; // Obtener usuario actual
      if (usuarioActual != null) {
        DocumentSnapshot usuarioDoc = await _firestore
            .collection('Usuarios')
            .doc(usuarioActual.uid)
            .get();

        // Si el documento existe, actualizar el nombre
        if (usuarioDoc.exists && usuarioDoc['Nombre'] != null) {
          setState(() {
            _nombreActual = usuarioDoc['Nombre'];
          });
        } else {
          setState(() {
            _nombreActual = 'Nombre no disponible';
          });
        }
      }
    } catch (e) {
      setState(() {
        _nombreActual = 'Error al cargar el Nombre';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CambiarFotoDePerfil()),
                ).then((_) {
                  _cargarImagenPerfil(); // Recargar la imagen al regresar
                });
              },
              child: ClipOval(
                child: _imagenPerfil ?? const CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _nombreActual, // Mostrar el nombre actual
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: AppTheme.botonConfiguracion(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Estadisticas()),
                        );
                      },
                      child: const Text('Estadísticas'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: AppTheme.botonConfiguracion(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CambiarNombreUsuario()),
                        ).then((_) {
                          // Recargar el nombre al regresar
                          _cargarNombreActual();
                        });
                      },
                      child: const Text('Actualizar Nombre'),
                    ),
                    const SizedBox(height: 20),

                    // Botón para cambiar la contraseña del usuario
                    ElevatedButton(
                      style: AppTheme.botonConfiguracion(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CambiarContrasena()),
                        );
                      },
                      child: const Text('Modificar Contraseña'),
                    ),
                    const SizedBox(height: 20),
                    // Botón para cambiar la imagen de perfil del usuario
                    ElevatedButton(
                      style: AppTheme.botonConfiguracion(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CambiarFotoDePerfil()),
                        ).then((_) {
                          _cargarImagenPerfil(); // Recargar la imagen al regresar
                        });
                      },
                      child: const Text('Cambiar Imagen de Perfil'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Botón flotante para cerrar sesión, colocado en la esquina inferior derecha
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // Navega a la pantalla de inicio de sesión cuando se pulsa
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const PantallaLogin(title: 'Login')),
            );
          });
        },
        backgroundColor: const Color.fromRGBO(237, 145, 28, 1),
        child: const Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
