// Importa 'dart:convert' para manejar la codificación y decodificación JSON
// ignore: unused_import
import 'dart:convert';
// Importa 'dart:io' para acceder al sistema de archivos y manejar archivos locales
// ignore: unused_import
import 'dart:io';
// Importa la pantalla principal de la app
import 'package:appoposiciones/home.dart';
// Importa la pantalla de registro de la app
import 'package:appoposiciones/registro.dart';
// Importa Firebase Auth para autenticar usuarios mediante Firebase
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
// Importa los widgets básicos de Flutter, necesarios para construir interfaces de usuario
import 'package:flutter/material.dart';
// Importa 'path_provider' para acceder a directorios específicos en el dispositivo
// ignore: unused_import
import 'package:path_provider/path_provider.dart';
// Importa el archivo de tema personalizado para aplicar estilos consistentes en la app
import 'theme.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RecordarContrasena.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key, required this.title});
  final String title;

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _usernameController =
      TextEditingController(); // Controlador para el campo de usuario
  final TextEditingController _passwordController =
      TextEditingController(); // Controlador para el campo de contraseña
  bool _passwordVisible = false; // Estado para la visibilidad de la contraseña
  // ignore: unused_field, prefer_final_fields
  List<dynamic> _users = []; // Lista para almacenar los usuarios registrados

  // Botón de login: aquí validamos que el usuario existe en Firebase Auth
  // ignore: non_constant_identifier_names
  Widget BotonAcceder(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) {
    return ElevatedButton(
      style: AppTheme.botonFuncional(),
      onPressed: () async {
        String username = usernameController.text;
        String password = passwordController.text;

        // Validamos si los campos están vacíos
        if (username.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todos los campos son obligatorios.')),
          );
          return;
        }
        //  Consultar firestore para verificar el usuario y contraseña
        try {
          // Intentamos hacer login con Firebase Auth
          // ignore: unused_local_variable
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: username, password: password);
          // Si el login es exitoso, redirige a la pantalla principal
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          // Si el login falla, muestra el error
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${e.message}')),
          );
        }
        //  Consultar firestore para verificar el usuario y contraseña
        try {
          // Intentamos hacer login con Firebase Auth
          // ignore: unused_local_variable
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: username, password: password);
          // Si el login es exitoso, redirige a la pantalla principal
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          // Si el login falla, muestra el error
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${e.message}')),
          );
        }
      },
      child: const Text('Login'),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Oculta el botón de retroceso en el AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(
            20.0), // Espaciado de 20px alrededor del contenido
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Logo de la app en la parte superior
              Image.asset(
                "assets/images/LogoAcademia.jpg",
                height: 250,
                width: 150,
              ),
              const SizedBox(height: 30), // Separador vertical
              buildTextFields(), // Campos de texto para usuario y contraseña
              const SizedBox(height: 30), // Separador vertical
              BotonAcceder(context, _usernameController,
                  _passwordController), // Botón de acceso
              const SizedBox(height: 30), // Separador vertical

              // Texto para el registro con enlace que lleva directamente a la pantalla de registro
              TextButton(
                onPressed: () {
                  // Redirige directamente a la pantalla de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PantallaRegistro()), // Navega a la pantalla de registro
                  );
                },
                child: const Text("¿No estás registrado? Regístrate aquí"),
              ),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 1,
              ),
              TextButton(
                onPressed: () {
                  // Redirige directamente a la pantalla de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RecordarContrasena()), // Navega a la pantalla de registro
                  );
                },
                child: const Text("¿Has olvidado tu contraseña?"),
              ),
            ],
          ),
        ),
      )
    );

  }




  // Campos de texto para el usuario y la contraseña, centrados y con diseño personalizado
  Widget buildTextFields() {
    return Center(
      child: Column(
        children: [
          // Campo de texto para el nombre de usuario con fondo transparente, borde azul celeste y texto en negro
          SizedBox(
            width: 250, // Define un ancho fijo más pequeño
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText:
                    'Email', // Aparece en la parte inferior al hacer clic
                filled: true,
                fillColor: const Color.fromARGB(
                    255, 217, 227, 251), // Fondo transparente
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(
                          255, 60, 120, 255)), // Borde azul celeste
                  borderRadius: BorderRadius.circular(
                      10), // Borde con esquinas redondeadas
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 120, 255),
                      width: 2), // Borde más grueso al enfocar
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.black), // Texto en negro
            ),
          ),
          const SizedBox(height: 10), // Separador vertical entre campos

          // Campo de texto para la contraseña con el mismo diseño personalizado
          SizedBox(
            width: 250, // Define el mismo ancho que el campo de usuario
            child: TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible, // Cambia según la visibilidad
              decoration: InputDecoration(
                labelText:
                    'Contraseña', // Aparece en la parte inferior al hacer clic
                filled: true,
                fillColor: const Color.fromARGB(
                    255, 217, 227, 251), // Fondo transparente
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(
                          255, 60, 120, 255)), // Borde azul celeste
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 60, 120, 255),
                      width: 2), // Borde más grueso al enfocar
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color.fromARGB(255, 60, 120, 255),
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible =
                          !_passwordVisible; // Alterna visibilidad
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.black), // Texto en negro
            ),
          ),
        ],
      ),
    );
  }
}