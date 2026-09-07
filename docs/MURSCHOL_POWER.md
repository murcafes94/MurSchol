# MurSchol Settings — Energía

La página **Energía** seguirá el criterio visual de MurSchol Settings: presentación inspirada en Windows 11, claridad operativa cercana a Windows 10 y sin controles ficticios.

## Objetivo

Centralizar batería, brillo, suspensión y comportamiento energético sin duplicar la fuente de verdad del sistema.

Arquitectura prevista:

```text
MurSchol Settings
      |
 PowerBackend (Qt 6 / C++20)
      |
 +----+----------------+----------------+
 |                     |                |
UPower             brightnessctl      logind
batería/AC          brillo             suspensión/tapa
```

## Primera fase

### Batería

- Detectar presencia de batería mediante UPower.
- Mostrar porcentaje, cargando/descargando, conectado a corriente y tiempo estimado cuando UPower lo exponga.
- No inventar tiempo restante si el sistema no lo proporciona de forma fiable.

### Brillo

- Leer brillo actual.
- Ajustar brillo desde Settings.
- Mantener el control compatible con portátiles y monitores cuando el hardware exponga backlight.
- Si no existe control de brillo, la UI no mostrará un deslizador falso.

### Suspensión y pantalla

Opciones previstas:

- apagar pantalla tras un intervalo;
- suspender tras un intervalo;
- comportamiento con batería y conectado a corriente;
- al cerrar la tapa: suspender / no hacer nada, únicamente cuando systemd-logind lo permita y el hardware lo exponga.

## Perfiles MurSchol

La página Energía mostrará el perfil compartido **Ligero / Normal / Rendimiento**, pero no lo confundirá con un gobernador de CPU.

En la primera fase:

- Ligero: menos animaciones, miniaturas bajo demanda y menor actividad secundaria;
- Normal: equilibrio;
- Rendimiento: efectos completos y mayor precarga cuando corresponda.

Cualquier política de CPU, GPU o platform_profile se añadirá solo tras detectar soporte real y probarla en hardware.

## UX objetivo

```text
Energía y batería

Batería
82 % · 3 h 24 min restantes

Modo de energía
[ Ligero ] [ Normal ] [ Rendimiento ]

Pantalla
Brillo ─────────●──── 72 %

Apagar pantalla después de
[ 10 minutos ]

Suspender después de
[ 30 minutos ]

Al cerrar la tapa
[ Suspender ]
```

## Seguridad

- Settings nunca ejecutará comandos arbitrarios como root.
- Los cambios privilegiados usarán mecanismos limitados y, cuando sea necesario, Polkit.
- Los cambios de suspensión/tapa deberán respetar inhibidores de systemd-logind.

## Pendiente de validación

1. VirtualBox: comprobar qué expone UPower sin batería física.
2. Hardware real: batería, brillo, tapa y suspensión.
3. Verificar permisos de `brightnessctl` en Debian 13.
4. Evaluar integración futura con `power-profiles-daemon` o `platform_profile` solo si aporta valor sin aumentar consumo ni complejidad.
