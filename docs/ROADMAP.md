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

- [ ] Incorporar al repositorio el prototipo del shell MurSchol.
- [ ] Dock inferior adaptable.
- [ ] Menú Inicio.
- [ ] Centro de control real conectado a red/audio/energía.
- [ ] Búsqueda universal.
- [ ] Indexador de aplicaciones `.desktop`.
- [ ] Modo claro/oscuro.
- [ ] Perfil gráfico Ligero sin blur ni efectos costosos.
- [ ] MurSchol System Center.

### Aplicaciones

- [ ] Linux nativo, Flatpak y AppImage.
- [ ] Waydroid bajo demanda para APK.
- [ ] Wine/Bottles bajo demanda para EXE/MSI.
- [ ] MurSchol App Manager con instalación unificada.
- [ ] Niveles de compatibilidad por aplicación.
- [ ] Integración con Moodle, Biblioteca y modo estudio.

### Distribución

- [ ] Perfil de instalación Básico/Completo/Personalizado.
- [ ] Caché segura para paquetes y componentes opcionales.
- [ ] Repositorio MurSchol de pruebas.
- [ ] Actualizaciones firmadas.
- [ ] Live ISO.
- [ ] Instalador gráfico.
- [ ] Primera imagen instalable para pruebas en hardware real.
- [ ] Pruebas en equipos de 2 GB, 4 GB y 8 GB de RAM.
