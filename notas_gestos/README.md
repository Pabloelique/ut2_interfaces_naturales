# Actividad 2 · Agitar para deshacer

App de notas: al borrar una nota sale «Nota borrada» con «Deshacer», y agitar el móvil también la recupera en su posición. El gesto se puede desactivar.

## Ficheros
- `lib/detector_agitado.dart`: clase `DetectorAgitado` (Dart puro).
- `lib/main.dart`: lista de notas, `Dismissible`, SnackBar y sensor (`sensors_plus`).
- `test/detector_agitado_test.dart`: 5 pruebas (reposo, sacudida, dentro de la pausa, pasada la pausa y otro umbral).

## Cómo probarlo
```bash
flutter test test/detector_agitado_test.dart
flutter run
```
En el emulador: *Extended controls › Virtual sensors* y mover el dispositivo virtual.

## Reflexión

### 1. Umbral elegido
| Umbral | Resultado caminando con el móvil en la mano |
|--------|---------------------------------------------|
| 10 m/s² | <!-- RELLENAR --> |
| 15 m/s² | <!-- RELLENAR --> |
| 25 m/s² | <!-- RELLENAR --> |

**Elijo:** <!-- RELLENAR: el umbral y por qué (un umbral bajo salta al caminar; uno alto obliga a agitar muy fuerte) -->

### 2. ¿Por qué `userAccelerometerEventStream` y no `accelerometerEventStream`?
`accelerometerEventStream` incluye la gravedad, así que con el móvil quieto encima de la mesa ya marca unos 9,8 m/s² (en el eje z). `userAccelerometerEventStream` resta la gravedad y en reposo da valores cercanos a 0, así que solo mide el movimiento que hace el usuario. Con el acelerómetro normal, el reposo ya estaría cerca del umbral y con un movimiento pequeño saltaría la sacudida sin querer.

### 3. Condiciones de WCAG 2.5.4 (Activación mediante movimiento) que cumple la app
1. **La función también se puede hacer con un componente de la interfaz:** deshacer está en el botón «Deshacer» del SnackBar, sin necesidad de agitar.
2. **La respuesta al movimiento se puede desactivar** para evitar activaciones accidentales: el interruptor «Agitar para deshacer» deja de escuchar el sensor.

## Capturas (emulador Android)
La sacudida se simuló con los sensores virtuales del emulador.

| Nota borrada (con Deshacer) | Nota recuperada al agitar |
|---|---|
| ![Borrada](capturas/nota_borrada.png) | ![Recuperada](capturas/recuperada_al_agitar.png) |
