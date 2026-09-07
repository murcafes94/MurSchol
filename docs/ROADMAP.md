# Hoja de ruta de MurSchol

## Fase 1 — MurSchol Launcher

- [x] Launcher HOME Android mínimo.
- [x] Accesos a Aula Virtual, Biblioteca, Apuntes, Internet, Archivos y YouTube.
- [x] Cajón de aplicaciones.
- [x] Modo claro/oscuro según el sistema.
- [ ] Probar en Redmi Pad 2.
- [ ] Ajustar interfaz tras uso real.
- [ ] Configuración de accesos y URL de Moodle.
- [ ] Búsqueda de aplicaciones.
- [ ] Primera versión de MurSchol Safe sin privilegios de sistema.

## Fase 2 — MurSchol OS Mobile

- [ ] Definir dispositivos de referencia.
- [ ] Evaluar AOSP/GSI/ROM por dispositivo.
- [ ] Integrar MurSchol Launcher como HOME del sistema.
- [ ] Políticas de navegación segura a nivel de sistema.
- [ ] Optimización de memoria y batería.
- [ ] Compartir lenguaje visual y servicios básicos con MurSchol Desktop.

## Fase 3 — MurSchol OS Desktop

### Base y arquitectura

- [x] Elegir base Linux mínima: **Debian 13 minimal** como base inicial.
- [x] Definir objetivo de bajo consumo y perfiles Ligero/Normal/Rendimiento.
- [x] Definir experiencia unificada Linux + Android + Windows.
- [x] Definir política inicial de repositorios stable/testing/experimental.
- [x] Crear scripts reproducibles de bootstrap de la primera base Live Debian.
- [x] Validar **labwc** como compositor Wayland ligero en el primer arranque virtual.
- [ ] Validar labwc en hardware físico y varios controladores gráficos.

### MurSchol Desktop

- [x] Incorporar al repositorio el prototipo del shell MurSchol en C++20 + Qt 6/QML.
- [x] MurSchol Desktop 0.3.0 como primera revisión visual tras prueba en VirtualBox.
- [x] Dock inferior flotante con auto-ocultado y activación desde el borde inferior-centro.
- [x] Menú Inicio renovado con categorías y búsqueda.
- [x] Indexador de aplicaciones `.desktop` con lectura de `Categories`.
- [x] Búsqueda universal — primera fase local: aplicaciones, nombres de archivos y acciones.
- [x] MurSchol System Center — primera fase con hardware, recursos y compatibilidad.
- [x] Selector de rendimiento rediseñado con recomendación Ligero / Normal / Rendimiento.
- [x] Eliminar la decoración externa del shell para que MurSchol Desktop use su propia barra visual.
- [x] Espacios Estudio / Trabajos / Personal con estado persistente y atajos.
- [x] Modo estudio — primera fase de perfiles y preferencias.
- [x] Guía visible de multitarea: Alt+Tab y división con Super+flechas.
- [x] Primera implementación del dock global `wlr-layer-shell` mediante LayerShellQt.
- [ ] Validar el dock global sobre aplicaciones maximizadas en VirtualBox y hardware real.
- [ ] Visor gráfico de aplicaciones abiertas integrado en MurSchol.
- [ ] Centro de control real conectado a red/audio/energía.
- [ ] Búsqueda de contenido dentro de documentos, opcional y de bajo consumo.
- [ ] Modo claro/oscuro.
- [ ] Aplicar físicamente el perfil Ligero a todos los efectos del compositor.
- [ ] Espacios de trabajo gestionados por el compositor y sincronizados con el shell.
- [ ] Modo estudio con composición real de ventanas.

### Multitarea y ventanas

- [x] Aprovechar el cambio de ventanas nativo de labwc con `Alt+Tab`.
- [x] Mantener controles estándar de minimizar, maximizar/restaurar y cerrar para aplicaciones normales.
- [x] Permitir división rápida de ventanas con los atajos nativos `Super + flechas`.
- [ ] Mostrar miniaturas de ventanas abiertas desde el dock.
- [ ] Activar una ventana existente al pulsar su icono del dock.
- [ ] Enviar ventanas entre Estudio / Trabajos / Personal desde la interfaz.
- [ ] Presets reales PDF + NotCan, Moodle + Apuntes y Lectura.

