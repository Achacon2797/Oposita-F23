import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class CambiarNombreUsuario extends StatefulWidget {
  const CambiarNombreUsuario({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CambiarNombreUsuarioState createState() => _CambiarNombreUsuarioState();
}

class _CambiarNombreUsuarioState extends State<CambiarNombreUsuario> {
  final TextEditingController _newNameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _nombreActual = '';

  @override
  void initState() {
    super.initState();
    _cargarNombreActual();
  }

  Future<void> _cargarNombreActual() async {
    try {
      User? usuarioActual = _auth.currentUser;
      if (usuarioActual != null) {
        DocumentSnapshot usuarioDoc = await _firestore
            .collection('Usuarios')
            .doc(usuarioActual.uid)
            .get();

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

  Future<void> _cambiarNombreUsuario() async {
    String nuevoNombre = _newNameController.text.trim();

    if (nuevoNombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el nuevo nombre')),
      );
      return;
    }

    try {
      User? usuarioActual = _auth.currentUser;
      if (usuarioActual == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      DocumentReference usuarioDoc =
          _firestore.collection('Usuarios').doc(usuarioActual.uid);

      await usuarioDoc.update({'Nombre': nuevoNombre});

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre actualizado a: $nuevoNombre')),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar Nombre: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Nombre de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre actual: $_nombreActual',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nuevo nombre:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newNameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 217, 227, 251),
                border: OutlineInputBorder(),
                hintText: 'Escribe el nuevo nombre',
                floatingLabelBehavior:
                    FloatingLabelBehavior.auto, // Flota al hacer foco
                labelText: 'Escribe el nuevo nombre',
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: AppTheme.botonFuncional(),
              onPressed: _cambiarNombreUsuario,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
