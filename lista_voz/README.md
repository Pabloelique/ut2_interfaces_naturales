# Actividad 1 · Lista controlada por voz

App Flutter con una lista que se maneja con la voz (añadir, borrar, leer, ayuda) y responde hablando. Todas las órdenes tienen también su botón.

## Ficheros
- `lib/comandos.dart`: enum `Comando` y `interpretarComando()` (Dart puro).
- `lib/main.dart`: pantalla, reconocimiento (`speech_to_text`) y síntesis (`flutter_tts`).
- `test/comandos_test.dart`: 8 pruebas unitarias del intérprete.

## Cómo probarlo
```bash
flutter test test/comandos_test.dart
flutter run
```

## Reflexión

### 1. ¿Reconocimiento en el dispositivo o en un servidor?
`speech_to_text` no reconoce la voz él mismo: en Android usa el servicio de reconocimiento del sistema (normalmente el de Google). Por eso hay que declarar `RecognitionService` en `<queries>` y el permiso de `INTERNET`.

**Prueba en modo avión:** <!-- RELLENAR: qué pasó en tu móvil (funcionó / dio error / no entendía) y el modelo de móvil -->

Según el resultado:
- **Privacidad:** si funciona sin red, el audio no sale del móvil. Si necesita red, la voz se envía a un servidor externo.
- **Coste:** el servicio del sistema no cuesta nada a la app. Con un servicio en la nube de pago sí habría coste por uso.
- **Latencia:** en local la respuesta no depende de la conexión. En servidor depende de la red y con mala cobertura tarda o falla.
- **Plataforma:** depende de cada móvil y de si tiene descargado el paquete de idioma sin conexión. En escritorio o en un móvil sin servicio de voz el micrófono no está disponible.

### 2. Situaciones en las que no se puede usar la voz
1. **Lugar con ruido o donde hay que estar en silencio** (clase, biblioteca, transporte público). La app tiene los botones Añadir, Borrar y Leer, que hacen lo mismo que la voz.
2. **Usuario con problemas de habla o sin permiso de micrófono / sin servicio de voz.** El micrófono sale deshabilitado (gris), con un texto que explica el motivo, y la app sigue funcionando con los botones.
