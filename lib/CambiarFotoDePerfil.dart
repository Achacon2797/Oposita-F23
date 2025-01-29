import 'package:flutter/material.dart'; // Importa el paquete de Flutter para la interfaz de usuario
import 'dart:io'; // Importa la biblioteca para manejar archivos
import 'package:image_picker/image_picker.dart'; // Importa la biblioteca para seleccionar imágenes
// ignore: unused_import
import 'package:permission_handler/permission_handler.dart'; // Importa el paquete para manejar permisos
// ignore: unused_import
import 'theme.dart'; // Importa el archivo que contiene el tema
import 'package:shared_preferences/shared_preferences.dart'; // Para almacenamiento local en Web
// ignore: unused_import
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Para codificar y decodificar base64

class CambiarFotoDePerfil extends StatefulWidget {
  const CambiarFotoDePerfil({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CambiarFotoDePerfilState createState() => _CambiarFotoDePerfilState();
}

class _CambiarFotoDePerfilState extends State<CambiarFotoDePerfil> {
  File? _imagenPerfil;
  String? _imagenBase64; // Base64 para web y persistencia en móviles
  final String _imagenPredeterminada =
      'assets/images/UsuarioPredeterminado.jpg';

  @override
  void initState() {
    super.initState();
    _cargarImagenPerfil();
  }

  // Cargar la imagen desde SharedPreferences (o usar la predeterminada)
  Future<void> _cargarImagenPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image =
        prefs.getString('imagenPerfil'); // Obtener la imagen base64

    if (base64Image != null) {
      setState(() {
        _imagenBase64 = base64Image; // Guardar la imagen base64
        _imagenPerfil = null; // No hay archivo físico en web
      });
    } else {
      setState(() {
        _imagenBase64 = null;
        _imagenPerfil = null; // Usar la predeterminada
      });
    }
  }

  // Cambiar la imagen de perfil y guardarla como base64
  Future<void> _cambiarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes =
          await pickedFile.readAsBytes(); // Compatible con Flutter Web
      if (bytes.isNotEmpty) {
        // Validar que no esté vacía
        final base64Image = base64Encode(bytes); // Convertir a base64
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'imagenPerfil', base64Image); // Guardar en SharedPreferences
        // ignore: avoid_print
        print('Imagen válida guardada'); // Depuración

        setState(() {
          _imagenBase64 = base64Image; // Actualizar la imagen en memoria
          _imagenPerfil = null; // No necesitamos un archivo físico
        });
      } else {
        // ignore: avoid_print
        print('La imagen seleccionada está vacía'); // Depuración si falla
      }
    }
  }

  // Eliminar la imagen personalizada (restaurar la predeterminada)
  Future<void> _restaurarImagenPredeterminada() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('imagenPerfil'); // Eliminar la imagen guardada

    setState(() {
      _imagenBase64 = null; // Restaurar a la predeterminada
      _imagenPerfil = null;
    });
  }

  // Mostrar la imagen según su estado (base64, archivo o predeterminada)
  Widget _mostrarImagenPerfil() {
    if (_imagenBase64 != null) {
      final bytes = base64Decode(_imagenBase64!); // Decodificar base64
      return Image.memory(
        bytes,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (_imagenPerfil != null) {
      return Image.file(
        _imagenPerfil!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        _imagenPredeterminada,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Foto de Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _mostrarImagenPerfil(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cambiarImagen,
              child: const Text('Cambiar Imagen'),
            ),
            ElevatedButton(
              onPressed: _restaurarImagenPredeterminada,
              child: const Text('Restaurar Imagen Predeterminada'),
            ),
          ],
        ),
      ),
    );
  }
}
