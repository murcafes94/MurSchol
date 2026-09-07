# MurSchol Settings

MurSchol Settings será el centro único de configuración de MurSchol OS. Su objetivo es reemplazar la dispersión actual entre System Center, controles rápidos, herramientas externas y ajustes manuales, sin convertir el sistema en un panel pesado.

## Principios

1. **Una sola configuración visible.** El usuario no debe saber qué ajuste viene de labwc, NetworkManager, PipeWire, BlueZ, UPower, XDG o Debian.
2. **Panel rápido ≠ Settings.** El panel rápido sirve para acciones de segundos; Settings sirve para configurar.
3. **La interfaz nunca corre como root.** Los cambios privilegiados se harán mediante helpers limitados y Polkit cuando corresponda.
4. **Local-first.** La mayoría de preferencias deben funcionar y persistir sin cuenta ni Internet.
5. **Sin duplicación.** System Center pasa a ser información y rendimiento dentro de Settings, no otra aplicación paralela.
6. **Configuración compartida.** Los perfiles y preferencias de MurSchol deben poder ser consultados por Reader, Files, Photos, Media, Music y el shell mediante un almacenamiento común pequeño.

## Estructura de navegación

### Sistema

- Pantalla
- Sonido
- Red e Internet
- Bluetooth
- Energía
- Almacenamiento

### Personalización

- Apariencia
- Fondo
- Dock
- Panel
- Espacios de trabajo

### Aplicaciones

- Aplicaciones instaladas
- Aplicaciones predeterminadas
- Inicio automático
- Compatibilidad Linux / Android / Windows

### Dispositivo

- Hardware
- Rendimiento
- Batería
- Información del sistema

### MurSchol OS

- Actualizaciones
- Fecha e idioma
- Accesibilidad
- Copia de seguridad
- Acerca de

## Arquitectura

```text
MurSchol Settings (Qt 6 / QML)
            |
      SettingsBackend
            |
  +---------+----------+----------+-----------+
  |         |          |          |           |
Display   Network    Audio     Bluetooth    Power
  |         |          |          |           |
labwc/    Network-   PipeWire/   BlueZ      UPower/
wlroots   Manager    WirePlumber D-Bus      brightnessctl
            |
  +---------+----------+----------+-----------+
            |
   MurSchol preferences
   XDG MIME / apps / profiles
```

La primera implementación no debe crear un daemon grande. Se empezará con una aplicación normal y backends especializados. Solo los servicios que realmente necesiten permanecer activos —por ejemplo recordatorios del calendario o actualización diferida— serán procesos separados.

## Persistencia común

Las preferencias propias de MurSchol deben converger en una configuración compartida, inicialmente bajo `~/.config/murschol/`. Entre ellas:

- tema: automático / claro / oscuro;
- color de énfasis;
- perfil Ligero / Normal / Rendimiento;
- comportamiento y tamaño del dock;
- espacio de trabajo activo y preferencias de espacios;
- reducción de animaciones;
- aplicaciones predeterminadas propias de MurSchol.

No se copiarán a este archivo estados que ya pertenecen correctamente a NetworkManager, PipeWire, BlueZ o XDG.

## Panel rápido

El panel rápido debe mostrar únicamente controles inmediatos:

- Wi-Fi;
- Bluetooth;
- volumen;
- brillo;
- batería;
- perfil de rendimiento;
- acceso a Settings.

Un clic sobre el texto o la flecha de una categoría puede abrir su página completa en MurSchol Settings.

## Fase 1 — base que conviene construir primero

### Apariencia

- tema automático / claro / oscuro;
- color de énfasis;
- animaciones normal / reducidas / desactivadas;
- fondo de escritorio;
- integración inicial con shell y aplicaciones MurSchol.

### Dock y panel

- auto-ocultar;
- tamaño;
- posición/alineación permitida por el diseño MurSchol;
- ampliación al pasar el puntero;
- mostrar indicadores de aplicaciones abiertas;
- densidad del panel.

### Rendimiento

El selector actual ya persiste Ligero / Normal / Rendimiento, pero todavía afecta principalmente sondeo y algunas animaciones. Settings debe convertirlo en una política compartida real.

Objetivo:

- **Ligero:** menos animaciones, miniaturas bajo demanda, menor precarga y cachés pequeñas.
- **Normal:** equilibrio.
- **Rendimiento:** mayor precarga/caché y efectos completos cuando el hardware lo permita.

La política no debe forzar frecuencias de CPU directamente en la primera fase. Cualquier control energético de bajo nivel requerirá detección de hardware, permisos y pruebas reales.

