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
- [ ] Crear scripts reproducibles de bootstrap de la base Debian.
- [ ] Elegir y validar compositor Wayland ligero para la primera imagen.

### MurSchol Desktop

- [x] Incorporar al repositorio el prototipo del shell MurSchol en C++20 + Qt 6/QML.
- [x] Dock inferior inicial adaptable.
- [x] Menú Inicio.
- [x] Indexador de aplicaciones `.desktop`.
- [x] Búsqueda universal — primera fase local: aplicaciones, nombres de archivos y acciones.
- [x] MurSchol System Center — primera fase con hardware, recursos y compatibilidad.
- [x] Perfil adaptativo Ligero / Normal / Rendimiento con recomendación por hardware.
- [x] Espacios Estudio / Trabajos / Personal con estado persistente y atajos.
- [x] Modo estudio — primera fase de perfiles y preferencias.
- [ ] Centro de control real conectado a red/audio/energía.
- [ ] Búsqueda de contenido dentro de documentos, opcional y de bajo consumo.
- [ ] Modo claro/oscuro.
- [ ] Aplicar físicamente el perfil Ligero a todos los efectos del compositor.
- [ ] Espacios de trabajo gestionados por el compositor.
- [ ] Modo estudio con composición real de ventanas.

### Aplicaciones

- [x] Lanzamiento de aplicaciones Linux instaladas mediante `.desktop`.
- [x] Detección e inicio básico de Waydroid bajo demanda.
- [x] Detección e inicio básico de Wine/Bottles bajo demanda.
- [ ] AppImage y Flatpak integrados explícitamente en App Manager.
- [ ] MurSchol App Manager con instalación unificada para Linux/Android/Windows.
- [ ] Asociación de `.apk`, `.exe`, `.msi`, `.deb` y `.AppImage` con App Manager.
- [ ] Niveles de compatibilidad por aplicación.
- [ ] MurSchol Store.
- [ ] Integración profunda con Moodle, Biblioteca, NotCan y modo estudio.

### Distribución

- [ ] Perfil de instalación Básico/Completo/Personalizado.
- [ ] Caché segura para paquetes y componentes opcionales.
- [ ] Repositorio MurSchol de pruebas.
- [ ] Actualizaciones firmadas.
- [ ] Live ISO.
- [ ] Instalador gráfico.
- [ ] Primera imagen instalable para pruebas en hardware real.
- [ ] Pruebas en equipos de 2 GB, 4 GB y 8 GB de RAM.

### Compilación continua

- [x] GitHub Actions para compilar el shell sin depender de una PC Linux local.
- [x] Empaquetado automático del prototipo Linux x86-64 como artefacto de prueba.
- [ ] Workflow para construir una Live ISO reproducible.
