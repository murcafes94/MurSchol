# MurSchol

MurSchol es un proyecto unificado para construir una experiencia de estudio ligera y coherente en Android y PC.

## Componentes

- `mobile/launcher/` — **MurSchol Launcher**, el escritorio académico instalable como APK sobre Android/HyperOS.
- `mobile/os/` — futuro **MurSchol OS Mobile**, para tablet y teléfono sobre una base Android/AOSP.
- `desktop/os/` — futuro **MurSchol OS Desktop**, para PC sobre una base Linux ligera.
- `shared/` — recursos y especificaciones compartidas entre plataformas.
- `docs/` — arquitectura, hoja de ruta y decisiones técnicas.

## Estado actual

La primera pieza funcional es **MurSchol Launcher 0.1 — Simplex**. Es un launcher HOME de Android sin root, pensado primero para tablet, con accesos rápidos a Aula Virtual (Moodle), Biblioteca, Apuntes, Internet, Archivos y YouTube, además de un cajón de aplicaciones.

## Principios

1. Ligero y rápido incluso en hardware modesto.
2. Estudio y lectura como prioridad.
3. Interfaz coherente entre tablet, teléfono y PC.
4. Sin modificaciones destructivas para probar el launcher.
5. Evolución gradual: Launcher → MurSchol OS Mobile → MurSchol OS Desktop.

## Compilación del launcher

GitHub Actions compilará automáticamente el APK de depuración al modificar `mobile/launcher/`. También puede abrirse ese directorio directamente en Android Studio.

---

**MurSchol** — un entorno de estudio, no solo otra capa de aplicaciones.
