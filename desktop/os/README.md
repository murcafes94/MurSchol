# MurSchol OS Desktop

Sistema para PC de la familia MurSchol.

## Estado actual

Se inició **MurSchol Desktop 0.2**, el primer shell real del proyecto para Linux. La implementación comienza directamente con **C++20 + Qt 6/QML** para evitar depender de un runtime Python en el escritorio final y mantener una base ligera.

### Ya implementado en el prototipo

- barra superior propia;
- dock inferior;
- menú Inicio;
- indexado real de aplicaciones Linux desde archivos `.desktop`;
- búsqueda de aplicaciones por nombre;
- lanzamiento de aplicaciones instaladas;
- monitor básico de CPU, RAM y disco;
- detección de Waydroid, Wine, Bottles y Flatpak;
- MurSchol System Center inicial;
- perfiles Ligero / Normal / Rendimiento;
- espacios de trabajo como primera capa visual;
- atajos para Archivos y Terminal;
- compilación automática con GitHub Actions.

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

## Compilar

En Debian/Ubuntu de desarrollo:

```bash
sudo apt install cmake ninja-build g++ qt6-base-dev qt6-declarative-dev
cmake -S desktop/os/shell -B build/desktop -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/desktop --parallel
./build/desktop/murschol-desktop
```

Si no se dispone de una PC Linux, GitHub Actions compila automáticamente el shell y publica un artefacto de prueba.

## Próximos hitos

1. convertir el prototipo en una sesión Wayland completa;
2. conectar Wi‑Fi, Bluetooth, audio, brillo y energía;
3. búsqueda universal de archivos y acciones;
4. espacios de trabajo funcionales;
5. modo estudio (PDF + NotCan / Moodle + apuntes);
6. App Manager unificado para Linux/Android/Windows;
7. Live ISO de MurSchol OS.
