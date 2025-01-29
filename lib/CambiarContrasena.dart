import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class CambiarContrasena extends StatefulWidget {
  const CambiarContrasena({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CambiarContrasenaState createState() => _CambiarContrasenaState();
}

class _CambiarContrasenaState extends State<CambiarContrasena> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _repeatPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _cambiarContrasena() async {
    if (_newPasswordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
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

      AuthCredential credenciales = EmailAuthProvider.credential(
        email: usuarioActual.email!,
        password: _oldPasswordController.text,
      );

      await usuarioActual.reauthenticateWithCredential(credenciales);

      await usuarioActual.updatePassword(_newPasswordController.text);

      await _firestore.collection('Usuarios').doc(usuarioActual.uid).update({
        'lastPasswordChange': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña cambiada con éxito')),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              controller: _oldPasswordController,
              label: 'Contraseña antigua',
              isVisible: _oldPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _oldPasswordVisible = !_oldPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Contraseña nueva',
              isVisible: _newPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _newPasswordVisible = !_newPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _repeatPasswordController,
              label: 'Repetir contraseña nueva',
              isVisible: _repeatPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _repeatPasswordVisible = !_repeatPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: AppTheme.botonFuncional(),
              onPressed: _cambiarContrasena,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 217, 227, 251),
        labelText: label,
        floatingLabelBehavior:
            FloatingLabelBehavior.auto, // Activa el floating label
        labelStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        hintText: label,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 83, 82, 82)),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
