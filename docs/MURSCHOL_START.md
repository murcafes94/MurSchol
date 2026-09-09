# MurSchol Start

MurSchol Start es el lanzador principal de aplicaciones del escritorio. Su objetivo es combinar la claridad de Windows 11, la rapidez de un lanzador Linux y la coherencia visual que destaca en Deepin/DDE, sin convertir el sistema en un clon de ninguno de ellos.

## Principios

- El usuario ve **aplicaciones y tareas**, no la plataforma técnica desde la que se ejecutan.
- La búsqueda sigue siendo la vía más rápida para abrir aplicaciones, archivos y ajustes.
- Las aplicaciones pueden fijarse localmente para crear una zona personal de acceso rápido.
- Las aplicaciones abiertas recientemente se recuerdan solo en el equipo.
- No hay telemetría ni sincronización remota de actividad.
- El lanzador debe seguir siendo útil en modo Ligero: sin blur obligatorio, sin indexadores pesados y sin animaciones costosas.

## Estado 0.2

La versión 0.2 añade dos vistas de uso frecuente:

- **Fijadas**: aplicaciones elegidas por el usuario.
- **Recientes**: últimas aplicaciones abiertas desde MurSchol Start, ordenadas por uso reciente.

El estado se guarda en `~/.config/murschol/start.ini` mediante `QSettings`. La lista reciente se limita visualmente para evitar convertir Inicio en un historial infinito.

Cada mosaico permite fijar o desfijar una aplicación. En la vista general se mantiene el filtrado por categorías: Educación, Productividad, Multimedia, Internet, Sistema y Accesibilidad.

## Coherencia de producto

MurSchol Start deja de mostrar la etiqueta de origen técnico (`Linux`, `Usuario`, etc.) debajo de cada aplicación. Esa información pertenece a **Settings > Aplicaciones > Compatibilidad**, no al flujo normal de abrir una app.

El pie del lanzador ofrece accesos directos a **Archivos**, **Configuración** y **Apagar**.

## Próximas fases

1. Sustituir letras de respaldo por iconos propios coherentes para todas las aplicaciones MurSchol.
2. Añadir menú contextual con fijar al Dock, información de la aplicación y desinstalar cuando corresponda.
3. Integrar ventanas abiertas reales para que una aplicación ya ejecutándose se active en vez de lanzar una instancia nueva cuando sea apropiado.
4. Añadir recomendaciones académicas opcionales basadas únicamente en contexto local de MurSchol, sin telemetría.
5. Unificar visualmente Start, Dock, Settings y las aplicaciones mediante el MurSchol Design System.

## Estado de validación

El comportamiento debe validarse en la siguiente Live ISO. La compilación correcta no se considera prueba suficiente de interacción, foco, teclado ni comportamiento bajo labwc/Wayland.
