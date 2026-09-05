# MurSchol OS Desktop

Sistema para PC de la familia MurSchol.

## Estado actual

**MurSchol Desktop 0.2.3** es el primer shell real del proyecto para Linux. La implementación usa **C++20 + Qt 6/QML** para evitar depender de un runtime Python en el escritorio final y mantener una base ligera.

### Ya implementado en el prototipo

- barra superior propia con reloj, CPU, RAM, batería y espacio activo;
- dock inferior con accesos a Inicio, Archivos, Terminal, Android, Windows, App Manager y Sistema;
- menú Inicio;
- indexado real de aplicaciones Linux desde archivos `.desktop`;
- lanzamiento de aplicaciones instaladas;
- **búsqueda universal local** de aplicaciones, documentos y acciones;
- búsqueda limitada a Escritorio, Documentos y Descargas para evitar un indexador pesado;
- acción opcional para buscar en Internet mediante el navegador predeterminado;
- monitor real de CPU, RAM y disco;
- detección de distribución, kernel, CPU, núcleos/hilos y batería;
- detección de Waydroid, Wine, Bottles y Flatpak;
- MurSchol System Center inicial;
- perfil recomendado automáticamente según RAM y CPU;
- perfiles Ligero / Normal / Rendimiento persistentes;
- espacios de trabajo seleccionables: Estudio / Trabajos / Personal;
- atajos `Super + 1`, `Super + 2` y `Super + 3` para los espacios;
- primera capa funcional de **Modo estudio** con perfiles PDF + NotCan, Moodle + Apuntes y Lectura;
- **MurSchol App Manager 0.1** integrado en el shell;
- detección e instalación/apertura guiada de `.apk`, `.exe`, `.msi`, `.deb`, `.AppImage` y `.flatpakref`;
- selección automática del motor adecuado: Waydroid, Wine/Bottles, APT, AppImage o Flatpak;
- compilación automática con GitHub Actions.

> Los espacios y el Modo estudio ya guardan estado y preferencias. La colocación real de ventanas se conectará cuando MurSchol Desktop controle el compositor Wayland.

> App Manager ya ejecuta la ruta de instalación correspondiente, pero todavía no registra asociaciones de archivos del sistema ni crea perfiles de compatibilidad por aplicación. Esos pasos pertenecen a la siguiente fase.

## Base prevista

- kernel Linux;
- Debian 13 minimal como primera base de distribución;
- Wayland;
- compositor ligero por validar;
- MurSchol Desktop como shell propio.

No se instalará GNOME o KDE completo como dependencia del producto final.

## Filosofía de recursos

Android (Waydroid) y Windows (Wine/Bottles) serán componentes bajo demanda. MurSchol debe arrancar con servicios mínimos y activar capas adicionales solo cuando una aplicación las necesite.

Perfiles iniciales:

- **Ligero**: efectos mínimos, indexación limitada, servicios opcionales bajo demanda.
- **Normal**: equilibrio para equipos de 4 GB o más.
- **Rendimiento**: más caché y multitarea cuando el hardware lo permita.

La búsqueda local evita por ahora un servicio de indexación en segundo plano: mantiene un índice acotado de nombres de archivos y lo actualiza cuando el usuario lo solicita.

## Compilar

En Debian/Ubuntu de desarrollo:

```bash
sudo apt install cmake ninja-build g++ qt6-base-dev qt6-declarative-dev libxkbcommon-dev qml6-module-qtquick-dialogs
cmake -S desktop/os/shell -B build/desktop -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/desktop --parallel
./build/desktop/murschol-desktop
```

Si no se dispone de una PC Linux, GitHub Actions compila automáticamente el shell y publica un artefacto de prueba.

## Próximos hitos

1. perfiles aislados por aplicación Windows y registro de compatibilidad;
2. asociaciones de archivos con MurSchol App Manager;
3. convertir el prototipo en una sesión Wayland completa;
4. conectar Wi‑Fi, Bluetooth, audio, brillo y energía;
5. convertir los espacios de trabajo en escritorios reales;
6. hacer que Modo estudio organice físicamente las ventanas;
7. preparar scripts reproducibles de Debian 13 minimal;
8. primera Live ISO de MurSchol OS.