### MurSchol Files

- [x] Definir la visión funcional en `docs/MURSCHOL_FILES.md`.
- [x] Crear el primer ejecutable nativo `murschol-files` en Qt 6/C++20.
- [x] Navegación por Inicio, Documentos, Descargas, Imágenes, Música y Videos.
- [x] Barra de ruta y búsqueda dentro de la carpeta actual.
- [x] Vista lista y cuadrícula.
- [x] Mostrar tamaño, fecha e iconos por tipo de archivo.
- [x] Crear carpetas y abrir archivos mediante su asociación.
- [x] Hacer MurSchol Files el gestor predeterminado de `inode/directory` en la Live ISO.
- [x] Mantener Thunar temporalmente como respaldo de seguridad.
- [ ] Historial atrás/adelante.
- [ ] Selección simple y múltiple.
- [ ] Copiar, cortar, pegar, mover, renombrar y borrar.
- [ ] Papelera y confirmaciones seguras para operaciones destructivas.
- [ ] Arrastrar y soltar.
- [ ] Panel de vista previa opcional.
- [ ] Miniaturas con caché limitada y desactivables en perfil Ligero.
- [ ] Pestañas.
- [ ] Vista dividida.
- [ ] Favoritos y etiquetas.
- [ ] Unidades USB y discos externos.
- [ ] Compresión y extracción.
- [ ] SMB/Samba, WebDAV y SFTP.
- [ ] Integración futura con MurSchol Cloud / Nextcloud, Biblioteca y NotCan.

### MurSchol Reader

- [x] Definir la visión y arquitectura en `docs/MURSCHOL_READER.md`.
- [x] Crear el esqueleto Qt 6/QML de `murschol-reader`.
- [x] Crear biblioteca visual inicial con recientes, colecciones y progreso.
- [x] Crear modo lector con panel de Contenido oculto por defecto.
- [x] Crear panel Mis marcas oculto por defecto.
- [x] Añadir modo concentración F11/Esc.
- [x] Preparar controles de búsqueda, zoom e impresión sin ocupar permanentemente el área de lectura.
- [ ] Integrar Poppler/Qt y renderizar PDF real.
- [ ] Integrar un motor eBook rápido para EPUB/MOBI/AZW3/FB2/CBZ.
- [ ] Crear base SQLite real de biblioteca, progreso, colecciones y metadatos.
- [ ] Persistir marcadores, subrayados y anotaciones.
- [ ] Implementar MurSchol Print Center con vista previa, escalado, varias páginas, folleto y dúplex.
- [ ] Añadir Calibre como gestor avanzado opcional, fuera de la ruta normal de lectura.
- [ ] Asociar formatos desde MurSchol Files.
- [ ] Integrar MurSchol Reader en la Live ISO tras validar lectura real y tiempos de apertura.

### MurSchol Photos

- [x] Definir la visión funcional en `docs/MURSCHOL_PHOTOS.md`.
- [x] Crear el primer ejecutable Qt 6/C++20 `murschol-photos`.
- [x] Reconocer JPG/JPEG, PNG, GIF, SVG y WebP.
- [x] Abrir una imagen directamente desde una ruta sin cargar una biblioteca previa.
- [x] Navegar anterior/siguiente entre imágenes de la misma carpeta.
- [x] Mostrar formato, dimensiones, tamaño, fecha y ubicación bajo demanda.
- [x] Panel de información oculto por defecto.
- [x] Preparar zoom, giro, enderezado visual, marco de recorte y dibujo.
- [ ] Guardar recorte, enderezado y dibujo en una copia sin destruir el original por defecto.
- [ ] Deshacer/rehacer operaciones de edición.
- [ ] Leer EXIF/GPS de forma diferida.
- [ ] Asociar formatos de imagen desde MurSchol Files y la Live ISO.
- [ ] Medir apertura con imágenes grandes y carpetas extensas.

### MurSchol Media

