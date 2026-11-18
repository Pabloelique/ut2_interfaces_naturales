// Actividad 1 · Lista controlada por voz.
// Pulsas el micrófono, dices una orden y la app la ejecuta y responde hablando.
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'comandos.dart';

void main() => runApp(const MaterialApp(home: ListaVoz()));

class ListaVoz extends StatefulWidget {
  const ListaVoz({super.key});

  @override
  State<ListaVoz> createState() => _ListaVozState();
}

class _ListaVozState extends State<ListaVoz> {
  final SpeechToText _voz = SpeechToText(); // reconocimiento (voz -> texto)
  final FlutterTts _tts = FlutterTts(); // síntesis (texto -> voz)
  final List<String> _elementos = [];

  bool _vozDisponible = false;
  String _transcripcion = '';

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  Future<void> _iniciarVoz() async {
    await _tts.setLanguage('es-ES');
    final disponible = await _voz.initialize();
    if (!mounted) return;
    setState(() => _vozDisponible = disponible);
  }

  Future<void> _pulsarMicrofono() async {
    setState(() => _transcripcion = '');
    await _voz.listen(
      onResult: _alResultado,
      localeId: 'es_ES',
      listenFor: const Duration(seconds: 5), // máximo 5 segundos
    );
  }

  void _alResultado(SpeechRecognitionResult resultado) {
    // Mientras se habla, se va mostrando lo que se oye.
    setState(() => _transcripcion = resultado.recognizedWords);
    // Solo cuando el resultado es final se ejecuta la orden.
    if (resultado.finalResult) {
      _ejecutar(interpretarComando(resultado.recognizedWords));
    }
  }

  void _ejecutar(Comando comando) {
    switch (comando) {
      case Comando.anadir:
        final numero = _elementos.length + 1;
        setState(() => _elementos.add('Elemento $numero'));
        _hablar('Añadido el elemento $numero');
      case Comando.borrar:
        if (_elementos.isEmpty) {
          _hablar('La lista está vacía');
        } else {
          final numero = _elementos.length;
          setState(() => _elementos.removeLast());
          _hablar('Borrado el elemento $numero');
        }
      case Comando.leer:
        final total = _elementos.length;
        _hablar(total == 1 ? 'Hay 1 elemento' : 'Hay $total elementos');
      case Comando.ayuda:
        _hablar('Puedes decir: añadir, borrar, leer o ayuda.');
      case Comando.desconocido:
        break; // TODO: avisar al usuario
    }
  }

  Future<void> _hablar(String texto) async {
    await _tts.stop(); // corta la frase anterior si aún estaba hablando
    await _tts.speak(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista por voz')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _transcripcion.isEmpty ? '-' : _transcripcion,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _elementos.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(_elementos[index]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Pulsar y decir una orden',
        onPressed: _vozDisponible ? _pulsarMicrofono : null,
        child: const Icon(Icons.mic_none),
      ),
    );
  }
}
