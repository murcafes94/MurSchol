# MurSchol OS Live 0.1

Primera imagen Live reproducible de MurSchol OS para PC x86-64.

## Objetivo de esta imagen

Esta ISO es una **alpha técnica** para comprobar que el equipo puede arrancar directamente en una sesión MurSchol basada en Debian 13 + Wayland + labwc + MurSchol Desktop. Todavía no es la edición final ni instala MurSchol en el disco.

Incluye de base:

- Debian 13 (Trixie) Live;
- kernel Linux amd64;
- labwc como compositor Wayland ligero;
- MurSchol Desktop compilado dentro del propio sistema Debian;
- NetworkManager;
- PipeWire/WirePlumber;
- Bluetooth y control básico de energía;
- Thunar, Foot y Firefox ESR;
- firmware común de Wi‑Fi.

Waydroid, Wine/Bottles y el instalador gráfico se mantienen fuera de esta primera ISO para medir el consumo del sistema básico sin capas adicionales.

## Construir

En Debian/Ubuntu con `live-build` instalado:

```bash
sudo ./desktop/os/live/build-live.sh
```

Salida esperada:

```text
MurSchol-OS-0.1-Live-amd64.iso
MurSchol-OS-0.1-Live-amd64.iso.sha256
```

GitHub Actions ejecuta el mismo proceso y publica ambos archivos como artefacto.

## Probar sin instalar

La forma más segura para la primera prueba es una máquina virtual (VirtualBox, VMware o QEMU) con:

- 2 CPU virtuales;
- 2 GB de RAM como mínimo (4 GB recomendado para probar el perfil Normal);
- EFI o BIOS;
- disco virtual opcional, ya que la ISO funciona en modo Live.

También puede escribirse la ISO a un USB con una herramienta como Rufus, Balena Etcher o Ventoy y arrancar un PC desde el USB. **No hace falta modificar el disco interno para esta prueba.**

## Qué validar

1. aparece el arranque Debian Live;
2. se crea el usuario Live `murschol`;
3. LightDM entra automáticamente en la sesión `MurSchol OS`;
4. labwc inicia Wayland;
5. MurSchol Desktop aparece maximizado;
6. funcionan Inicio, Archivos, Terminal y búsqueda local;
7. System Center muestra CPU/RAM/disco/batería;
8. Firefox y Thunar pueden abrirse desde el sistema.

Si alguno de estos pasos falla, anotar el punto exacto y, de ser posible, una foto del error para corregir la siguiente build.
