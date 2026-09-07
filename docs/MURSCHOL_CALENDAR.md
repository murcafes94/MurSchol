# MurSchol Calendar

MurSchol Calendar es el calendario local-first de MurSchol OS. La aplicación debe funcionar completamente sin conexión y tratar la sincronización como una capacidad opcional, no como un requisito para crear o consultar eventos.

## Objetivos

- Vistas Hoy, Semana, Mes y Agenda.
- Eventos normales y de todo el día.
- Calendarios separados como Personal, Estudio y Trabajo.
- Recordatorios sin necesidad de mantener la ventana del calendario abierta.
- Datos locales persistentes mediante SQLite.
- Importación/exportación iCalendar (`.ics`).
- Sincronización futura mediante CalDAV, incluyendo Nextcloud.
- Interfaz rápida, sobria y coherente con MurSchol Desktop.

## Primera implementación 0.1

La primera base vive en `desktop/apps/calendar/` y crea el ejecutable `murschol-calendar` con Qt 6/C++20 y QML.

Incluye actualmente:

- vista mensual navegable;
- selección de día;
- agenda diaria;
- creación y eliminación de eventos;
- eventos de todo el día;
- hora de inicio y fin;
- categorías Personal, Estudio y Trabajo;
- notas;
- minutos de anticipación para un recordatorio;
- persistencia local en SQLite bajo la carpeta de datos de la aplicación.

Los minutos de recordatorio ya se almacenan, pero **todavía no existe un servicio en segundo plano que emita las notificaciones**. Esa pieza se implementará aparte para que Calendar pueda cerrarse sin perder avisos.

## Arquitectura prevista

```text
MurSchol Calendar
      |
      +-- interfaz Qt/QML
      |
      +-- Calendar Core
      |      |
      |      +-- SQLite local
      |      +-- recurrencias
      |      +-- iCalendar (.ics)
      |
      +-- Reminder Service
      |      |
      |      +-- notificaciones del sistema
      |
      +-- Sync Providers (opcionales)
             |
             +-- CalDAV
             +-- Nextcloud
             +-- otros proveedores futuros
```

## Recordatorios

El servicio de recordatorios debe ser pequeño y separado de la ventana principal. Su responsabilidad será consultar los próximos avisos y emitir una notificación del sistema en el momento adecuado. No debe mantener la interfaz ni una instancia completa de QML cargada en memoria.

## Sincronización

CalDAV será la primera opción porque evita ligar MurSchol Calendar a un proveedor concreto y permite trabajar con servidores propios, Nextcloud y otros servicios compatibles.

La sincronización nunca debe bloquear el acceso al calendario local. Si el servidor no responde, los eventos locales siguen disponibles y los cambios pendientes se sincronizan después.

## Próximos pasos

1. Añadir edición de eventos existentes.
2. Añadir recurrencias diarias, semanales, mensuales y anuales.
3. Crear vistas Semana y Agenda global.
4. Implementar `murschol-reminder-service`.
5. Exportar e importar `.ics`.
6. Implementar CalDAV.
7. Añadir drag & drop para mover eventos.
8. Validar zonas horarias y eventos con hora UTC/local.
9. Integrar notificaciones y accesos rápidos con MurSchol Desktop.
10. Integrar en la Live ISO solo después de validar persistencia y recordatorios.
