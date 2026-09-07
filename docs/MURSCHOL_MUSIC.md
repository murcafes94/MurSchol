# MurSchol Music

MurSchol Music es la biblioteca musical universal de MurSchol. Su objetivo no es depender de un único servicio de streaming, sino combinar de forma modular música local, servidor personal, radio y proveedores externos opcionales.

## Principios

1. **Local-first**: la música del dispositivo debe funcionar sin Internet.
2. **Apertura rápida**: la interfaz aparece primero; el indexado de la biblioteca ocurre en segundo plano.
3. **Sin encerrar archivos**: la biblioteca organiza los archivos donde ya están.
4. **Motor compartido**: la reproducción se apoya en MurSchol Media/libmpv para no duplicar códecs ni lógica de reproducción.
5. **Proveedores aislados**: radio, OpenSubsonic y servicios externos no forman parte inseparable del núcleo.
6. **Sin eludir DRM ni restricciones de servicios**: los conectores externos deben respetar APIs, términos y derechos aplicables.

## Arquitectura

```text
MurSchol Music
│
├── Biblioteca local
│   ├── MP3
│   ├── FLAC
│   ├── WAV
│   ├── OGG/Opus
│   └── M4A/AAC
│
├── Mi servidor
│   └── OpenSubsonic / Navidrome
│
├── Radio
│   └── proveedor de emisoras por Internet
│
├── Servicios
│   └── proveedores/plugins opcionales
│
└── Reproducción
    └── MurSchol Media / libmpv
```

## Fase 0.1

La primera base implementa:

- ejecutable `murschol-music` en Qt 6/QML;
- biblioteca local que explora la carpeta Música de forma asíncrona;
- búsqueda por título, artista o álbum;
- formatos locales MP3, FLAC, WAV, OGG/OGA, Opus, M4A, AAC y WMA;
- reproducción delegada a `murschol-media`;
- interfaz preparada para Este dispositivo, Mi servidor, Radio y Servicios;
- separación clara entre núcleo local y proveedores futuros.

En esta fase los metadatos se deducen de nombre de archivo y carpeta. La lectura real de tags y portadas se añadirá después mediante una capa especializada para no ralentizar la primera apertura.

## Próximas fases

### Biblioteca local

- leer tags reales: título, artista, álbum, género, año y número de pista;
- extraer portadas de forma diferida;
- vistas Álbumes, Artistas, Géneros, Listas y Favoritos;
- cola de reproducción y listas persistentes;
- gapless playback y ReplayGain;
- letras locales `.lrc` y letras por proveedor opcional;
- integración MPRIS con el panel de MurSchol.

### Servidor personal

- cliente OpenSubsonic;
- conexión con Navidrome y servidores compatibles;
- caché opcional para escuchar sin conexión;
- sincronización de favoritos, listas e historial cuando el servidor lo permita.

### Radio

- proveedor de emisoras independiente;
- búsqueda por país, idioma y género;
- favoritos y recientes;
- reproducción del stream mediante el mismo motor multimedia.

### Servicios y plugins

Inspirado conceptualmente en proyectos como Spotube, Nuclear y muffon, MurSchol Music tendrá una interfaz de proveedores. Un proveedor podrá aportar una o varias capacidades:

- búsqueda;
- streaming autorizado;
- metadatos;
- letras;
- recomendaciones;
- scrobbling.

La caída o retirada de un proveedor no debe impedir que funcionen la biblioteca local, el servidor personal ni la radio.

## Regla de rendimiento

MurSchol Music no debe bloquear el arranque esperando a que termine el indexado. La ventana aparece primero y la exploración de la carpeta Música se ejecuta en segundo plano. Portadas, tags complejos y servicios online se cargarán después y bajo demanda.
