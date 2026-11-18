// Actividad 2 · Agitar para deshacer.
// Al agitar el móvil se recupera la última nota borrada. El gesto es opcional
// y siempre tiene alternativa táctil (botón «Deshacer» del SnackBar).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'detector_agitado.dart';

void main() => runApp(const MaterialApp(home: NotasGestos()));

// Cada nota lleva un id para que la key del Dismissible sea única
// aunque haya dos notas con el mismo texto.
class Nota {
  Nota(this.id, this.texto);
  final int id;
  final String texto;
}

class NotasGestos extends StatefulWidget {
  const NotasGestos({super.key});

  @override
  State<NotasGestos> createState() => _NotasGestosState();
}

class _NotasGestosState extends State<NotasGestos> {
  final List<Nota> _notas = [];
  final _controlador = TextEditingController();
  final _detector = DetectorAgitado();
  int _siguienteId = 0;

  // Última nota borrada y su posición, para poder deshacer.
  Nota? _notaBorrada;
  int? _posicionBorrada;

  StreamSubscription<UserAccelerometerEvent>? _suscripcion;

  @override
  void initState() {
    super.initState();
    // userAccelerometer mide la aceleración SIN la gravedad.
    _suscripcion = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((evento) {
      if (_detector.procesar(evento.x, evento.y, evento.z, DateTime.now())) {
        _recuperar(alAgitar: true);
      }
    });
  }

  void _anadir() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    setState(() => _notas.add(Nota(_siguienteId++, texto)));
    _controlador.clear();
  }

  void _borrar(int index) {
    setState(() {
      _notaBorrada = _notas.removeAt(index);
      _posicionBorrada = index;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nota borrada'),
        action: SnackBarAction(label: 'Deshacer', onPressed: _recuperar),
      ),
    );
  }

  void _recuperar({bool alAgitar = false}) {
    final nota = _notaBorrada;
    if (nota == null) return; // nada que deshacer: la sacudida no hace nada
    setState(() {
      // Por si la lista ha cambiado, no me paso del final.
      final guardada = _posicionBorrada!;
      final posicion = guardada <= _notas.length ? guardada : _notas.length;
      _notas.insert(posicion, nota);
      _notaBorrada = null;
      _posicionBorrada = null;
    });
    if (alAgitar) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota recuperada al agitar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlador,
                    decoration: const InputDecoration(labelText: 'Nueva nota'),
                    onSubmitted: (_) => _anadir(),
                  ),
                ),
                IconButton(
                  tooltip: 'Añadir nota',
                  icon: const Icon(Icons.add),
                  onPressed: _anadir,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                final nota = _notas[index];
                return Dismissible(
                  key: ValueKey(nota.id), // la key sale del dato, no del índice
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _borrar(index),
                  child: ListTile(
                    title: Text(nota.texto),
                    trailing: IconButton(
                      tooltip: 'Borrar nota',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _borrar(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