### Sistema / Acerca de

Mover aquí la información que hoy expone System Center:

- distribución;
- kernel;
- CPU y número de hilos;
- RAM total y uso;
- disco;
- batería;
- compatibilidad Waydroid / Wine / Bottles / Flatpak.

System Center puede desaparecer visualmente cuando Settings cubra estas páginas, pero su backend reutilizable debe migrarse en lugar de reescribirse desde cero.

## Fase 2 — hardware y conectividad

### Red

Preferencia técnica: hablar con NetworkManager mediante D-Bus en lugar de abrir `nm-connection-editor` como experiencia principal.

Funciones:

- Wi-Fi on/off;
- redes visibles;
- conexión/desconexión;
- redes guardadas;
- Ethernet;
- detalles IP/DNS;
- proxy más adelante.

### Sonido

Preferencia: PipeWire/WirePlumber.

- salida activa;
- entrada activa;
- volumen;
- silencio;
- balance;
- dispositivos;
- niveles por aplicación en una fase posterior.

### Bluetooth

BlueZ por D-Bus:

- on/off;
- descubrir;
- emparejar;
- conectar/desconectar;
- olvidar dispositivo.

### Energía

- batería y estado de carga;
- brillo;
- suspensión;
- apagado de pantalla;
- comportamiento al cerrar tapa cuando el hardware lo exponga;
- coordinación futura con perfiles de rendimiento.

## Fase 3 — pantalla y aplicaciones

### Pantalla

Para wlroots/labwc se evaluará el mecanismo más estable disponible en Debian 13 para:

- resolución;
- frecuencia;
- escala;
- orientación;
- pantalla principal;
- disposición de varios monitores.

No se grabará configuración destructiva inmediatamente: los cambios de pantalla deben ofrecer confirmación y reversión automática si el usuario no confirma.

### Aplicaciones predeterminadas

Settings será la interfaz para asociaciones XDG/MIME:

- navegador;
- PDF/eBook;
- imágenes;
- música;
- vídeo;
- carpetas;
- calendario;
- tipos adicionales.

La fuente de verdad seguirá siendo XDG/MIME; Settings solo la hará comprensible.

### Compatibilidad

Una página específica mostrará:

```text
Linux
  Nativo / Flatpak / AppImage
Android
  Waydroid: instalado / detenido / activo
Windows
  Wine / Bottles: disponible / no instalado
```

No se presentará como virtualización perfecta: cada plataforma conservará sus límites de compatibilidad.

## Fase 4 — actualizaciones y privilegios

La interfaz debe ocultar la complejidad de `apt` y Flatpak, pero no esconder qué se va a instalar.

Arquitectura prevista:

```text
MurSchol Settings
      |
UpdateBackend (sin privilegios)
      |
Polkit
      |
helper mínimo de MurSchol
      |
apt / componentes MurSchol / Flatpak
```

El helper privilegiado tendrá una lista de operaciones cerrada. No aceptará comandos de shell arbitrarios provenientes de QML.

## Relación con el código actual

El proyecto ya tiene piezas aprovechables:

- `SystemBackend`: estadísticas, hardware, batería, perfil y detección de compatibilidad.
- `SystemCenter.qml`: interfaz actual que sirve como referencia para la futura página Sistema/Rendimiento.
- `QuickControlsBackend.h`: intención inicial de Red/Audio/Bluetooth; debe evolucionar a backends reales en lugar de limitarse a abrir herramientas externas.
- App Manager: puede alimentar la página Aplicaciones/Compatibilidad, sin fusionar necesariamente su instalador dentro de Settings.

## Orden recomendado de implementación

1. Crear `murschol-settings` con navegación y búsqueda interna.
2. Crear `MurScholSettingsStore` compartido para apariencia/perfil/dock.
3. Migrar Información + Rendimiento desde System Center.
4. Implementar Apariencia y Dock de forma real.
5. Conectar Panel rápido con Settings.
6. Red, Audio y Bluetooth mediante D-Bus.
7. Energía y Pantalla.
8. Aplicaciones predeterminadas.
9. Actualizaciones con helper Polkit.
10. Accesibilidad, copias de seguridad y opciones avanzadas.

## Restricción de la alpha

No se integrará una opción en Settings como "funcional" solo porque tenga una interfaz. Cada interruptor debe leer el estado real del sistema, aplicar el cambio y confirmar el resultado. Las páginas todavía no conectadas deberán identificarse internamente como pendientes y no simular cambios.
