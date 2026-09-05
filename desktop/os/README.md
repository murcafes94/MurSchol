# MurSchol OS Desktop

Sistema para PC de la familia MurSchol.

## Estado actual

MurSchol Desktop ya funciona como un shell real en **C++20 + Qt 6/QML** y la primera imagen Live reproducible está en construcción sobre **Debian 13 (Trixie) + Wayland + labwc**.

### Ya implementado en el prototipo

- barra superior propia;
- dock inferior;
- menú Inicio;
- indexado real de aplicaciones Linux desde archivos `.desktop`;
- búsqueda universal local de aplicaciones, archivos y acciones;
- lanzamiento de aplicaciones instaladas;
- monitor de CPU, RAM, disco y batería;
- detección de Waydroid, Wine, Bottles y Flatpak;
- MurSchol System Center inicial;
- perfiles Ligero / Normal / Rendimiento con recomendación por hardware;
- espacios Estudio / Trabajos / Personal;
- modo estudio inicial;
- MurSchol App Manager inicial para `.apk`, `.exe`, `.msi`, `.deb`, `.AppImage` y `.flatpakref`;
- compilación automática del shell con GitHub Actions;
- infraestructura de **MurSchol OS Live 0.1** con `live-build`.

## Base prevista

- kernel Linux;
- Debian 13 minimal como base de distribución;
- Wayland;
- labwc como compositor ligero de la primera alpha;
- MurSchol Desktop como shell propio.

No se instalará GNOME o KDE completo como dependencia del producto final.

## Filosofía de recursos

Android (Waydroid) y Windows (Wine/Bottles) serán componentes bajo demanda. MurSchol debe arrancar con servicios mínimos y activar capas adicionales solo cuando una aplicación las necesite.

Perfiles iniciales:

- **Ligero**: efectos mínimos, indexación limitada, servicios opcionales bajo demanda.
- **Normal**: equilibrio para equipos de 4 GB o más.
- **Rendimiento**: más caché y multitarea cuando el hardware lo permita.

## Compilar el shell

En Debian/Ubuntu de desarrollo:

```bash
sudo apt install cmake ninja-build g++ qt6-base-dev qt6-declarative-dev
cmake -S desktop/os/shell -B build/desktop -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/desktop --parallel
./build/desktop/murschol-desktop
```

## Construir la ISO Live

Con `live-build` y sus dependencias instaladas:

```bash
sudo ./desktop/os/live/build-live.sh
```

La salida esperada es:

```text
MurSchol-OS-0.1-Live-amd64.iso
MurSchol-OS-0.1-Live-amd64.iso.sha256
```

GitHub Actions también construye la ISO automáticamente y la publica como artefacto de prueba.

## Próximos hitos

1. validar el primer arranque de MurSchol OS Live en máquina virtual;
2. corregir sesión/autologin/Wayland según el resultado de la primera ISO;
3. conectar Wi‑Fi, Bluetooth, audio, brillo y energía directamente al shell;
4. convertir espacios de trabajo y modo estudio en funciones del compositor;
5. App Manager unificado completo para Linux/Android/Windows;
6. instalador gráfico;
7. primera imagen instalable en hardware real.
