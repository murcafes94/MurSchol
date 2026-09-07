# MurSchol Capture

MurSchol Capture es la utilidad ligera de capturas de MurSchol OS. Su objetivo es abrirse solo cuando se necesita, capturar rápido y terminar sin mantener procesos pesados residentes.

## Arquitectura

- `grim`: captura de pantalla Wayland/wlroots.
- `slurp`: selección interactiva de región.
- `wl-copy`: copia PNG al portapapeles.
- `notify-send`: notificación de captura guardada.
- MurSchol Photos: edición y anotación posterior.

## Flujo principal

1. `Super + Shift + S` inicia captura de región.
2. `Print Screen` captura la pantalla completa.
3. La captura se guarda como PNG en `Imágenes/Capturas de pantalla/`.
4. Si `wl-copy` está disponible, la imagen también se copia al portapapeles.
5. La interfaz permite abrir la captura en MurSchol Photos o abrir la carpeta.

También puede iniciarse la ventana `murschol-capture`, con selección de temporizador de 0, 3, 5 o 10 segundos.

## CLI

- `murschol-capture --region`
- `murschol-capture --screen`
- `murschol-capture --region --delay 5`
- `murschol-capture --screen --delay 10`

## Edición

MurSchol Capture no duplica un editor. El botón Editar abre:

`murschol-photos --annotate <archivo>`

El modo de anotación de Photos prepara lápiz, resaltador, flecha, rectángulo, texto, ocultación, deshacer y rehacer, además de recorte, giro y enderezado visual.

El guardado destructivo del original no es el objetivo. La composición final de anotaciones a resolución original y Guardar una copia se completarán en MurSchol Photos antes de considerarlo un editor definitivo.

## Próximas fases

- captura de ventana concreta;
- guardado de anotaciones a resolución original;
- pixelado real, además de ocultación sólida;
- captura con desplazamiento;
- grabación de pantalla con backend ligero compatible con wlroots;
- integración con historial de capturas.
