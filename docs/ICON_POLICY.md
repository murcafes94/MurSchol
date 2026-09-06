# MurSchol OS — Política de iconos

## Objetivo

La iconografía de MurSchol debe sentirse coherente entre Desktop, Launcher, Mobile y las aplicaciones propias. No se mezclarán familias visuales sin una razón funcional.

## Fuente principal

Para los iconos generales se prioriza **All SVG Icons**, seleccionando una sola familia abierta y coherente para cada versión del sistema. Los candidatos principales son **Tabler** y **Phosphor** por su claridad, variedad y buen comportamiento a tamaños pequeños.

## Referencia secundaria

**Flaticon** puede seguir utilizándose como referencia o para iconos concretos heredados de NotCan, siempre respetando la licencia y atribución aplicable al recurso elegido. No se copiarán iconos con condiciones incompatibles con la distribución de MurSchol OS.

## Reglas visuales

- mismo grosor de trazo dentro de cada superficie;
- esquinas suavemente redondeadas;
- evitar mezclar iconos 3D, lineales y rellenos en una misma barra;
- variantes claras para reposo, hover, activo y deshabilitado;
- tamaño base del dock: 28–32 px;
- tamaño base de menús: 20–24 px;
- icono + etiqueta para funciones esenciales;
- color solo cuando aporta significado, no como decoración indiscriminada.

## Categorías prioritarias

1. Inicio
2. Archivos
3. Navegador
4. Biblioteca
5. NotCan
6. Moodle
7. Terminal
8. Tienda / App Manager
9. Ajustes
10. Papelera
11. Red / Wi‑Fi
12. Sonido
13. Energía
14. Rendimiento
15. Android / Linux / Windows

## Implementación por fases

### v0.3

Se normaliza la geometría, tamaños y estados de los botones del shell. Mientras se integra el paquete SVG definitivo, se usan símbolos/fallbacks simples para garantizar que la ISO funcione incluso sin un tema de iconos externo.

### v0.4

Se incorporará el set SVG definitivo al repositorio, con licencia y atribución documentadas, y se eliminarán los fallbacks provisionales en las superficies principales.
