# MurSchol Design System

MurSchol adopta una identidad visual propia basada en cuatro colores esenciales: **blanco, azul, negro y rojo**. La intención no es llenar la interfaz de cuatro colores al mismo tiempo, sino asignar a cada uno una función estable y reconocible en todo el sistema.

## Paleta base

| Token | Valor | Uso |
| --- | --- | --- |
| `white` | `#F8FAFC` | fondo claro, texto principal sobre oscuro |
| `whitePure` | `#FFFFFF` | superficies elevadas en modo claro |
| `black` | `#0B0D12` | fondo principal oscuro |
| `blackSoft` | `#11151C` | paneles y tarjetas oscuras |
| `blackRaised` | `#171C24` | superficies elevadas oscuras |
| `blue` | `#2563EB` | acción principal, foco, selección, identidad MurSchol |
| `blueHover` | `#3B82F6` | hover y énfasis interactivo |
| `blueDeep` | `#123A7A` | selección o superficie azul oscura |
| `blueSoft` | `#EAF1FF` | selección y tarjetas en modo claro |
| `red` | `#E63946` | error, acción destructiva, alerta crítica |
| `redHover` | `#FF4D5A` | hover de acción destructiva |

Los grises permitidos se consideran derivados neutros de blanco/negro y se usan únicamente para jerarquía, bordes y texto secundario:

- `gray100`: `#EEF1F5`
- `gray300`: `#D8DEE9`
- `gray500`: `#9AA4B2`
- `gray700`: `#5B6573`
- `gray850`: `#252B35`

## Regla de uso

- **Azul** es el color de interacción y de identidad. Selecciones, foco, botones primarios, indicadores activos y enlaces usan azul.
- **Rojo** no se usa como adorno general. Se reserva para eliminar, apagar, error, peligro, grabación activa o estados que requieren atención inmediata.
- **Negro** estructura el modo oscuro. No se sustituye por verde azulado, púrpura ni teal.
- **Blanco** estructura el modo claro y sirve como contraste principal.
- No se usan verde, púrpura, naranja o teal como parte de la identidad visual global. Una aplicación de terceros conserva su icono original.

## Temas

### Oscuro

- Fondo: `black`
- Paneles: `blackSoft`
- Tarjetas: `blackRaised`
- Texto principal: `white`
- Texto secundario: `gray500`
- Selección/foco: `blue`
- Destructivo/error: `red`

### Claro

- Fondo: `white`
- Paneles/tarjetas: `whitePure`
- Texto principal: `black`
- Texto secundario: `gray700`
- Selección/foco: `blue`
- Selección suave: `blueSoft`
- Destructivo/error: `red`

## Forma y espaciado

MurSchol debe sentirse moderno y sobrio, no futurista recargado.

- Radio pequeño: 8–10 px
- Radio medio: 12–14 px
- Radio de tarjetas: 18 px
- Radio de panel grande: 24–30 px
- Espaciado base: 4 px
- Espaciados habituales: 8, 12, 16, 24 y 32 px
- Controles táctiles/clicables: mínimo aproximado de 40–44 px cuando el espacio lo permita

## Movimiento

- Duración rápida: 100 ms
- Duración normal: 160 ms
- Duración lenta: 220 ms
- Se prefieren cambios de opacidad, color y escala moderada.
- El perfil **Ligero** reduce o elimina blur, sombras complejas y escalado de hover.
- `Reducidas` usa transiciones aproximadas de 80 ms y `Desactivadas` elimina animación cosmética.

## Iconografía

- SVG es el formato principal para iconos MurSchol.
- Se mantiene una familia visual coherente, con Tabler o Phosphor como referencias principales.
- Iconos de terceros no se recolorean arbitrariamente.
- Rojo se usa en iconos solo para acciones destructivas o estados críticos.

## Componentes

Todos los componentes MurSchol deben derivarse de estos tokens:

- botón primario: azul + texto blanco;
- botón secundario: superficie neutra + borde gris;
- botón destructivo: rojo + texto blanco;
- campo de texto: fondo neutro, borde gris, foco azul;
- tarjeta seleccionada: azul profundo en oscuro / azul suave en claro;
- indicador activo: azul;
- error: rojo;
- divisor: gris neutro.

## Tokens canónicos

La paleta base vive en `shared/design/palette.json` y los valores semánticos de tema, espaciado, radios, alturas de controles y movimiento viven en `shared/design/tokens.json`.

Durante la fase alpha cada aplicación puede mantener un adaptador QML local, pero no debe inventar colores propios fuera de estos tokens. El objetivo es mover progresivamente Start, Dock, Settings, Files, Photos, Reader, Calendar, Calculator, Media y Music hacia una capa de componentes compartidos sin introducir un daemon ni una dependencia pesada.

## Estado actual de adopción

- **Start** ya usa negro/blanco como base, azul para selección/foco y rojo para borrar recientes o acciones destructivas.
- **Settings** usa azul como acento predeterminado (`#2563EB`) y migra automáticamente el antiguo teal predeterminado cuando lo encuentra en configuraciones existentes.
- El resto de aplicaciones se migrará de forma progresiva para no romper superficies funcionales antes de su validación visual.

## Alcance

La paleta se aplicará progresivamente a:

1. Start y Dock.
2. Settings y controles rápidos.
3. Files, Photos y Capture.
4. Reader, Calendar, Calculator, Media y Music.
5. MurSchol Store y futuros componentes.

La adopción progresiva evita romper aplicaciones ya funcionales. Una compilación correcta no sustituye la validación visual en Wayland, pantalla real y modo claro/oscuro.
