# Referencias para construcción y personalización de imágenes MurSchol OS

MurSchol OS mantiene como base de producción **Debian 13 + live-build + configuración versionada en Git + GitHub Actions**. Las herramientas y proyectos revisados aquí sirven como referencias históricas o técnicas, no como sustitutos automáticos del pipeline actual.

## Criterio de decisión

La construcción de MurSchol debe ser:

- reproducible desde un repositorio limpio;
- declarativa: paquetes, hooks y archivos incluidos están versionados;
- auditable: no depende del estado accidental de una máquina personal;
- automatizable en CI;
- capaz de producir checksum y artefacto por build;
- fácil de extender a instalador, canales Stable/Preview/Nightly y, más adelante, ARM64.

Por estas razones seguimos prefiriendo `live-build` para la ISO de PC.

## AryaLinux

AryaLinux fue una distribución basada en Linux From Scratch, con gestión de paquetes estilo ports y el gestor `alps`. DistroWatch la marca actualmente como **discontinuada**; su última versión listada es de 2020.

Qué aporta como referencia:

- demuestra cuánto control se obtiene construyendo una distribución desde componentes muy bajos;
- es útil para entender cómo una distro puede crear identidad propia incluso sin basarse directamente en Debian/Ubuntu;
- sirve para estudiar separación entre sistema base, scripts de construcción y selección de escritorio.

Qué no haremos:

- no migraremos MurSchol a LFS;
- no construiremos nuestro propio gestor de paquetes durante la alpha;
- no abandonaremos el ecosistema Debian, APT y sus actualizaciones de seguridad.

La relación coste/beneficio sería negativa para nuestro objetivo actual: MurSchol quiere controlar la experiencia de escritorio, no rehacer toda la distribución desde cero.

## SUSE Studio / Studio Express

`openSUSE/studioexpress-landing` es el repositorio de la página de transición de SUSE Studio Express. El propio historial del repositorio deja claro que el antiguo SUSE Studio dejó de ser el producto vigente y la iniciativa se trasladó a herramientas de construcción posteriores del ecosistema SUSE.

Idea que sí interesa:

- describir una imagen mediante una configuración reproducible y construir variantes de forma automatizada;
- separar selección de paquetes, identidad, configuración y formato de salida;
- pensar en perfiles de imagen, por ejemplo MurSchol Básico / Completo / Desarrollo.

No tiene sentido integrar `studioexpress-landing`: es una página web histórica, no un motor de construcción de imágenes.

## chamuco/respin

Este proyecto es un fork de Remastersys para crear copias/respins de distribuciones instaladas. Su README documenta soporte antiguo para Ubuntu/Mint y señala límites como imágenes de 4 GB. La actividad principal visible del repositorio se remonta a 2016.

Ventaja conceptual:

- convertir un sistema ya personalizado en una Live ISO puede ser cómodo para prototipos personales.

Problema para MurSchol:

- un respin puede heredar estado residual, paquetes instalados a mano y configuración no documentada;
- es más difícil garantizar que dos builds desde cero sean equivalentes;
- el proyecto está demasiado desactualizado para convertirlo en pieza crítica de Debian 13.

Conclusión: **no integrar**.

## AB9IL/Linux-Respinner

Linux-Respinner es más actual que `chamuco/respin` y mantiene scripts para extraer imágenes Debian/Ubuntu/Mint, entrar en `chroot`, cambiar paquetes/archivos y volver a generar la ISO. Su historial incluye actividad en 2024 y el proyecto está bajo GPLv3.

Es una referencia útil para:

- inspeccionar técnicas de extracción de ISO y SquashFS;
- reconstrucción de imágenes con `xorriso`, `squashfs-tools` y utilidades Syslinux;
- mantenimiento de múltiples proyectos de respin;
- tareas de recuperación o modificación de una ISO existente cuando no tenemos la receta original.

Pero el flujo principal sigue siendo imperativo: extraer una imagen existente, modificar el `chroot` y volver a empaquetar. MurSchol ya dispone de una receta `live-build` versionada que parte de una base Debian limpia, lo cual es preferible para producción.

Decisión:

- **no sustituir live-build**;
- usar Linux-Respinner únicamente como referencia técnica y posible herramienta de laboratorio/recuperación;
- si se reutiliza código GPLv3 en el futuro, mantenerlo claramente separado y cumplir su licencia.

## Arquitectura de build de MurSchol

```text
Git repository
   |
   +-- desktop/os/live/config
   |      +-- package lists
   |      +-- includes.chroot
   |      +-- hooks
   |      +-- session + labwc
   |
   +-- desktop/os/shell
   +-- desktop/apps/*
   |
   v
Debian live-build
   |
   +-- instala dependencias
   +-- compila componentes MurSchol
   +-- configura sesión Live
   +-- genera SquashFS / ISO híbrida
   |
   v
GitHub Actions
   |
   +-- valida build
   +-- calcula SHA-256
   +-- publica artefacto
```

## Mejoras derivadas de estas referencias

1. Mantener `live-build` como builder canónico.
2. Añadir posteriormente perfiles de imagen (`minimal`, `standard`, `complete`, `dev`) sin duplicar toda la configuración.
3. Crear un manifiesto de build legible por máquina con versión de Debian, paquetes MurSchol y commit de origen.
4. Incluir el commit SHA y canal (`Preview`, luego `Stable`/`Nightly`) en `/etc/os-release` o un archivo MurSchol específico.
5. Conservar checksum de cada ISO y, más adelante, firma criptográfica de releases.
6. Añadir smoke tests automáticos de la imagen cuando la infraestructura lo permita.
7. Mantener una ruta documentada para reconstruir una ISO desde cero en una máquina Debian limpia.

## Referencias revisadas

- https://distrowatch.com/table.php?distribution=arya
- https://github.com/openSUSE/studioexpress-landing
- https://github.com/chamuco/respin
- https://github.com/AB9IL/Linux-Respinner
