# Política de repositorios de MurSchol OS

MurSchol OS utilizará una política de software conservadora: pocos repositorios activos, orígenes claramente identificados y canales separados según estabilidad.

## Objetivos

- mantener estabilidad en equipos de uso diario;
- reducir conflictos de dependencias;
- hacer comprensible de dónde procede cada paquete;
- permitir probar software nuevo sin contaminar el canal estable;
- facilitar actualizaciones y recuperación;
- minimizar descargas repetidas mediante caché segura.

## Canales MurSchol

### `stable/core`

Componentes esenciales del sistema:

- MurSchol Desktop;
- servicios MurSchol;
- configuraciones del sistema;
- integración con Wayland;
- herramientas de recuperación.

Este canal debe cambiar lentamente.

### `stable/apps`

Aplicaciones mantenidas o verificadas para MurSchol.

### `stable/updates`

Correcciones de errores y seguridad para paquetes ya publicados en estable.

### `testing`

Candidatos a la siguiente versión estable. Puede contener cambios incompatibles y no se habilita por defecto en equipos normales.

### `experimental`

Integraciones en prueba, controladores especiales y prototipos. Nunca se activa automáticamente.

## Repositorios externos

MurSchol puede permitir repositorios de terceros, pero aplicará estas reglas:

1. el usuario debe aceptar expresamente su incorporación;
2. el sistema muestra proveedor, URL, firma y nivel de confianza;
3. un repositorio externo puede deshabilitarse sin romper el sistema base;
4. el sistema advertirá cuando dos repositorios pretendan sustituir el mismo componente crítico;
5. no se habilitarán decenas de repositorios por defecto;
6. los componentes esenciales de MurSchol tendrán prioridad sobre repositorios opcionales salvo elección avanzada consciente.

## Seguridad

- paquetes y metadatos deben verificarse criptográficamente;
- las claves de firma se distribuyen mediante el sistema base o un mecanismo verificable;
- actualizaciones críticas no deben depender de scripts remotos ejecutados sin validación;
- MurSchol App Manager debe mostrar el origen antes de instalar software no oficial.

## Caché local

Inspirado en sistemas de despliegue que conservan imágenes o artefactos para instalaciones posteriores, MurSchol podrá mantener una caché local limitada de:

- paquetes descargados recientemente;
- componentes opcionales de Android/Windows;
- actualizaciones pendientes;
- metadatos de la tienda.

La caché tendrá límites por tamaño y podrá limpiarse desde Configuración.

## Instalación declarativa por perfiles

La instalación y recuperación podrán describirse mediante perfiles, por ejemplo:

```yaml
profile: basic
components:
  - murschol-desktop
  - network
  - audio
  - files
  - browser
optional:
  android: false
  windows: false
```

Un perfil `complete` podrá activar Android y Windows. Un perfil personalizado podrá elegir componentes de forma individual.

La intención es que una reinstalación futura sea reproducible y no dependa de una larga secuencia manual de pasos.

## Base Debian

La primera base estable prevista es Debian 13 minimal. Los repositorios Debian oficiales siguen siendo la fuente principal del sistema base. Los repositorios MurSchol contendrán principalmente nuestra capa de escritorio, configuración, integraciones y paquetes propios.

No se pretende duplicar todo Debian en infraestructura propia durante las primeras fases.
