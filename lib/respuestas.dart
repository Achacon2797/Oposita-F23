class Respuesta {
  final String texto;
  final bool correcta;

  Respuesta(this.texto, this.correcta);

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(json['texto'], json['correcta']);
  }
}
