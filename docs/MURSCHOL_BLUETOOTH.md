# MurSchol Bluetooth

La página **Bluetooth** de MurSchol Settings usa BlueZ como fuente de verdad. MurSchol no mantiene una base paralela de dispositivos.

## Arquitectura 0.1

```text
MurSchol Settings
      |
BluetoothBackend (Qt 6 / C++20)
      |
Qt DBus
      |
BlueZ
      |
adaptador / dispositivos
```

## Funciones implementadas

- detectar el servicio `org.bluez` en el bus del sistema;
- localizar el primer adaptador `hci*` disponible;
- leer nombre, estado de encendido y estado de descubrimiento;
- encender/apagar el adaptador mediante `org.bluez.Adapter1`;
- iniciar y detener descubrimiento;
- enumerar dispositivos conocidos/descubiertos;
- mostrar nombre, dirección, estado emparejado, conectado y confiable;
- conectar y desconectar dispositivos ya emparejados mediante `org.bluez.Device1`;
- cambiar la propiedad `Trusted` desde el backend cuando sea necesario;
- conservar Blueman como flujo avanzado para emparejamientos que requieran agente, PIN o confirmación.

## Seguridad y emparejamiento

MurSchol 0.1 **no implementa todavía un agente BlueZ propio**. Por eso no simulamos un cuadro de PIN dentro de Settings. Si un dispositivo no está emparejado, la interfaz abre el administrador de Blueman para completar el proceso con un agente de emparejamiento real.

Cuando implementemos `org.bluez.Agent1`, podremos integrar confirmaciones, PIN/passkey y autorización directamente en MurSchol sin depender visualmente de Blueman.

## Rendimiento

BluetoothBackend solo vive mientras Settings está abierto. Refresca el estado cada cuatro segundos y no añade un daemon residente. En fases posteriores se sustituirá parte del sondeo por señales D-Bus de BlueZ.

## Pendiente

- agente BlueZ propio para emparejamiento completo;
- olvidar/eliminar dispositivos con confirmación;
- varias interfaces/adaptadores Bluetooth;
- iconos por clase de dispositivo;
- batería de auriculares/periféricos cuando BlueZ la exponga;
- perfiles de audio Bluetooth coordinados con PipeWire;
- actualización reactiva por señales D-Bus;
- pruebas en hardware real y VirtualBox con adaptador USB expuesto.
