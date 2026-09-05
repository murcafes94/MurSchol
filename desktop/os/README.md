# MurSchol OS Desktop

MurSchol OS Desktop es la variante para PC de MurSchol: un sistema Linux ligero, coherente con MurSchol Mobile y capaz de presentar aplicaciones Linux, Android y Windows dentro de una sola experiencia de escritorio.

## Base técnica decidida

- **Kernel:** Linux.
- **Base inicial:** Debian 13 minimal (`amd64`).
- **Sesión gráfica:** Wayland.
- **Compositor objetivo:** uno ligero basado en wlroots/labwc durante las primeras fases; el shell MurSchol se construirá de forma independiente para poder sustituir la base gráfica más adelante.
- **Shell:** MurSchol Desktop, con interfaz propia.
- **Linux:** aplicaciones nativas, Flatpak y AppImage.
- **Android:** Waydroid bajo demanda.
- **Windows:** Wine/Bottles bajo demanda.

## Principio de diseño

El usuario no debe tener que pensar en si una aplicación es Linux, Android o Windows. Inicio, búsqueda y dock las presentan como aplicaciones de MurSchol. El origen técnico solo aparece en información avanzada o en el Centro del Sistema.

## Objetivo de ligereza

MurSchol se diseña primero para hardware modesto y luego se amplía para equipos potentes.

- Objetivo de escritorio recién iniciado: **aprox. 450–500 MB de RAM o menos**, sujeto a medición real.
- Objetivo mínimo de referencia: **2 GB RAM, CPU x86-64 de 2 núcleos y almacenamiento HDD/SSD**.
- Waydroid, Wine/Bottles, indexadores pesados y servicios no esenciales no deben arrancar permanentemente.
- Efectos visuales costosos (blur, transparencias complejas, animaciones extensas) se desactivarán en el perfil ligero.

## Perfiles de hardware

### Ligero

Para equipos de aproximadamente 2 GB de RAM:

- Linux nativo como prioridad.
- efectos mínimos;
- animaciones reducidas;
- Android apagado hasta que el usuario abra una APK;
- Windows iniciado solo al ejecutar una aplicación compatible;
- servicios opcionales suspendidos cuando no se utilizan.

### Normal

Para 4 GB de RAM:

- experiencia visual completa moderada;
- Android y Windows bajo demanda;
- multitarea estándar.

### Rendimiento

Para 8 GB o más:

- todos los subsistemas disponibles;
- multitarea amplia;
- efectos opcionales completos.

Los perfiles serán una política del mismo sistema, no tres distribuciones distintas.

## Interfaz de escritorio

La interfaz diaria será limpia y no mostrará paneles técnicos permanentemente.

- barra superior discreta con reloj, red, sonido, batería/energía y acceso al centro de control;
- dock inferior centrado y adaptable;
- menú Inicio con búsqueda, aplicaciones fijadas y recientes;
- búsqueda universal mediante `Super + Espacio`;
- ventanas con bordes suaves y controles consistentes;
- modos claro y oscuro;
- escritorio libre para carpetas, documentos y accesos directos;
- Centro del Sistema separado para Android, Windows, repositorios, recursos y diagnósticos.

## Instalación de aplicaciones

MurSchol App Manager detectará el tipo de archivo y elegirá la capa adecuada:

- `.apk` → Waydroid;
- `.exe` / `.msi` → Wine o Bottles;
- `.deb` → APT/MurSchol Packages;
- `.AppImage` → ejecución Linux;
- Flatpak → integración con repositorio configurado.

El gestor de aplicaciones deberá comprobar compatibilidad y dependencias antes de ejecutar cambios destructivos.

## Distribución y repositorios

Se prevén canales propios separados para minimizar errores y conservar estabilidad:

- `stable/core` — componentes esenciales de MurSchol;
- `stable/apps` — aplicaciones aprobadas;
- `stable/updates` — correcciones y seguridad;
- `testing` — candidatos a próxima versión;
- `experimental` — integración y compatibilidad en pruebas.

Los repositorios externos no se habilitarán silenciosamente. Deberán mostrar origen, nivel de confianza y permitir desactivación.

## Filosofía

MurSchol toma como referencias de diseño la simplicidad de sistemas centrados en una experiencia única, la eficiencia de sistemas alternativos ligeros, los gestores de repositorios bien separados y el despliegue automatizado mediante perfiles. No pretende copiar su interfaz ni su código: estas ideas se reinterpretan para un entorno académico, offline-first y de bajos recursos.

Consulta también `docs/DESKTOP_VISION.md` y `docs/REPOSITORY_POLICY.md`.
