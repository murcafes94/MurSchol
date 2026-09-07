# MurSchol Settings — Energía

La página **Energía** sigue el criterio visual de MurSchol Settings: presentación inspirada en Windows 11, claridad operativa cercana a Windows 10 y controles visibles solo cuando tienen un backend real.

## Arquitectura 0.1

```text
MurSchol Settings
      |
 PowerBackend (Qt 6 / C++20)
      |
 +----+----------------+----------------+
 |                     |                |
UPower             brightnessctl      logind
batería/AC          brillo             suspensión
```

## Implementado

### Batería

- Detectar UPower en el bus del sistema.
- Detectar batería real o DisplayDevice de UPower.
- Mostrar porcentaje.
- Mostrar cargando, descargando, carga completa y estados pendientes.
- Mostrar tiempo restante o tiempo para completar únicamente cuando UPower lo informa.
- Diferenciar la ausencia de batería de un error; esto es importante en VirtualBox y PCs de escritorio.

### Brillo

- Detectar `brightnessctl` y un dispositivo de brillo compatible.
- Leer porcentaje actual.
- Ajustar brillo desde Settings.
- Ocultar el control si el hardware no ofrece un backlight utilizable.
- Informar si el sistema rechaza el cambio por permisos o soporte.

El mismo `PowerBackend` se comparte con la página **Pantalla** para no crear dos fuentes de verdad.

### Suspensión

- Botón **Suspender ahora** conectado a `org.freedesktop.login1.Manager.Suspend` mediante D-Bus.
- No se ejecutan comandos de shell privilegiados arbitrarios.
- systemd-logind conserva el control de permisos e inhibidores.

### Perfiles MurSchol

La página muestra el perfil compartido **Ligero / Normal / Rendimiento** usando el almacenamiento común de MurSchol.

Estos perfiles todavía no fuerzan frecuencias de CPU o GPU. Actualmente coordinan preferencias del shell y de las aplicaciones que ya consultan el perfil común.

## Pendiente

- Apagar pantalla automáticamente tras un intervalo.
- Suspender automáticamente tras un intervalo.
- Políticas distintas con batería y corriente.
- Acción al cerrar la tapa.
- Servicio de sesión pequeño que aplique esas políticas aun cuando Settings esté cerrado.
- Evaluar `power-profiles-daemon` o `platform_profile` únicamente si aporta valor en hardware compatible.

No se mostrarán selectores de temporización o tapa hasta que exista el servicio que realmente los aplique.

## Validación pendiente

1. VirtualBox: confirmar que la ausencia de batería se representa correctamente y que `Suspend` no rompe la sesión de prueba.
2. Portátil real: batería, tiempo estimado, brillo y suspensión.
3. Verificar permisos de `brightnessctl` en Debian 13 sobre hardware físico.
4. Comprobar comportamiento con varios controladores de backlight.
