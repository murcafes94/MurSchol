# MurSchol OS — Informe de prueba ISO #105

Fecha de prueba: 2026-09-06 (Ecuador)
Entorno: Oracle VirtualBox, sesión Live MurSchol OS 0.1

## Confirmado visualmente / por grabación

- [x] La ISO arranca y entra al escritorio MurSchol.
- [x] La barra superior se dibuja correctamente.
- [x] MurSchol Files abre desde el entorno.
- [x] El panel/dock global aparece sobre MurSchol Files y puede volver a ocultarse.
- [x] Inicio abre sobre una aplicación sin reemplazarla.
- [x] El menú Inicio enumera aplicaciones reales instaladas.
- [x] MurSchol Files navega por Inicio e Imágenes.
- [x] MurSchol Capture creó al menos una captura PNG dentro de la carpeta de capturas.

## Incidencias detectadas

### Carpetas XDG incompletas

En la Live ISO #105 existían `Downloads` y `Pictures`, pero faltaban rutas estándar como `/home/user/Documents`. Al pulsar el acceso Documentos, MurSchol Files mostraba:

`La carpeta no existe: /home/user/Documents`

Corrección aplicada después de esta prueba:

- inicializar `user-dirs.dirs` antes de arrancar la sesión;
- crear Documentos, Descargas, Imágenes, Música, Vídeos y Escritorio;
- usar nombres coherentes en español para la alpha;
- incluir `xdg-user-dirs` en la Live ISO.

La corrección debe validarse en una ISO posterior a la #105.

## Rendimiento observado desde VirtualBox

VirtualBox mostró carga del invitado cercana a 0 % en el instante de la captura, mientras la carga del VMM rondaba 47 %. Esto no se interpreta como 47 % de CPU consumida por MurSchol: una parte importante corresponde al hipervisor/renderizado del host. La alpha fuerza Pixman/Qt Quick software en VirtualBox para evitar pantalla negra con la aceleración 3D desactivada.

La métrica de RAM del panel de VirtualBox no estaba disponible porque requiere Guest Additions. Por tanto, el consumo real de RAM debe comprobarse dentro del invitado (`/proc/meminfo`, Settings/System Center) y no inferirse de esa pantalla de VirtualBox.

## Pendiente inmediato

- [ ] Settings → Apariencia y Dock.
- [ ] Settings → Red e Internet.
- [ ] Settings → Sonido.
- [ ] Settings → Bluetooth.
- [ ] Validar `Super + Shift + S` para captura de región.
- [ ] Validar edición de captura en MurSchol Photos.
- [ ] Validar Alt+Tab y Super+flechas con varias ventanas.
- [ ] Medir RAM/CPU dentro del invitado durante reposo y con Files abierto.
