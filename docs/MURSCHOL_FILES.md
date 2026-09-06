# MurSchol Files — visión y arquitectura

MurSchol Files será el gestor de archivos propio de MurSchol OS. La meta no es copiar el Explorador de Windows, Finder, Dolphin, Thunar, PCManFM u otros gestores, sino combinar sus mejores patrones con una interfaz ligera y coherente con el resto del sistema.

## Principios

1. **Rápido en equipos modestos**
   - Arranque inmediato.
   - Carga progresiva cuando una carpeta tiene muchos elementos.
   - Miniaturas bajo demanda.
   - Nada de indexación pesada obligatoria en segundo plano.

2. **Fácil para quien viene de Windows o macOS**
   - Barra lateral de ubicaciones.
   - Barra de ruta clara.
   - Lista y cuadrícula.
   - Pestañas.
   - Panel de vista previa opcional.
   - Acciones básicas visibles: copiar, mover, renombrar, borrar, nueva carpeta.

3. **Potente sin verse recargado**
   - Vista dividida opcional al estilo de los gestores de doble panel.
   - Búsqueda local rápida.
   - Ordenación y filtros.
   - Acceso a dispositivos externos y ubicaciones de red.
   - Favoritos y etiquetas.
   - Acciones rápidas mediante teclado para usuarios avanzados sin obligar a usarlas.

4. **Integración MurSchol**
   - Accesos directos a NotCan, Biblioteca y futuras carpetas de MurSchol Cloud.
   - Abrir PDFs con el visor preferido del usuario.
   - Compartir archivos con las aplicaciones del sistema sin convertir Files en un visor universal pesado.
   - Posible vista de proyecto/estudio para carpetas de materias, trabajos y recursos.

## Referencias de diseño

### Windows 11 File Explorer

Tomamos:
- navegación familiar;
- barra de ruta y búsqueda separadas;
- barra lateral clara;
- pestañas;
- acciones frecuentes visibles;
- presentación limpia de nombre, fecha y tamaño.

No copiamos la interfaz ni sus recursos visuales.

### macOS Finder

Tomamos:
- simplicidad de la barra lateral;
- vista de iconos/lista;
- panel de vista previa;
- favoritos y etiquetas como organización complementaria.

### Dolphin

Tomamos como referencia funcional:
- pestañas;
- vista dividida;
- previsualizaciones;
- ubicaciones de red;
- alta capacidad sin obligar a mostrar todas las herramientas a la vez.

### Thunar / PCManFM

Tomamos:
- velocidad;
- bajo consumo;
- comportamiento predecible;
- dependencia mínima.

Thunar permanece temporalmente en la Live ISO como respaldo mientras MurSchol Files madura.

### XDA — comparación de gestores Linux

El artículo de XDA “6 free file managers on Linux that are better than anything on Windows” compara Midnight Commander, Konqueror, Treemacs, Thunar, Yazi y Dolphin. Lo usamos como referencia de patrones, no como ranking definitivo.

Ideas que sí encajan con MurSchol Files:

- **Midnight Commander**: navegación de doble panel y operaciones rápidas con teclado. MurSchol adoptará esto como vista dividida opcional, no como interfaz principal.
- **Yazi**: navegación extremadamente rápida y orientada a teclado. MurSchol incorporará atajos y una futura paleta de acciones sin convertir el gestor en una aplicación de terminal.
- **Dolphin**: equilibrio entre vista dividida, pestañas, red, previsualización y potencia. Es la principal referencia funcional avanzada.
- **Thunar**: ligereza y previsibilidad. Es la referencia de consumo y sencillez.
- **Treemacs**: árbol de proyecto persistente. Puede inspirar una futura vista “Proyecto/Estudio” para materias, trabajos o repositorios sin hacerla obligatoria para el usuario normal.
- **Konqueror**: demuestra el valor de integrar navegación y servicios, pero MurSchol Files mantendrá navegador web y gestor de archivos como aplicaciones separadas para reducir complejidad y consumo.

Fuente de referencia: https://www.xda-developers.com/free-file-managers-on-linux-that-are-better-than-anything-on-windows/

### Comunidad Linux

La comunidad suele dividir las preferencias entre gestores muy completos como Dolphin y opciones ligeras como Thunar/PCManFM. Para MurSchol esto refuerza una decisión: ofrecer una experiencia básica limpia y rápida, con funciones avanzadas opcionales y progresivas.

## Funciones por fases

### Fase 0.1 — ya iniciada

- navegación por carpetas;
- Inicio, Documentos, Descargas, Imágenes, Música y Videos;
- barra de ruta;
- búsqueda dentro de la carpeta actual;
- vista lista;
- vista cuadrícula;
- tamaño y fecha de modificación;
- iconos por tipo de archivo;
- crear carpeta;
- abrir archivos con la aplicación asociada;
- asociación `inode/directory` con MurSchol Files.

### Fase 0.2

- selección simple y múltiple;
- copiar, cortar, pegar, mover, renombrar y borrar;
- confirmación segura para operaciones destructivas;
- historial atrás/adelante;
- arrastrar y soltar;
- barra de progreso de operaciones grandes;
- atajos de teclado consistentes;
- panel de vista previa opcional para imágenes, PDF, texto, audio y video sin cargar el archivo completo cuando no sea necesario.

### Fase 0.3

- pestañas;
- vista dividida;
- favoritos;
- etiquetas;
- dispositivos USB y discos externos;
- papelera;
- compresión y extracción mediante herramientas del sistema;
- miniaturas con caché limitada;
- paleta de acciones para usuarios avanzados.

### Fase 0.4

- SMB/Samba;
- WebDAV;
- SFTP;
- MurSchol Cloud / Nextcloud cuando el proyecto de nube privada esté listo;
- integración con Biblioteca y NotCan;
- vista opcional Proyecto/Estudio inspirada en árboles de proyecto.

## Decisiones de rendimiento

- El gestor seguirá en **Qt 6 / C++20**.
- Las miniaturas tendrán caché limitada y serán opcionales en perfil Ligero.
- El panel de vista previa se podrá desactivar.
- Las operaciones grandes se harán en segundo plano con progreso y cancelación.
- La vista dividida no implicará duplicar procesos completos.
- No se instalará un indexador de contenido pesado por defecto.
- Las funciones avanzadas estarán desacopladas para no penalizar el arranque básico.

## Navegadores y archivos

MurSchol Files debe abrir carpetas directamente. No debe depender de `xdg-open` para abrir la carpeta personal, porque una asociación MIME incorrecta podría enviar una carpeta al navegador. `xdg-open` se reservará como respaldo y para abrir archivos con su aplicación registrada.
