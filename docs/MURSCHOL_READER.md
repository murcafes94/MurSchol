# MurSchol Reader — visión y arquitectura

MurSchol Reader será el lector y biblioteca personal de estudio de MurSchol OS. La aplicación mostrará una sola interfaz propia y seleccionará internamente el motor adecuado según el formato.

## Principio central

**Abrir primero, cargar después.**

Al abrir un documento desde MurSchol Files, la lectura no debe esperar a que se actualicen portadas, metadatos, miniaturas, colecciones o índices secundarios. El documento visible tiene prioridad y el resto del trabajo se realiza bajo demanda o en segundo plano.

## Arquitectura prevista

```text
MurSchol Reader
├── interfaz Qt/QML propia
├── biblioteca local SQLite
├── motor PDF
│   └── Poppler/Qt como primera opción
├── motor eBook
│   └── foliate-js como primera opción a evaluar
└── Calibre opcional
    └── conversión, metadatos masivos y gestión avanzada
```

Calibre no participa en la ruta normal de apertura. Un EPUB, MOBI o AZW3 debe poder abrirse directamente en MurSchol Reader sin iniciar Calibre.

## Biblioteca

La biblioteca será una capa de organización sobre los archivos reales y no un contenedor propietario. Campos previstos:

- título;
- subtítulo;
- autor;
- año;
- editorial;
- ISBN;
- idioma;
- descripción;
- portada;
- formato;
- ruta del archivo;
- número de páginas o posiciones;
- progreso;
- última apertura;
- favorito;
- colecciones;
- etiquetas;
- marcadores;
- subrayados;
- anotaciones.

## Interfaz de lectura

Durante la lectura, el documento debe ocupar casi toda la ventana.

### Barra superior

Controles principales:

- volver a biblioteca;
- abrir Contenido;
- página/progreso;
- buscar;
- imprimir;
- zoom cuando corresponda;
- abrir Mis marcas;
- modo concentración;
- menú adicional.

### Panel de Contenido

Oculto por defecto. Se abre desde un botón y se desliza desde la izquierda.

Incluye:

- índice;
- capítulos;
- miniaturas cuando correspondan;
- marcadores;
- búsqueda dentro del índice.

### Panel Mis marcas

Oculto por defecto. Se abre desde un botón y se desliza desde la derecha.

Incluye:

- subrayados;
- notas;
- marcadores.

En pantallas pequeñas ambos paneles aparecen sobre el documento. En monitores grandes podrá evaluarse posteriormente una opción para anclarlos.

### Modo concentración

`F11` oculta la barra principal y deja el documento prácticamente solo. `Esc` o `F11` restaura la interfaz. Los controles no deben distraer cuando no se usan.

## Motores

### PDF

Primera opción: Poppler con integración Qt.

Funciones previstas:

- renderizado bajo demanda;
- búsqueda;
- índice;
- enlaces;
- selección y copia;
- anotaciones;
- rotación;
- página simple/doble;
- ajuste a página/ancho;
- miniaturas bajo demanda;
- impresión avanzada.

### eBook

Primera opción a evaluar: foliate-js.

Formatos objetivo iniciales:

- EPUB;
- MOBI;
- AZW/AZW3;
- FB2;
- CBZ.

Funciones previstas:

- fuente;
- tamaño de texto;
- interlineado;
- márgenes;
- paginado o continuo;
- tema claro/sepia/oscuro;
- búsqueda;
- marcadores;
- progreso.

KOReader queda como referencia funcional y posible respaldo. Otros motores nativos podrán evaluarse si ofrecen mejor rendimiento o integración C++/Qt.

## Perfiles de rendimiento

### Ligero

- mínimo número de páginas precargadas;
- miniaturas únicamente al solicitarlas;
- caché reducida;
- animaciones mínimas.

### Normal

- precarga moderada;
- caché equilibrada;
- miniaturas progresivas.

### Rendimiento

- mayor precarga y caché;
- desplazamiento más fluido;
- trabajo anticipado de páginas próximas.

Los valores reales se fijarán después de pruebas en hardware.

## Impresión PDF avanzada

MurSchol Reader tendrá su propio centro de impresión sobre Qt PrintSupport/CUPS. Objetivo funcional similar al nivel de control de Adobe Reader, sin depender de sus componentes.

Funciones previstas:

- impresora;
- todas / página actual / rangos;
- páginas pares/impares;
- orden inverso;
- tamaño real;
- ajustar al área imprimible;
- escala personalizada;
- A4/Carta y otros tamaños;
- orientación;
- varias páginas por hoja;
- modo folleto;
- dúplex automático o manual;
- copias e intercalado;
- color / grises / blanco y negro cuando el controlador lo permita;
- vista previa en tiempo real;
- imprimir con o sin anotaciones.

## Estado de implementación

### 0.1 — iniciada

- [x] Esqueleto Qt 6/QML separado en `desktop/apps/reader`.
- [x] Biblioteca visual inicial.
- [x] Apertura visual biblioteca → modo lector.
- [x] Panel Contenido ocultable desde botón.
- [x] Panel Mis marcas ocultable desde botón.
- [x] Modo concentración con F11/Esc.
- [x] Controles preliminares de zoom, búsqueda e impresión.
- [ ] Integrar Poppler y renderizar PDF real.
- [ ] Integrar el motor eBook.
- [ ] Crear base SQLite real de biblioteca.
- [ ] Persistir progreso, marcadores y anotaciones.
- [ ] Implementar MurSchol Print Center.
- [ ] Asociar formatos desde MurSchol Files.
- [ ] Integrar Reader en la Live ISO cuando la primera lectura real esté validada.
