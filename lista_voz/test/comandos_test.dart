import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  test('no distingue mayúsculas ni tildes', () {
    expect(interpretarComando('Añade'), Comando.anadir);
    expect(interpretarComando('anade'), Comando.anadir);
    expect(interpretarComando('AÑADIR'), Comando.anadir);
  });

  test('sinónimos de añadir', () {
    expect(interpretarComando('nuevo'), Comando.anadir);
    expect(interpretarComando('crear'), Comando.anadir);
  });

  test('sinónimos de borrar', () {
    for (final palabra in ['borrar', 'borra', 'eliminar', 'quitar']) {
      expect(interpretarComando(palabra), Comando.borrar);
    }
  });

  test('sinónimos de leer', () {
    for (final palabra in ['leer', 'lee', 'cuántos', 'lista']) {
      expect(interpretarComando(palabra), Comando.leer);
    }
  });

  test('sinónimos de ayuda', () {
    expect(interpretarComando('ayuda'), Comando.ayuda);
    expect(interpretarComando('Comandos'), Comando.ayuda);
  });

  test('reconoce la orden dentro de una frase', () {
    expect(interpretarComando('por favor añade uno'), Comando.anadir);
    expect(interpretarComando('¿Cuántos hay?'), Comando.leer);
  });

  test('texto vacío es desconocido', () {
    expect(interpretarComando(''), Comando.desconocido);
  });

  test('cualquier otra cosa es desconocido', () {
    expect(interpretarComando('hola'), Comando.desconocido);
    expect(interpretarComando('buenos días'), Comando.desconocido);
  });
}
