// Detecta una sacudida a partir de las lecturas del acelerómetro.
// Es Dart puro: el instante llega como parámetro para poder probar la pausa
// en los tests sin tener que esperar de verdad.
import 'dart:math';

class DetectorAgitado {
  DetectorAgitado({this.umbral = 15, this.pausa = const Duration(seconds: 1)});

  final double umbral; // m/s² a partir de los que cuenta como sacudida
  final Duration pausa; // tiempo que se ignoran lecturas tras una sacudida

  DateTime? _ultimaSacudida;

  bool procesar(double x, double y, double z, DateTime instante) {
    // Durante la pausa no cuento nada: un solo gesto no vale por dos.
    final ultima = _ultimaSacudida;
    if (ultima != null && instante.difference(ultima) < pausa) return false;

    final modulo = sqrt(x * x + y * y + z * z);
    if (modulo > umbral) {
      _ultimaSacudida = instante;
      return true;
    }
    return false;
  }
}
