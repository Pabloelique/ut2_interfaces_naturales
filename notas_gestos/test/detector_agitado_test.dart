import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  final inicio = DateTime(2026, 11, 18, 10, 0, 0);

  test('en reposo no detecta nada', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(0, 0, 0, inicio), isFalse);
    expect(detector.procesar(1, 2, 1, inicio), isFalse); // movimiento suave
  });

  test('detecta una sacudida que supera el umbral', () {
    final detector = DetectorAgitado();
    // √(12² + 10² + 5²) ≈ 16,4 > 15
    expect(detector.procesar(12, 10, 5, inicio), isTrue);
  });

  test('ignora una segunda sacudida dentro de la pausa', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(20, 0, 0, inicio), isTrue);
    final dentro = inicio.add(const Duration(milliseconds: 500));
    expect(detector.procesar(20, 0, 0, dentro), isFalse);
  });

  test('detecta otra sacudida pasada la pausa', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(20, 0, 0, inicio), isTrue);
    final despues = inicio.add(const Duration(milliseconds: 1100));
    expect(detector.procesar(20, 0, 0, despues), isTrue);
  });

  test('respeta un umbral distinto', () {
    final detector = DetectorAgitado(umbral: 25);
    expect(detector.procesar(20, 0, 0, inicio), isFalse); // 20 < 25
  });
}
