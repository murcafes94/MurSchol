# MurSchol Media — visión y arquitectura

MurSchol Media será el reproductor local de vídeo y audio de MurSchol OS. La prioridad es abrir archivos rápidamente y reproducirlos sin obligar al usuario a cargar una biblioteca multimedia completa.

## Principios

1. **Abrir primero, cargar después**
   - Doble clic en un archivo → reproducción inmediata.
   - No hay indexación obligatoria antes de reproducir.
   - Los archivos vecinos de la carpeta se detectan después para anterior/siguiente.
   - La posición se guarda localmente para continuar más tarde.

2. **Una sola aplicación visible**
   - Vídeo y audio comparten el mismo ejecutable `murschol-media`.
   - La interfaz cambia automáticamente según el tipo de archivo.
   - El usuario no necesita conocer el motor interno.

3. **Motor maduro, interfaz MurSchol**
   - Motor inicial: **libmpv/mpv**.
   - MurSchol controla la interfaz, navegación, atajos y estado.
   - mpv controla decodificación, códecs, pistas, subtítulos y aceleración compatible.

4. **Controles discretos**
   - En vídeo, las barras superior e inferior se ocultan cuando no se usan.
   - En audio, los controles permanecen visibles con una interfaz centrada.
   - Ajustes secundarios aparecen solo bajo demanda.

## Formatos objetivo iniciales

### Vídeo
- MP4
- MKV
- WebM
- MOV
- AVI
- M4V
- MPEG/MPG
- TS/M2TS

### Audio
- MP3
- FLAC
- WAV
- OGG/OGA
- Opus
- M4A
- AAC
- WMA

La compatibilidad real depende de la compilación de mpv/FFmpeg presente en MurSchol OS.

## Funciones 0.1

- apertura directa desde argumento de línea de comandos;
- arrastrar un archivo sobre la ventana;
- reproducir/pausar;
- avanzar y retroceder 10 segundos;
- buscar una posición exacta en la línea de tiempo;
- volumen;
- velocidad de reproducción;
- pantalla completa;
- cambiar pista de audio;
- cambiar pista de subtítulos;
- anterior/siguiente dentro de la carpeta actual;
- recordar posición por archivo;
- controles auto-ocultables en vídeo;
- interfaz específica para audio.

## Próximas fases

### 0.2
- mostrar nombre real de pista de audio y subtítulos;
- selector completo de pistas en vez de solo ciclo;
- cargar subtítulos externos `.srt`, `.ass`, `.vtt`;
- controles de relación de aspecto y ajuste de vídeo;
- modo siempre visible / mini reproductor;
- manejo claro de fin de reproducción;
- restauración de velocidad por archivo si se desea;
- metadatos y portada embebida para audio.

### 0.3
- cola de reproducción;
- listas `.m3u/.m3u8`;
- historial reciente;
- capítulos;
- Picture-in-Picture si la arquitectura Wayland lo permite correctamente;
- mejor integración con teclas multimedia MPRIS;
- integración con MurSchol Files para asociaciones de formatos.

### Futuro
- biblioteca musical opcional;
- listas de reproducción persistentes;
- artistas, álbumes y portadas;
- búsqueda local de música;
- estudiar un servicio musical propio tipo Spotify, separado del reproductor local.

## Rendimiento

- `hwdec=auto-safe` permite a mpv usar aceleración de vídeo cuando el sistema la soporta de forma segura.
- El reproductor no escanea toda la biblioteca antes de abrir un archivo.
- El sondeo de estado se mantiene ligero y desacoplado del renderizado.
- En equipos modestos se prioriza la reproducción sobre animaciones de interfaz.

## Aplicaciones avanzadas

VLC puede mantenerse disponible como aplicación opcional para usuarios que necesiten funciones especializadas. MurSchol Media será el reproductor predeterminado para el uso cotidiano.
