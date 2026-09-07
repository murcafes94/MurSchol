# MurSchol Network — Red e Internet

La primera integración nativa de red vive dentro de **MurSchol Settings**. El objetivo es que la configuración habitual de Wi‑Fi se pueda hacer desde la interfaz MurSchol sin duplicar ni reemplazar a NetworkManager.

## Arquitectura 0.1

```text
MurSchol Settings
      |
NetworkBackend (Qt 6 / C++20)
      |
Qt DBus
      |
NetworkManager
      |
Wi‑Fi / conexiones guardadas / conectividad
```

NetworkManager continúa siendo la fuente de verdad. MurSchol no mantiene una segunda base de redes ni guarda contraseñas en su propio archivo de preferencias.

## Funciones implementadas

- Detectar si NetworkManager está disponible en el bus del sistema.
- Detectar adaptador Wi‑Fi y nombre de interfaz.
- Leer estado global de red y Wi‑Fi.
- Activar/desactivar Wi‑Fi mediante la propiedad real de NetworkManager.
- Solicitar escaneo de redes por D‑Bus.
- Enumerar puntos de acceso visibles.
- Mostrar SSID, intensidad, seguridad y banda aproximada.
- Identificar la red activa.
- Mostrar IPv4 de la interfaz activa.
- Mostrar el estado de conectividad de NetworkManager: sin conexión, portal cautivo, limitada o Internet disponible.
- Detectar redes Wi‑Fi ya guardadas en NetworkManager.
- Activar por D‑Bus una conexión Wi‑Fi previamente guardada.
- Desconectar la interfaz Wi‑Fi activa.
- Mantener `nm-connection-editor` como respaldo para crear perfiles nuevos, introducir contraseñas, VPN, DNS manual y opciones avanzadas durante esta fase.

## Seguridad

MurSchol Network **no copia contraseñas Wi‑Fi** a `~/.config/murschol/settings.ini`. Los secretos siguen siendo responsabilidad de NetworkManager y de su agente de secretos.

La primera fase tampoco pasa contraseñas por argumentos de shell. Las redes nuevas protegidas se configuran con el editor oficial de NetworkManager hasta implementar un agente de secretos/flujo D‑Bus adecuado.

## Rendimiento

- No se crea un daemon adicional.
- El backend existe únicamente mientras MurSchol Settings está abierto.
- El estado se refresca periódicamente con un intervalo moderado.
- El escaneo se solicita solo cuando el usuario lo pide o NetworkManager lo actualiza por su cuenta.
- Las redes con el mismo SSID se agrupan mostrando el punto de acceso de mayor señal, priorizando siempre el AP activo.

## Pendiente

1. Conectar redes nuevas protegidas desde MurSchol mediante un flujo de secretos seguro.
2. Ethernet: estado, velocidad, dirección y activar/desactivar perfiles guardados.
3. Redes guardadas: olvidar, prioridad y autoconexión.
4. IP/DNS manual y automático.
5. VPN.
6. Proxy del sistema.
7. Soporte de varias interfaces Wi‑Fi en vez de priorizar la primera.
8. Actualización reactiva mediante señales D‑Bus para reducir todavía más el sondeo.
9. Pruebas reales en VirtualBox y hardware físico antes de considerar terminada la página de Red.
