// tema_stats.dart
class TemaStats {
  bool temaIniciado = false;
  List<bool> respuestasCorrectas = [];
  int vecesRealizado = 0;

  TemaStats();

  TemaStats.fromJson(Map<String, dynamic> json)
      : temaIniciado = json['temaIniciado'] ?? false,
        respuestasCorrectas =
            List<bool>.from(json['respuestasCorrectas'] ?? []),
        vecesRealizado = json['vecesRealizado'] ?? 0;

  Map<String, dynamic> toJson() => {
        'temaIniciado': temaIniciado,
        'respuestasCorrectas': respuestasCorrectas,
        'vecesRealizado': vecesRealizado,
      };

  void resetRespuestas(int cantidadPreguntas) {
    respuestasCorrectas = List<bool>.filled(cantidadPreguntas, false);
  }

  bool todasRespuestasCorrectas() {
    return respuestasCorrectas.isNotEmpty &&
        respuestasCorrectas.every((resp) => resp == true);
  }

  void incrementarVecesRealizado() {
    vecesRealizado++;
  }
}
