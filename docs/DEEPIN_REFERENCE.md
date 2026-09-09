# Deepin como referencia para MurSchol

Deepin/DDE se adopta como **referencia de producto y pulido visual**, no como base técnica de MurSchol OS.

## Decisión

MurSchol mantiene su arquitectura propia:

- Debian 13 Stable minimal.
- Wayland + labwc/wlroots.
- Shell y aplicaciones propias en C++20 + Qt 6/QML.
- Integración progresiva con Linux nativo, Flatpak/AppImage, Waydroid y Wine/Bottles.

No se sustituirá labwc por DDE ni se copiará el stack completo de Deepin. La meta es estudiar patrones de UX, coherencia visual y organización de aplicaciones que puedan implementarse de forma ligera y compatible con la identidad de MurSchol.

## Qué sí tomamos como referencia

### 1. Coherencia de escritorio completa

Deepin destaca porque dock, centro de control, gestor de archivos y aplicaciones propias comparten lenguaje visual. MurSchol debe buscar la misma continuidad entre:

- Desktop/Shell.
- Dock/Panel.
- Start y búsqueda.
- Settings.
- Files.
- Photos.
- Capture.
- Reader.
- Media/Music.
- Calendar.
- Calculator.
- futura Store.

La coherencia vale más que añadir efectos aislados.

### 2. Settings como aplicación central del sistema

Deepin Control Center sirve de referencia para que MurSchol Settings sea el punto único para:

- pantalla;
- sonido;
- red;
- Bluetooth;
- energía;
- almacenamiento;
- personalización;
- aplicaciones;
- compatibilidad;
- hardware y rendimiento;
- actualizaciones;
- accesibilidad;
- información del sistema.

MurSchol conservará un panel rápido separado para acciones inmediatas, mientras Settings contiene la configuración completa.

### 3. Dock pulido, no recargado

Deepin Dock confirma el valor de un panel visualmente cuidado, con estados claros y comportamiento consistente. Para MurSchol se mantiene la dirección ya elegida:

- disposición centrada;
- auto-ocultamiento;
- revelado rápido desde el borde;
- indicadores de aplicaciones abiertas;
- activación de ventanas reales;
- tooltips;
- escala/magnificación opcional;
- accesos rápidos y área de sistema discretos.

La implementación debe seguir siendo propia y ligera.

### 4. Suite de aplicaciones nativas

Deepin demuestra que una distribución se percibe como un sistema completo cuando sus aplicaciones básicas están integradas entre sí. MurSchol seguirá desarrollando una suite propia mínima, evitando duplicar herramientas innecesariamente.

Prioridad de integración:

1. Settings.
2. Files.
3. Photos + Capture.
4. Reader.
5. Calendar + Calculator.
6. Media/Music.
7. Store.

### 5. Diseño visual

Elementos útiles como referencia:

- jerarquía clara de tarjetas y secciones;
- esquinas moderadamente redondeadas;
- iconografía consistente;
- uso controlado de transparencia y desenfoque;
- animaciones cortas y funcionales;
- modo claro/oscuro coherente;
- estados hover, activo, seleccionado y deshabilitado claramente diferenciados;
- densidad visual cómoda sin desperdiciar pantalla.

MurSchol no debe depender de blur pesado. En perfil Ligero, los efectos costosos deben reducirse o desactivarse.

## Qué NO debemos copiar

- La identidad visual exacta de Deepin.
- Sus iconos, marcas o recursos propietarios sin revisar licencia.
- El escritorio DDE completo como dependencia.
- Servicios residentes que MurSchol no necesite.
- Animaciones o transparencias que deterioren rendimiento en hardware modesto.
- Código GPL/LGPL incorporado directamente sin evaluar primero implicaciones de licencia y arquitectura.

## Benchmark de MurSchol

A partir de ahora las referencias principales quedan así:

- **Windows 11:** organización, descubribilidad y estructura de Settings.
- **Windows 10:** claridad y densidad funcional.
- **macOS:** comportamiento del dock y cuidado de interacción.
- **Deepin/DDE:** coherencia visual de un escritorio Linux y suite nativa.
- **Thunar/PCManFM/Yazi:** referencia de ligereza y velocidad para Files.
- **Dolphin:** referencia funcional avanzada para Files.

MurSchol debe combinar esas ideas sin parecer una copia de ninguno.

## Aplicación inmediata

En el corto plazo, Deepin servirá sobre todo para revisar:

- consistencia visual de Settings;
- comportamiento final del Dock;
- navegación y estados en Files;
- integración Photos/Capture;
- estructura del futuro Start/Launchpad;
- experiencia de primera configuración;
- futura MurSchol Store.

La prioridad sigue siendo validar primero el sistema actual en VirtualBox y hardware real antes de introducir cambios funcionales profundos en la Live ISO.
