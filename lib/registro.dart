// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
// ignore: unused_import
import 'dart:convert'; // Para manejar JSON
import 'package:appoposiciones/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Paquete de Flutter para la interfaz de usuario
// ignore: unused_import
import 'package:path_provider/path_provider.dart'; // Para obtener el directorio del sistema
// ignore: unused_import
import 'dart:io'; // Para manejar archivos
// ignore: unused_import
import 'package:appoposiciones/home.dart'; // Asegúrate de que la ruta sea correcta
import 'theme.dart'; // Importa el archivo que contiene el tema
// ignore: unused_import
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para saber si está en web
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter/services.dart' show rootBundle;

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

/*
Funciones para guardar, cargar y eliminar la imagen
*/

Future<File> _getImagenPerfilPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/imagen_perfil_usuario.jpg');
}

// Guardar la imagen seleccionada en local
Future<void> guardarImagenPerfil(File nuevaImagen) async {
  final pathImagenPerfil = await _getImagenPerfilPath();
  await nuevaImagen.copy(pathImagenPerfil.path);
}

// Cargar la imagen guardada o usar la predeterminada
Future<File?> cargarImagenPerfil() async {
  final pathImagenPerfil = await _getImagenPerfilPath();
  if (await pathImagenPerfil.exists()) {
    return pathImagenPerfil;
  }
  return null; // Si no existe, usa la predeterminada
}

// Eliminar la imagen guardada
Future<void> eliminarImagenPerfil() async {
  final pathImagenPerfil = await _getImagenPerfilPath();
  if (await pathImagenPerfil.exists()) {
    await pathImagenPerfil.delete();
  }
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final firebase = FirebaseFirestore.instance;

  // Variables para almacenar errores de validación
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  // Variable de estado para controlar la visibilidad de la contraseña
  bool _isPasswordVisible = false;

  Color get cajaColorFondo =>
      const Color.fromARGB(255, 217, 227, 251); // Fondo de los cuadros de texto
  Color get textoColorCaja => const Color.fromARGB(
      255, 60, 120, 255); // Color del texto en los cuadros de texto

  final FirebaseAuth auth = FirebaseAuth.instance; // Instancia de FirebaseAuth

  // Función para registrar el usuario y almacenar sus datos en Firestore
  Future<void> registroUsuario() async {
    try {
      // Ruta de la imagen predeterminada en los assets
      // ignore: unused_local_variable
      const defaultProfileImagePath = 'assets/images/UsuarioPredeterminado.jpg';

      // Crear usuario con FirebaseAuth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 2. Guardar detalles adicionales del usuario en Firestore
      await firebase.collection('Usuarios').doc(userCredential.user?.uid).set({
        'Nombre':
            _usernameController.text, // Aparece en la parte inferior al enfocar
        'Email': _emailController.text,
        'Contraseña': _passwordController
            .text, // Nota: evitar guardar contraseñas sin cifrar en producción
      });

      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente.')),
      );

      // Redirigir al login
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => const PantallaLogin(title: 'login')),
      );
    } catch (e) {
      // Mostrar mensaje de error si falla el registro
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
  }

  // Métodos de validación para los campos
  void _validateUsername(String value) {
    setState(() {
      _usernameError = (value.isEmpty)
          ? ' El nombre de usuario no puede estar vacío'
          : (value.length > 15)
              ? 'Máximo 15 caracteres'
              : null;
    });
  }

  void _validateEmail(String value) {
    setState(() {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      _emailError = (value.isEmpty)
          ? 'El correo electrónico no puede estar vacío'
          : (!emailRegex.hasMatch(value))
              ? 'Formato de correo electrónico inválido'
              : null;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = (value.length < 8)
          ? 'Mínimo 8 caracteres'
          : (!RegExp(r'[A-Z]').hasMatch(value) ||
                  !RegExp(r'[a-z]').hasMatch(value) ||
                  !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))
              ? 'Debe contener una mayúscula, una minúscula y un símbolo'
              : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definir el ancho adaptable de las cajas de texto según el tamaño de la pantalla, con límite máximo en pantallas grandes
    double anchoCajasTexto = MediaQuery.of(context).size.width <
            600 // Ajusta el ancho de la caja de texto
        ? MediaQuery.of(context).size.width * 0.8 // Ancho adaptativo para móvil
        : 400; // Ancho máximo fijo para pantallas grandes

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // Logo de la aplicación en la parte superior
              Image.asset(
                'assets/images/LogoAcademia.jpg',
                height: 250,
                width: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Regístrate',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              // Campo de texto para nombre de usuario con diseño adaptable
              SizedBox(
                width: anchoCajasTexto, // Ajusta el ancho de la caja de texto
                child: TextField(
                  controller: _usernameController,
                  onChanged: _validateUsername,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Usuario',
                    hintText: 'Nombre de Usuario',
                    hintStyle:
                        TextStyle(color: textoColorCaja.withOpacity(0.6)),
                    fillColor: cajaColorFondo,
                    filled: true,
                    errorText: _usernameError,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: textoColorCaja),
                ),
              ),
              const SizedBox(height: 20),
              // Campo de texto para correo electrónico con diseño adaptable
              SizedBox(
                width: anchoCajasTexto,
                child: TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'Correo Electrónico',
                    hintStyle:
                        TextStyle(color: textoColorCaja.withOpacity(0.6)),
                    fillColor: cajaColorFondo,
                    filled: true,
                    errorText: _emailError,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: textoColorCaja),
                ),
              ),
              const SizedBox(height: 20),
              // Campo de texto para la contraseña con el ícono de visibilidad
              SizedBox(
                width: anchoCajasTexto,
                child: TextField(
                  controller: _passwordController,
                  onChanged: _validatePassword,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Contraseña',
                    hintStyle:
                        TextStyle(color: textoColorCaja.withOpacity(0.6)),
                    fillColor: cajaColorFondo,
                    filled: true,
                    errorText: _passwordError,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textoColorCaja, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: textoColorCaja,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: textoColorCaja),
                ),
              ),
              const SizedBox(height: 20),
              // Botón de registro
              SizedBox(
                width: anchoCajasTexto * 0.6,
                height: 40,
                child: ElevatedButton(
                  style: AppTheme.botonFuncional(),
                  onPressed: () {
                    if (_usernameError == null &&
                        _emailError == null &&
                        _passwordError == null) {
                      registroUsuario();
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
