// Actividad 1 · Lista controlada por voz.
// Pulsas el micrófono, dices una orden y la app la ejecuta y responde hablando.
// Todo lo que se hace con la voz también se puede hacer con botones.
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
  bool _escuchando = false;
  String _transcripcion = '';
  String _ultimaOrden = '-';
  String _motivoSinVoz = 'Comprobando el micrófono...';

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  Future<void> _iniciarVoz() async {
    await _tts.setLanguage('es-ES');

    bool disponible = false;
    try {
      disponible = await _voz.initialize(
        onStatus: _alCambiarEstado,
        onError: (_) {
          if (mounted) setState(() => _escuchando = false);
        },
      );
    } catch (_) {
      disponible = false; // por ejemplo, en una plataforma sin servicio de voz
    }

    // Si no está disponible, intento explicar el motivo.
    String motivo = '';
    if (!disponible) {
      bool tienePermiso = false;
      try {
        tienePermiso = await _voz.hasPermission;
      } catch (_) {}
      motivo = tienePermiso
          ? 'Este dispositivo no tiene servicio de reconocimiento de voz. Usa los botones.'
          : 'No hay permiso para usar el micrófono. Usa los botones o dale permiso en Ajustes.';
    }

    if (!mounted) return;
    setState(() {
      _vozDisponible = disponible;
      _motivoSinVoz = motivo;
    });
  }

  // El plugin avisa cuando deja de escuchar (al acabar los 5 s o al callarse).
  void _alCambiarEstado(String estado) {
    if (!mounted) return;
    if (estado == 'done' || estado == 'notListening') {
      setState(() => _escuchando = false);
    }
  }

  Future<void> _pulsarMicrofono() async {
    if (_escuchando) {
      await _voz.stop();
      setState(() => _escuchando = false);
      return;
    }
    setState(() {
      _escuchando = true;
      _transcripcion = '';
    });
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
      _ejecutar(interpretarComando(resultado.recognizedWords),
          oido: resultado.recognizedWords);
    }
  }

  // La usan tanto la voz como los botones, así las dos vías hacen lo mismo.
  void _ejecutar(Comando comando, {String oido = ''}) {
    setState(() => _ultimaOrden = comando.name);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No he entendido «$oido». Di «ayuda» para oír las órdenes'),
          ),
        );
    }
  }

  Future<void> _hablar(String texto) async {
    await _tts.stop(); // corta la frase anterior si aún estaba hablando
    await _tts.speak(texto);
  }

  @override
  void dispose() {
    // Libero los recursos: paro el micrófono y la voz.
    _voz.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista por voz'),
        actions: [
          IconButton(
            tooltip: 'Oír las órdenes disponibles',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _ejecutar(Comando.ayuda),
          ),
        ],
      ),
      body: Column(
        // stretch: la tarjeta ocupa todo el ancho
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feedback: lo que se está oyendo y la última orden reconocida.
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_escuchando ? 'Escuchando...' : 'Transcripción:'),
                  Text(
                    _transcripcion.isEmpty ? '-' : _transcripcion,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text('Última orden: $_ultimaOrden'),
                  // Si no hay voz, se explica por qué.
                  if (!_vozDisponible)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _motivoSinVoz,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _elementos.isEmpty
                ? const Center(child: Text('La lista está vacía'))
                : ListView.builder(
                    itemCount: _elementos.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(_elementos[index]),
                    ),
                  ),
          ),
          // Alternativa táctil: los mismos comandos con botones.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 110),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () => _ejecutar(Comando.anadir),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
                FilledButton.icon(
                  onPressed: () => _ejecutar(Comando.borrar),
                  icon: const Icon(Icons.remove),
                  label: const Text('Borrar'),
                ),
                FilledButton.icon(
                  onPressed: () => _ejecutar(Comando.leer),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Leer'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: !_vozDisponible
            ? 'Micrófono no disponible'
            : _escuchando
                ? 'Dejar de escuchar'
                : 'Pulsar y decir una orden',
        // null deshabilita el botón, como en el ejemplo 05 del contador
        onPressed: _vozDisponible ? _pulsarMicrofono : null,
        // Cambia de color e icono mientras escucha.
        backgroundColor: !_vozDisponible
            ? Colors.grey
            : _escuchando
                ? Colors.red
                : null,
        child: Icon(_escuchando ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
