// Ampliación: detecta si el móvil se inclina a la izquierda o a la derecha
// con el eje x del acelerómetro (accelerometerEventStream, que SÍ incluye
// la gravedad). Es Dart puro para poder probarlo con tests.
//
// Con el móvil de pie y recto, x vale casi 0. Si bajas el lado izquierdo,
// x se hace positivo; si bajas el derecho, se hace negativo (hasta 9,8).

enum Inclinacion { ninguna, izquierda, derecha }

class DetectorInclinacion {
  DetectorInclinacion({this.umbral = 5});

  final double umbral; // m/s² en el eje x para contar como inclinado

  // Tras una inclinación espero a que el móvil vuelva al centro,
  // así mantenerlo inclinado cuenta una sola vez.
  bool _esperandoCentro = false;

  Inclinacion procesar(double x) {
    if (_esperandoCentro) {
      // Vuelve a estar «recto» cuando x baja de la mitad del umbral.
      if (x.abs() < umbral / 2) _esperandoCentro = false;
      return Inclinacion.ninguna;
    }

    if (x > umbral) {
      _esperandoCentro = true;
      return Inclinacion.izquierda;
    }
    if (x < -umbral) {
      _esperandoCentro = true;
      return Inclinacion.derecha;
    }
    return Inclinacion.ninguna;
  }
}
