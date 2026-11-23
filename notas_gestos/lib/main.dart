// Actividad 2 · Agitar para deshacer.
// Al agitar el móvil se recupera la última nota borrada. El gesto es opcional
// y siempre tiene alternativa táctil (botón «Deshacer» del SnackBar).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'detector_agitado.dart';
import 'detector_inclinacion.dart';

// Color de la app: verde oliva. Como en el ejemplo 13, con la semilla
// Flutter saca todos los colores (botones, interruptores, etc.).
const colorApp = Color(0xFF6B8E23);

void main() => runApp(
  MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: colorApp)),
    home: const NotasGestos(),
  ),
);

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

  bool _agitarActivo = true;
  bool _hayAcelerometro = true;
  StreamSubscription<UserAccelerometerEvent>? _suscripcion;

  // Ampliación: pestaña elegida en la NavigationBar (0 = Notas, 1 = Papelera).
  int _pestana = 0;
  // Notas borradas, que se ven en la pestaña Papelera.
  final List<Nota> _papelera = [];
  // Inclinar el móvil para cambiar de pestaña.
  final _detectorInclinacion = DetectorInclinacion();
  bool _inclinarActivo = true;
  StreamSubscription<AccelerometerEvent>? _suscripcionInclinacion;

  @override
  void initState() {
    super.initState();
    _activarSensor();
    _activarInclinacion();
  }

  void _activarInclinacion() {
    // accelerometer SÍ incluye la gravedad: con el móvil de pie, al inclinarlo
    // a un lado la gravedad «cae» sobre el eje x.
    try {
      _suscripcionInclinacion =
          accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
              .listen(
                (evento) {
                  final inclinacion = _detectorInclinacion.procesar(evento.x);
                  // Izquierda = pestaña de la izquierda (Notas), derecha = Papelera.
                  if (inclinacion == Inclinacion.izquierda) {
                    setState(() => _pestana = 0);
                  } else if (inclinacion == Inclinacion.derecha) {
                    setState(() => _pestana = 1);
                  }
                },
                onError: (_) => _desactivarInclinacion(), // sin acelerómetro
                cancelOnError: true,
              );
    } catch (_) {
      _desactivarInclinacion();
    }
  }

  void _desactivarInclinacion() {
    _suscripcionInclinacion?.cancel();
    _suscripcionInclinacion = null;
  }

  void _activarSensor() {
    // userAccelerometer mide la aceleración SIN la gravedad.
    try {
      _suscripcion =
          userAccelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          ).listen(
            (evento) {
              if (_detector.procesar(
                evento.x,
                evento.y,
                evento.z,
                DateTime.now(),
              )) {
                _recuperar(alAgitar: true);
              }
            },
            onError: (_) => _sinSensor(), // por ejemplo, en escritorio
            cancelOnError: true,
          );
    } catch (_) {
      // Algunas plataformas fallan al crear el flujo en vez de dar error en él.
      WidgetsBinding.instance.addPostFrameCallback((_) => _sinSensor());
    }
  }

  void _desactivarSensor() {
    _suscripcion?.cancel();
    _suscripcion = null;
  }

  void _sinSensor() {
    _desactivarSensor();
    if (!mounted) return;
    setState(() {
      _agitarActivo = false;
      _hayAcelerometro = false;
    });
    _mostrarMensaje('Este dispositivo no tiene acelerómetro');
  }

  void _cambiarInclinar(bool activo) {
    setState(() => _inclinarActivo = activo);
    // Igual que agitar: desactivado, no se escucha el sensor (WCAG 2.5.4).
    activo ? _activarInclinacion() : _desactivarInclinacion();
  }

  void _cambiarAgitar(bool activo) {
    setState(() => _agitarActivo = activo);
    // Desactivado, la app deja de escuchar el sensor.
    activo ? _activarSensor() : _desactivarSensor();
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
      _papelera.add(_notaBorrada!); // va a la papelera
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
      _papelera.remove(nota); // si se recupera, sale de la papelera
      _notaBorrada = null;
      _posicionBorrada = null;
    });
    if (alAgitar) _mostrarMensaje('Nota recuperada al agitar');
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  void dispose() {
    _desactivarSensor(); // cancelo la suscripción al sensor
    _desactivarInclinacion(); // y la de inclinar
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Notas'),
        actions: [
          // Feedback: indica si el gesto está activo.
          Tooltip(
            message: _agitarActivo
                ? 'Agitar para deshacer: activado'
                : 'Agitar para deshacer: desactivado',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                _agitarActivo ? Icons.vibration : Icons.mobile_off,
                color: _agitarActivo ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: _pestana == 1
          ? _pantallaPapelera()
          : Column(
              children: [
                SwitchListTile(
                  title: const Text('Agitar para deshacer'),
                  subtitle: Text(
                    _hayAcelerometro
                        ? 'Agita el móvil para recuperar la última nota borrada'
                        : 'Este dispositivo no tiene acelerómetro',
                  ),
                  value: _agitarActivo,
                  // Sin acelerómetro el interruptor queda deshabilitado.
                  onChanged: _hayAcelerometro ? _cambiarAgitar : null,
                ),
                SwitchListTile(
                  title: const Text('Inclinar para cambiar de pestaña'),
                  subtitle: const Text(
                    'Inclina a la izquierda para Notas y a la derecha para Papelera',
                  ),
                  value: _inclinarActivo && _hayAcelerometro,
                  onChanged: _hayAcelerometro ? _cambiarInclinar : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controlador,
                          decoration: const InputDecoration(
                            labelText: 'Nueva nota',
                          ),
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
                        key: ValueKey(
                          nota.id,
                        ), // la key sale del dato, no del índice
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (indice) => setState(() => _pestana = indice),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Notas'),
          NavigationDestination(icon: Icon(Icons.delete), label: 'Papelera'),
        ],
      ),
    );
  }

  // Pestaña Papelera.
  Widget _pantallaPapelera() {
    if (_papelera.isEmpty) {
      return const Center(child: Text('La papelera está vacía'));
    }
    return ListView.builder(
      itemCount: _papelera.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.delete_outline),
        title: Text(_papelera[index].texto),
      ),
    );
  }
}
