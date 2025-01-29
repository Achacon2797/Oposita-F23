import 'respuestas.dart'; // Asegúrate de que la ruta es correcta

class Pregunta {
  final String pregunta;
  final List<Respuesta> respuestas;

  Pregunta(this.pregunta, this.respuestas);

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    var list = json['respuestas'] as List;
    List<Respuesta> respuestasList =
        list.map((i) => Respuesta.fromJson(i)).toList();

    return Pregunta(json['pregunta'], respuestasList);
  }
}
