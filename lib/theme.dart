import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String fontFamily = 'Times New Roman';

class AppTheme {
  /* ANCHO BOTONES TEMAS */
  static double getButtonWidth(BuildContext context) {
    return MediaQuery.of(context).size.width *
        0.95; // 95% del ancho de la pantalla
  }

  // Paleta de colores
  static const Color primaryColor =
      Color.fromARGB(255, 255, 255, 255); // Morado
  static const Color secondaryColor =
      Color.fromARGB(255, 209, 225, 224); // Verde aguamarina

  // Colores TEXTO BOTONES TEMAS
  static const Color textCompletado =
      Color.fromRGBO(32, 98, 35, 1); // Letras texto TEMA COMPLETO
  static const Color textEmpezado =
      Color(0xFF6D4C41); // Letras texto TEMA EMPEZADO
  static const Color textNoAbierto =
      Colors.black; // Letras texto TEMA sin EMPEZAR

  // Colores para respuesta correcta e incorrecta
  static const Color respuestaCorrecta = Color(0xFF4CAF50); // Verde
  static const Color respuestaIncorrecta = Color(0xFFD32F2F); // Rojo oscuro

  /* Define un ThemeData para usar en TODA LA APP */
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28, // Tamaño letra
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
        fontFamily: fontFamily,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(1.0, 2.0), // Desplazamiento de la sombra.
            blurRadius: 3.0, // Difuminado de la sombra.
            color: Colors.black26, // Color de la sombra
          )
        ],
      ),
      bodyLarge: TextStyle(
        fontSize: 20.0, // Tamaño de la letra.
        fontWeight: FontWeight.bold, // La letra en negrita.
        color: Colors.blueAccent, // Color de la letra
        letterSpacing: 2.0,
        fontFamily: fontFamily, //
      ),
      bodyMedium: TextStyle(
        color: Colors.black54,
        fontFamily: fontFamily,
      ),
    ),
    inputDecorationTheme: textFieldDecoration,
    cardTheme: cardThemeNormal, // Establecer un tema de Card por defecto
  );

  /* ---ESTILO TEXTFIELD--- */
  static final InputDecorationTheme textFieldDecoration = InputDecorationTheme(
    hintStyle: const TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 45, 45, 45), // Color del hint
      fontFamily: fontFamily,
    ),
    fillColor: const Color.fromARGB(255, 109, 172, 217), // Color de fondo
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  /* ---ESTILO BOTONES--- */
  static ButtonStyle botonFuncional() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 217, 227, 251),
      foregroundColor:
          const Color.fromARGB(255, 60, 120, 255), // Color del texto
      textStyle: const TextStyle(
        fontFamily: fontFamily, // Establecido al principio Tipo de letra.
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  static ButtonStyle botonConfiguracion() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 217, 227, 251),
      foregroundColor:
          const Color.fromARGB(255, 60, 120, 255), // Color del texto
      padding: const EdgeInsets.symmetric(
          vertical: 18.0, horizontal: 40.0), // Aumenta altura y ancho
      textStyle: const TextStyle(
        fontSize: 18, // Ajusta el tamaño de fuente si es necesario
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(30), // Bordes ligeramente redondeados
      ),
    );
  }

// Estilo para el botón cuando el tema está completado correctamente (verde)
  static ButtonStyle happyColor(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(getButtonWidth(context), 50),
      backgroundColor: Colors.green.shade100,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle notStartedColor(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize:
          Size(getButtonWidth(context), 50), // Ancho al 95% y altura fija de 50
      backgroundColor: const Color.fromARGB(
          255, 217, 227, 251), // Color de fondo para "no empezado"
      foregroundColor:
          const Color.fromARGB(255, 60, 120, 255), // Color del texto
      textStyle: const TextStyle(
        fontFamily: fontFamily, // Tipo de letra definido previamente
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle completedColor(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize:
          Size(getButtonWidth(context), 50), // Ancho al 95% y altura fija de 50
      backgroundColor: const Color.fromARGB(
          255, 110, 255, 165), // Color de fondo para "completado"
      foregroundColor: const Color.fromARGB(255, 0, 32, 2), // Color del texto
      textStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle inProgressColor(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize:
          Size(getButtonWidth(context), 50), // Ancho al 95% y altura fija de 50
      backgroundColor: const Color.fromARGB(
          255, 255, 216, 86), // Color de fondo para "en progreso"
      foregroundColor: const Color.fromARGB(255, 58, 19, 0), // Color del texto
      textStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  /* ---ESTILO CARDS--- */
  // Estilo para Card SIN ABRIR
  static final CardTheme cardThemeNormal = CardTheme(
    color: const Color.fromARGB(255, 210, 210, 210),
    shadowColor: const Color.fromARGB(255, 126, 126, 126),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.all(10),
  );

  // Estilo para Card COMPLETADAS
  static final CardTheme cardThemeSuccess = CardTheme(
    color: Colors.green.shade100,
    shadowColor: Colors.green,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.all(10),
  );

  // Estilo para Card EMPEZADAS
  static final CardTheme cardThemeError = CardTheme(
    color: Colors.red.shade100,
    shadowColor: const Color.fromARGB(255, 225, 183, 28),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.all(10),
  );
}

/*
IMAGEN DE PERFIL
*/
// Método reutilizable para cargar imagen de perfil
Future<Widget> cargarImagenPerfil({double width = 100, double height = 100}) async {
  final prefs = await SharedPreferences.getInstance();
  final base64Image = prefs.getString('imagenPerfil');

  if (base64Image != null) {
    final bytes = base64Decode(base64Image);
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      'assets/images/UsuarioPredeterminado.jpg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}


  // Puedes definir otros estilos o adaptarlos según sea necesario

