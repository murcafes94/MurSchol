# MurSchol OS — Checklist de prueba en VirtualBox

Esta lista sirve para validar la alpha de MurSchol OS de forma rápida y repetible. El objetivo no es probar cada función extrema, sino detectar bloqueos, regresiones visuales y backends que no estén respondiendo dentro de la sesión Live.

## Configuración de VirtualBox

- RAM: 4096 MB.
- CPU: 2 vCPU.
- Vídeo: VMSVGA.
- Memoria de vídeo: 128 MB.
- Aceleración 3D: desactivada.
- Disco virtual: 20 GB o más si se usa uno.
- Arranque desde la ISO Live más reciente.

## 1. Arranque

- [ ] La ISO llega a LightDM sin quedarse en pantalla negra.
- [ ] La sesión Live inicia automáticamente.
- [ ] Aparece MurSchol Desktop.
- [ ] No hay ventanas de error al iniciar.
- [ ] Barra superior y dock se dibujan correctamente.

## 2. Dock global

- [ ] El dock aparece en la zona inferior central.
- [ ] El auto-ocultado funciona.
- [ ] Llevar el cursor al borde inferior vuelve a mostrarlo.
- [ ] Inicio abre correctamente.
- [ ] Archivos abre MurSchol Files.
- [ ] Configuración abre MurSchol Settings.
- [ ] Navegador abre Firefox/Edge según disponibilidad.
- [ ] Cambiar el tamaño del dock en Settings se refleja sin reiniciar sesión.
- [ ] Cambiar Ligero / Normal / Rendimiento se refleja en el shell según lo actualmente implementado.

## 3. MurSchol Settings

### Apariencia

- [ ] Claro/Oscuro/Automático cambian la interfaz de Settings.
- [ ] El color de énfasis cambia.
- [ ] Animaciones Normal/Reducidas/Desactivadas guardan estado.

### Red e Internet

- [ ] NetworkManager aparece disponible.
- [ ] Si existe Wi-Fi virtual/físico, el adaptador aparece.
- [ ] Buscar redes no bloquea Settings.
- [ ] Las redes guardadas se muestran cuando existen.
- [ ] Conectar/desconectar una red guardada no cierra Settings.

Nota: VirtualBox normalmente presenta Ethernet virtual y puede no exponer un adaptador Wi-Fi real.

### Sonido

- [ ] WirePlumber/PipeWire aparecen disponibles.
- [ ] Se detecta al menos una salida virtual cuando VirtualBox ofrece audio.
- [ ] El deslizador de salida responde.
- [ ] Silenciar/activar salida responde.
- [ ] La entrada/micrófono se muestra solo si existe.
- [ ] `Abrir avanzado` abre pavucontrol.

### Bluetooth

- [ ] Settings no falla si VirtualBox no expone Bluetooth.
- [ ] En hardware con Bluetooth, BlueZ detecta adaptador.
- [ ] Encender/apagar Bluetooth responde.
- [ ] Buscar dispositivos no bloquea la interfaz.
- [ ] Dispositivos ya emparejados pueden conectarse/desconectarse.

### Energía

- [ ] En VirtualBox, la ausencia de batería se muestra de forma normal y no como error.
- [ ] En portátil real, UPower muestra porcentaje y estado.
- [ ] El brillo aparece únicamente si `brightnessctl` detecta un dispositivo compatible.
- [ ] `Suspender ahora` solicita suspensión mediante logind.

### Pantalla

- [ ] Se detecta la pantalla virtual y su resolución.
- [ ] Se muestra frecuencia y escala detectadas.
- [ ] Brillo aparece solo si el hardware lo permite.
- [ ] Luz nocturna aparece disponible cuando Gammastep está instalado.
- [ ] Activar Luz nocturna cambia la temperatura si el compositor/driver admite control gamma.
- [ ] Desactivar Luz nocturna restablece la temperatura.
- [ ] Presets Suave/Nocturno responden sin bloquear Settings.

## 4. MurSchol Files

- [ ] Abre desde el dock.
- [ ] Inicio/Documentos/Descargas/Imágenes/Música/Vídeos navegan.
- [ ] Lista y cuadrícula funcionan.
- [ ] Crear carpeta funciona.
- [ ] Abrir un archivo usa su asociación.
- [ ] Buscar dentro de la carpeta actual no congela la interfaz.

## 5. Capture + Photos

- [ ] `Print Screen` crea captura completa.
- [ ] `Super + Shift + S` permite elegir región.
- [ ] La captura se guarda en Imágenes/Capturas de pantalla.
- [ ] La captura puede pegarse desde el portapapeles.
- [ ] `Editar` abre MurSchol Photos en modo anotación.
- [ ] Lápiz, resaltador, flecha, rectángulo, texto y ocultación se dibujan.
- [ ] Deshacer/rehacer funciona para anotaciones.

## 6. Ventanas y teclado

- [ ] Alt+Tab cambia entre ventanas.
- [ ] Alt+F4 cierra una aplicación normal.
- [ ] Super+flechas usa las acciones de labwc previstas.
- [ ] Super+Space abre la búsqueda/acción configurada cuando corresponda.

## 7. Información que conviene enviar al detectar un fallo

1. Captura de pantalla del fallo.
2. Qué botón/acción se pulsó justo antes.
3. Si el fallo ocurre siempre o solo una vez.
4. Si la app se cerró o solo dejó de responder.
5. En caso del panel global: contenido de `~/murschol-panel.log` si existe.

## Criterio de aprobación de una alpha

Una ISO puede considerarse apta para seguir probando cuando:

- arranca de forma reproducible;
- shell, dock, Settings y Files se abren;
- los backends ausentes fallan de forma segura, sin controles ficticios ni cierres;
- no hay regresiones graves de navegación;
- los fallos restantes están limitados a funciones todavía marcadas como experimentales o pendientes de hardware real.
