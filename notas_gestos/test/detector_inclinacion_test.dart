import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_inclinacion.dart';

void main() {
  test('con el móvil recto no detecta nada', () {
    final detector = DetectorInclinacion();
    expect(detector.procesar(0), Inclinacion.ninguna);
    expect(detector.procesar(2), Inclinacion.ninguna); // un poco torcido
    expect(detector.procesar(-2), Inclinacion.ninguna);
  });

  test('x positivo por encima del umbral es izquierda', () {
    final detector = DetectorInclinacion();
    expect(detector.procesar(7), Inclinacion.izquierda);
  });

  test('x negativo por debajo de -umbral es derecha', () {
    final detector = DetectorInclinacion();
    expect(detector.procesar(-7), Inclinacion.derecha);
  });

  test('mantenerlo inclinado cuenta una sola vez', () {
    final detector = DetectorInclinacion();
    expect(detector.procesar(7), Inclinacion.izquierda);
    expect(detector.procesar(8), Inclinacion.ninguna);
    expect(detector.procesar(7), Inclinacion.ninguna);
  });

  test('después de volver al centro detecta otra vez', () {
    final detector = DetectorInclinacion();
    expect(detector.procesar(7), Inclinacion.izquierda);
    expect(detector.procesar(1), Inclinacion.ninguna); // vuelve al centro
    expect(detector.procesar(-7), Inclinacion.derecha);
  });

  test('respeta un umbral distinto', () {
    final detector = DetectorInclinacion(umbral: 8);
    expect(detector.procesar(7), Inclinacion.ninguna); // 7 < 8
    expect(detector.procesar(9), Inclinacion.izquierda);
  });
}
