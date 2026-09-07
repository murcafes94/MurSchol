# MurSchol Photos — visión y primera implementación

MurSchol Photos será el visor de imágenes ligero de MurSchol OS. Su prioridad es abrir una imagen con rapidez y mostrar únicamente los controles necesarios. Las funciones secundarias se cargan o muestran bajo demanda.

## Formatos prioritarios

- JPG / JPEG
- PNG
- GIF animado
- SVG
- WebP

## Principio de rendimiento

**Abrir primero, cargar después.**

Al abrir una imagen desde MurSchol Files, Photos debe mostrar el archivo antes de generar miniaturas, leer metadatos avanzados o recorrer toda la carpeta. La navegación anterior/siguiente se prepara después de la primera apertura.

## Interfaz

La vista principal mantiene la imagen como protagonista:

- barra superior compacta;
- anterior / siguiente;
- zoom y ajustar a ventana;
- botón de Información;
- botón Editar;
- panel lateral de información oculto por defecto;
- sin biblioteca fotográfica pesada en la primera fase.

## Información de imagen

El panel `ⓘ` puede mostrar, cuando exista:

- nombre;
- formato;
- dimensiones;
- tamaño del archivo;
- fecha de modificación;
- ubicación;
- EXIF de cámara;
- ISO, exposición, apertura y focal;
- GPS;
- espacio de color;
- información específica de SVG/GIF cuando corresponda.

Los metadatos avanzados no deben bloquear la apertura inicial.

## Edición básica

Objetivo de la primera línea de edición:

- recortar;
- enderezar;
- girar 90°;
- voltear;
- rayar/dibujar;
- deshacer/rehacer;
- guardar una copia por defecto para proteger el original.

La alpha actual ya incorpora los controles y previsualización de giro, enderezado, marco de recorte y dibujo. El guardado destructivo/no destructivo de estas operaciones se implementará en la siguiente fase del backend.

## Estado técnico 0.1

Implementado en `desktop/apps/photos/`:

- aplicación Qt 6 / C++20 independiente;
- apertura directa de una ruta de imagen desde línea de comandos;
- lectura ligera de formato, dimensiones, tamaño y fecha;
- JPG/JPEG, PNG, GIF, SVG y WebP como formatos reconocidos;
- GIF con reproducción animada en la interfaz;
- navegación anterior/siguiente por imágenes de la misma carpeta;
- zoom;
- rotación visual;
- panel de información ocultable;
- modo de edición visual con enderezado, recorte y dibujo como base de interacción.

## Próxima fase

- guardar ediciones en una copia;
- recorte real sobre la imagen;
- enderezado con remuestreo de calidad;
- dibujo persistente;
- deshacer/rehacer;
- lectura EXIF diferida;
- asociación MIME desde MurSchol Files y MurSchol OS;
- pruebas con imágenes grandes y carpetas con cientos/miles de elementos;
- política de caché según perfiles Ligero / Normal / Rendimiento.
