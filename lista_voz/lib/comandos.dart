// Interpreta el texto reconocido por voz y lo convierte en una orden.
// Es Dart puro (sin Flutter) para poder probarlo con pruebas unitarias.

enum Comando { anadir, borrar, leer, ayuda, desconocido }

// Palabras que activan cada orden, ya escritas sin tildes ni mayúsculas.
const Map<Comando, List<String>> _sinonimos = {
  Comando.anadir: ['anadir', 'anade', 'nuevo', 'crear'],
  Comando.borrar: ['borrar', 'borra', 'eliminar', 'quitar'],
  Comando.leer: ['leer', 'lee', 'cuantos', 'lista'],
  Comando.ayuda: ['ayuda', 'comandos'],
};

// Pasa a minúsculas y quita tildes y la ñ: «AÑADIR» -> «anadir».
String _normalizar(String texto) {
  const conTilde = 'áéíóúüñ';
  const sinTilde = 'aeiouun';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < conTilde.length; i++) {
    resultado = resultado.replaceAll(conTilde[i], sinTilde[i]);
  }
  return resultado;
}

Comando interpretarComando(String texto) {
  // Separo la frase en palabras para encontrar la orden dentro de ella:
  // «por favor añade uno» -> [por, favor, anade, uno].
  final palabras = _normalizar(texto).split(RegExp(r'[^a-z]+'));
  for (final palabra in palabras) {
    for (final entrada in _sinonimos.entries) {
      if (entrada.value.contains(palabra)) return entrada.key;
    }
  }
  return Comando.desconocido; // también para el texto vacío
}
