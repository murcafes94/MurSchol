# MurSchol Storage

MurSchol Settings incorpora una página nativa de **Almacenamiento** orientada a equipos de escritorio y portátiles, manteniendo el principio del proyecto: mostrar información real, evitar controles simulados y no exigir un daemon propio.

## Objetivos

- Mostrar uso total, usado y libre del almacenamiento del sistema.
- Detectar particiones y volúmenes mediante `lsblk` y `QStorageInfo`.
- Distinguir sistema, discos internos y medios extraíbles.
- Abrir volúmenes montados desde el gestor de archivos predeterminado.
- Montar y desmontar dispositivos mediante `udisksctl`/UDisks2 cuando esté disponible.
- Ofrecer una limpieza segura y explícita.

## Backend

`StorageBackend` vive dentro de `desktop/apps/settings/` y utiliza:

- `lsblk` para inventario de dispositivos de bloque, tamaño, sistema de archivos, transporte y puntos de montaje.
- `QStorageInfo` para espacio usado/libre de volúmenes montados.
- `udisksctl` para montar y desmontar con las políticas de UDisks2/Polkit del sistema.
- `QDesktopServices` para abrir un punto de montaje sin acoplar Settings a MurSchol Files.

No se guarda información sensible ni se requiere ejecutar MurSchol Settings como root.

## Limpieza segura

La primera versión solo elimina categorías de bajo riesgo:

1. **Papelera del usuario**: contenido de `~/.local/share/Trash/files` e información asociada en `~/.local/share/Trash/info`.
2. **Miniaturas temporales**: `~/.cache/thumbnails`, que puede regenerarse automáticamente.

No se elimina el contenido de `~/Documentos`, `~/Descargas`, cachés generales de aplicaciones, paquetes, logs del sistema ni datos personales sin una acción específica futura.

## Dispositivos extraíbles

La Live ISO incluye `udisks2` y `util-linux`. Cuando `udisksctl` está disponible, Settings puede ofrecer **Montar** y **Expulsar** para volúmenes que no sean la raíz del sistema. Si no está disponible, la página queda en modo informativo y no simula la acción.

## Estado alpha

La interfaz y el backend están implementados, pero deben validarse en hardware real y VirtualBox antes de considerarse estables. En VirtualBox normalmente se verá un disco virtual interno; para probar USB real hará falta passthrough del dispositivo al invitado.

## Próximos pasos

- Confirmación visual antes de vaciar la papelera cuando contenga una cantidad importante de datos.
- Integración con MurSchol Files para Papelera y dispositivos.
- Vista de categorías de almacenamiento calculada en segundo plano.
- Detección y aviso de poco espacio.
- Opción de apagar de forma segura un dispositivo USB completo después de desmontar todas sus particiones.
