import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: use_key_in_widget_constructors
class RecordarContrasena extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RecordarContrasenaState createState() => _RecordarContrasenaState();
}

class _RecordarContrasenaState extends State<RecordarContrasena> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();

  Color get cajaColorFondo => const Color.fromARGB(255, 217, 227, 251);

  // Método para enviar el correo de restablecimiento de contraseña
  Future<void> _enviarCorreoRestablecimiento(String email) async {
    try {
      // Intentamos enviar el correo de restablecimiento de contraseña
      await _auth.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo de restablecimiento enviado a $email')),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo: ${e.message}')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error desconocido: $e')),
      );
    }
  }

  // Método para verificar si el correo está registrado en Firestore
  Future<void> _verificarCorreoEnFirestore(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: prefer_const_constructors
        SnackBar(content: Text('Por favor ingresa el email.')),
      );
      return;
    }

    try {
      // Consultamos Firestore para verificar si el correo existe en la colección 'usuarios'
      QuerySnapshot querySnapshot = await _firestore
          .collection('Usuarios')
          .where('Email', isEqualTo: email)
          .get();

      // Si no existe el correo en Firestore
      if (querySnapshot.docs.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: prefer_const_constructors
          SnackBar(
              // ignore: prefer_const_constructors
              content: Text('Este correo no está registrado en Firestore')),
        );
        return; // No continuamos, ya que el correo no está registrado en Firestore
      }

      // Si el correo existe en Firestore, enviamos el correo de restablecimiento
      await _enviarCorreoRestablecimiento(email);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al verificar el correo en Firestore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ignore: prefer_const_constructors
            Text(
              'Restablecer contraseña',
              // ignore: prefer_const_constructors
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20),
            // ignore: prefer_const_constructors
            Text(
              'Introduce el email empleado en el registro y te enviaremos instrucciones para cambiar la contraseña.',
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              // ignore: prefer_const_constructors
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Introduce tu email',
                fillColor: cajaColorFondo,
                filled: true,
                // ignore: prefer_const_constructors
                border: OutlineInputBorder(),
              ),
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text.trim();
                _verificarCorreoEnFirestore(
                    email); // Llamamos al método para verificar el correo en Firestore
              },
              // ignore: prefer_const_constructors
              child: Text(
                'RESTABLECER',
                // ignore: prefer_const_constructors
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
