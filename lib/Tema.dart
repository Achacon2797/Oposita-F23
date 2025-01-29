class Tema {
  final int id;
  final String titulo; // Titulo definido en el JSON
  final String ntema; // Tema dinámico

  Tema({required this.id, required this.titulo})
      : ntema = 'Tema $id'; // ntema se genera dinamicamente

  factory Tema.fromJson(Map<String, dynamic> json) {
    return Tema(
      id: json['id'], // Obtenemos el id del json.
      titulo: json['titulo'], // Obtenemos el título del json.
    );
  }
}
