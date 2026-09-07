# MurSchol Sound — Sonido

La página **Sonido** de MurSchol Settings controla el audio del sistema sin mantener una segunda configuración paralela. PipeWire/WirePlumber siguen siendo la fuente de verdad.

## Arquitectura 0.1

```text
MurSchol Settings
      |
SoundBackend (Qt 6 / C++20)
      |
wpctl (WirePlumber)
      |
PipeWire
      |
altavoces / auriculares / micrófonos
```

Se utiliza `wpctl`, la herramienta de control de WirePlumber, para esta primera integración. Esto evita introducir un daemon propio o duplicar el estado de PipeWire. Más adelante puede sustituirse internamente por una integración directa con la API de PipeWire/WirePlumber sin cambiar la interfaz pública de Settings.

## Funciones implementadas

- Detectar si `wpctl`/WirePlumber está disponible.
- Leer volumen de la salida predeterminada.
- Silenciar/activar la salida.
- Leer volumen de la entrada predeterminada.
- Silenciar/activar el micrófono.
- Enumerar salidas de audio visibles por WirePlumber.
- Enumerar entradas de audio visibles por WirePlumber.
- Identificar la salida y entrada predeterminadas.
- Cambiar el dispositivo predeterminado mediante `wpctl set-default`.
- Refrescar el estado con un intervalo moderado mientras Settings está abierto.
- Mantener `pavucontrol` como respaldo para perfiles, puertos y mezcla avanzada.

## Límites actuales

La versión 0.1 no intenta controlar todavía:

- volumen por aplicación;
- perfiles HDMI/analógico/Bluetooth avanzados;
- selección de puertos;
- balance izquierda/derecha;
- monitorización de nivel de micrófono;
- efectos o ecualizador;
- cambio automático de ruta al conectar auriculares;
- eventos reactivos directos de PipeWire.

Estas funciones se añadirán solo cuando estén conectadas a estado real. No se mostrarán interruptores ficticios.

## Rendimiento

SoundBackend no permanece activo fuera de MurSchol Settings. La consulta periódica se limita a la ventana de configuración y usa un intervalo de cinco segundos. Los cambios de volumen y mute se envían inmediatamente a WirePlumber.

## Pruebas pendientes

Antes de dar la página por terminada hay que comprobar en ejecución real:

1. salida integrada de portátil/escritorio;
2. HDMI/DisplayPort;
3. auriculares USB;
4. micrófono interno y USB;
5. audio Bluetooth cuando BlueZ esté conectado;
6. comportamiento dentro de VirtualBox;
7. cambio de dispositivo mientras se reproduce audio.
