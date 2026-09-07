# MurSchol Settings — Pantalla

La página **Pantalla** seguirá una experiencia inspirada en Windows 11, pero con menos fragmentación y con controles visibles solo cuando estén conectados a un backend real.

## Objetivo

Centralizar monitores, resolución, escala, orientación, frecuencia, brillo y **Luz nocturna** dentro de MurSchol Settings.

## Arquitectura prevista

```text
MurSchol Settings
      |
 DisplayBackend (Qt 6 / C++20)
      |
 +----------------+----------------+----------------+
 |                |                |
wlroots/labwc   brightnessctl   NightLightBackend
salidas          brillo          gamma/temperatura
```

Para la configuración de salidas se evaluará el mecanismo más estable disponible en Debian 13/labwc. No se fijará una dependencia definitiva antes de probarla en la ISO y en hardware real.

## Funciones de Pantalla

### Monitores

- detectar una o varias pantallas;
- identificar pantalla principal;
- resolución;
- frecuencia;
- escala;
- orientación;
- disposición relativa de varios monitores;
- confirmar cambios y revertir automáticamente si el usuario no confirma.

Nunca se persistirá un cambio de resolución/disposición potencialmente destructivo sin un mecanismo de reversión.

### Brillo

El control de brillo puede aparecer también en Energía. Ambos deben usar el mismo backend/fuente de verdad.

## Luz nocturna / filtro de luz azul

MurSchol incluirá un filtro similar a **Luz nocturna** de Windows 11.

Funciones previstas:

- activar/desactivar;
- intensidad/temperatura de color;
- activación inmediata;
- programación manual por hora;
- programación del atardecer al amanecer cuando exista ubicación/zona horaria suficiente;
- acceso rápido desde el panel del sistema.

UX objetivo:

```text
Luz nocturna                             [ ON ]
Reduce la luz azul y usa tonos más cálidos.

Intensidad
Más frío ───────●──────── Más cálido

Programación
○ Desactivada
● De 19:00 a 06:00
○ Del atardecer al amanecer

[ Activar ahora ]
```

### Presets

La interfaz puede ofrecer dos atajos sin limitar el control continuo:

- **Suave**: calentamiento discreto para estudio y lectura prolongada;
- **Nocturno**: temperatura más cálida para uso nocturno.

## Backend de Luz nocturna

Primera preferencia: una solución compatible con Wayland/wlroots que no obligue a mantener un entorno de escritorio pesado. Se evaluará `gammastep` y el soporte de protocolos de gamma del compositor.

No se usará Redshift como dependencia principal de MurSchol OS.

La implementación debe comprobar compatibilidad del compositor/controlador. Si no existe soporte gamma, Settings informará que Luz nocturna no está disponible en ese equipo en lugar de simular el efecto.

## Panel rápido

El panel rápido mostrará:

```text
Brillo   ─────●────
Luz nocturna   [ ON ]
```

Un toque activa/desactiva; el acceso de detalle abre `murschol-settings --page display`.

## Independencia del perfil de rendimiento

Luz nocturna no se activará automáticamente por usar Ligero/Normal/Rendimiento. Son preferencias distintas.

## Pendiente de validación

1. Detectar método fiable de configuración de salidas con labwc/wlroots en Debian 13.
2. Validar brillo en portátil real.
3. Validar gamma/Luz nocturna en VirtualBox y GPU física.
4. Diseñar reversión segura de resolución, escala y disposición.
5. Validar múltiples monitores y HiDPI.
