# MurSchol Settings — Pantalla

La página **Pantalla** sigue una experiencia inspirada en Windows 11, pero con menos fragmentación y con controles visibles solo cuando están conectados a un backend real.

## Arquitectura 0.1

```text
MurSchol Settings
      |
 DisplayBackend (Qt 6 / C++20)
      |
 +----------------+----------------+
 |                |                |
Qt / Wayland    Gammastep      PowerBackend
pantallas       luz nocturna   brillo
```

## Implementado

### Pantallas

`DisplayBackend` obtiene las pantallas visibles mediante Qt/Wayland y muestra:

- nombre de salida;
- resolución actual;
- frecuencia detectada;
- escala efectiva;
- posición lógica;
- pantalla principal.

La fase 0.1 es deliberadamente conservadora: todavía no cambia resolución, escala, orientación ni disposición. Antes de habilitar esos cambios necesitamos un mecanismo probado de **confirmación y reversión automática** para evitar dejar la pantalla inutilizable.

### Brillo

La página Pantalla reutiliza `PowerBackend`, la misma fuente usada por Energía:

- muestra el control únicamente cuando `brightnessctl` detecta un dispositivo compatible;
- lee el porcentaje actual;
- permite cambiarlo sin duplicar estado.

### Luz nocturna / filtro de luz azul

La primera implementación usa **Gammastep** en modo Wayland y está integrada en la receta de la Live ISO.

Funciones ya implementadas:

- activar/desactivar manualmente;
- temperatura ajustable entre 3000 K y 6500 K;
- preset **Suave** (5000 K);
- preset **Nocturno** (3600 K);
- persistir preferencia y temperatura bajo `~/.config/murschol/settings.ini`;
- reintentar la aplicación al abrir Settings si estaba activada;
- restablecer gamma al desactivar;
- informar de incompatibilidad si el compositor/controlador no admite el ajuste.

Gammastep se ejecuta con el método Wayland y en modo manual de una sola aplicación del efecto. MurSchol no usa Redshift como dependencia principal.

## Pendiente

- Programación por horario.
- Atardecer/amanecer.
- Acceso rápido de Luz nocturna desde el panel del sistema.
- Cambios reales de resolución, frecuencia, escala y orientación.
- Disposición gráfica de múltiples monitores.
- Confirmación de cambios y reversión automática.
- Validación HiDPI.

La programación se conectará a un servicio de usuario pequeño para que funcione aunque Settings esté cerrado; hasta entonces no se muestra un selector horario ficticio.

## Validación pendiente

1. VirtualBox: detectar correctamente la pantalla virtual y comprobar si el compositor expone control gamma.
2. Hardware real: validar Gammastep con GPU/controlador físicos.
3. Portátil real: brillo.
4. Varios monitores y HiDPI.
5. Elegir y probar el mecanismo definitivo para configurar salidas con labwc/wlroots.