- [x] Definir la arquitectura en `docs/MURSCHOL_MEDIA.md`.
- [x] Crear el primer ejecutable Qt 6/C++20 `murschol-media`.
- [x] Integrar libmpv como motor inicial de reproducción.
- [x] Preparar reproducción de vídeo y audio en una sola aplicación.
- [x] Apertura directa por ruta y arrastrar/soltar.
- [x] Controles de reproducción, salto, volumen, velocidad y pantalla completa.
- [x] Auto-ocultar controles durante vídeo.
- [x] Navegar anterior/siguiente entre medios de la misma carpeta.
- [x] Recordar localmente la posición para continuar después.
- [x] Preparar cambio de pista de audio y subtítulos.
- [ ] Validar renderizado y aceleración por hardware en VirtualBox y hardware real.
- [ ] Selector completo de pistas y subtítulos externos SRT/ASS/VTT.
- [ ] Extraer portada y metadatos embebidos de audio.
- [ ] Añadir cola, listas M3U/M3U8 y capítulos.
- [ ] Integrar MPRIS y teclas multimedia.
- [ ] Picture-in-Picture compatible con Wayland.
- [ ] Asociar formatos desde MurSchol Files y la Live ISO.
- [ ] Biblioteca musical local opcional; estudiar servicio musical tipo Spotify en una fase posterior.

### Iconografía

- [x] Definir política de iconos común en `docs/ICON_POLICY.md`.
- [x] Utilizar iconos reales del tema Linux como base funcional en la alpha.
- [ ] Integrar el set SVG definitivo en el shell.
- [ ] Sustituir fallbacks provisionales del dock y menús.
- [ ] Compartir iconos con NotCan y el resto del ecosistema MurSchol cuando corresponda.

### Aplicaciones

- [x] Lanzamiento de aplicaciones Linux instaladas mediante `.desktop`.
- [x] Acceso directo al navegador desde el dock.
- [x] Firefox ESR incluido como navegador libre y de respaldo en la Live ISO.
- [x] Microsoft Edge preparado como instalación opcional bajo demanda desde el repositorio oficial de Microsoft.
- [x] Priorizar Edge desde el botón Navegador cuando esté instalado.
- [x] Detección e inicio básico de Waydroid bajo demanda.
- [x] Detección e inicio básico de Wine/Bottles bajo demanda.
- [x] AppImage y Flatpak integrados en la primera versión de App Manager.
- [x] MurSchol App Manager — primera fase de instalación unificada Linux/Android/Windows.
- [x] Detección de `.apk`, `.exe`, `.msi`, `.deb`, `.AppImage` y `.flatpakref`.
- [ ] Asociación de esos formatos con App Manager a nivel de sistema.
- [ ] Crear perfiles aislados de Wine/Bottles por aplicación cuando corresponda.
- [ ] Niveles de compatibilidad por aplicación.
- [ ] MurSchol Store.
- [ ] Integración profunda con Moodle, Biblioteca, NotCan y modo estudio.

### Distribución

- [ ] Perfil de instalación Básico/Completo/Personalizado.
- [ ] Caché segura para paquetes y componentes opcionales.
- [ ] Repositorio MurSchol de pruebas.
- [ ] Actualizaciones firmadas.
- [x] **MurSchol OS 0.1 Live amd64** generado como primera alpha de prueba.
- [x] Validar arranque y sesión MurSchol en VirtualBox.
- [ ] Validar arranque BIOS/UEFI en varias configuraciones.
- [ ] Validar arranque desde USB en hardware real.
- [ ] Instalador gráfico.
- [ ] Primera imagen instalable para pruebas en hardware real.
- [ ] Pruebas en equipos de 2 GB, 4 GB y 8 GB de RAM.

### Compilación continua

- [x] GitHub Actions para compilar el shell sin depender de una PC Linux local.
- [x] Empaquetado automático del prototipo Linux x86-64 como artefacto de prueba.
- [x] Workflow reproducible para construir y verificar la Live ISO.
- [x] Verificación SHA-256 automática antes de publicar el artefacto de la ISO.
