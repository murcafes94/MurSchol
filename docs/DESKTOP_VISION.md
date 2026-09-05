# Visión de MurSchol Desktop

Este documento recoge decisiones de experiencia de usuario y funcionamiento general para MurSchol OS Desktop.

## 1. Objetivo

MurSchol Desktop debe sentirse como un sistema único, no como una distribución Linux que obliga al usuario a distinguir entre distintas capas de compatibilidad.

El principio rector es:

> Una aplicación es una aplicación. MurSchol decide por debajo cómo ejecutarla.

Por tanto, Inicio, dock, búsqueda y notificaciones no separan por defecto Linux, Android y Windows.

## 2. Escritorio diario

La pantalla principal debe ser limpia:

- fondo simple y ligero;
- barra superior pequeña;
- dock inferior centrado;
- iconos opcionales en escritorio;
- sin paneles técnicos permanentes;
- sin widgets costosos activos por defecto.

La información técnica vive en **MurSchol System Center**.

## 3. Inicio

El panel Inicio incluye:

1. buscador universal;
2. aplicaciones fijadas;
3. aplicaciones recientes;
4. documentos recientes;
5. acceso a todas las aplicaciones;
6. usuario, sesión y energía.

Las categorías pueden incluir Estudio, Productividad, Internet, Multimedia, Herramientas y Sistema.

## 4. Búsqueda universal

`Super + Espacio` abre una búsqueda central capaz de crecer por fases:

### Fase inicial
- aplicaciones instaladas;
- comandos del sistema;
- archivos por nombre.

### Fase posterior
- texto dentro de PDF/documentos indexados;
- apuntes de NotCan;
- recursos académicos locales;
- acciones rápidas;
- búsqueda web opcional cuando el usuario la permita.

El indexador debe trabajar con baja prioridad y suspenderse en perfil Ligero.

## 5. Centro de control

Un panel compacto desde la esquina superior derecha:

- Wi‑Fi;
- Bluetooth;
- volumen;
- brillo cuando exista;
- batería/energía;
- modo nocturno;
- No molestar;
- perfil de rendimiento;
- acceso a Configuración.

En equipos sin batería no se muestra batería; en escritorios sin control de brillo no se muestra ese control.

## 6. MurSchol System Center

Aplicación técnica separada del escritorio cotidiano.

Debe mostrar:

- CPU, RAM, disco y temperatura cuando el hardware lo permita;
- estado de Linux;
- estado de Waydroid;
- estado de Wine/Bottles;
- repositorios activos;
- actualizaciones;
- controladores;
- compatibilidad de aplicaciones;
- diagnósticos y reparación.

Su diseño puede inspirarse en paneles centralizados de administración, pero debe ser simple para usuarios no técnicos.

## 7. Aplicaciones y compatibilidad

### Linux

Es la plataforma nativa y preferida por eficiencia.

### Android

Waydroid se inicia cuando una aplicación Android lo necesita. Si no hay aplicaciones Android abiertas durante un periodo configurable, MurSchol puede suspender el contenedor para liberar recursos.

### Windows

Wine/Bottles se inicia al ejecutar una aplicación Windows. Cada programa puede tener un perfil aislado para reducir conflictos de dependencias.

### Estado de compatibilidad

MurSchol App Manager podrá mostrar:

- Nativa;
- Excelente;
- Compatible;
- Experimental;
- No compatible.

## 8. Instalación guiada

La instalación inicial debe funcionar por perfiles, de forma parecida a una biblioteca de plantillas:

### MurSchol Básico
- escritorio;
- red y audio;
- navegador;
- archivos;
- herramientas esenciales;
- aplicaciones Linux.

### MurSchol Completo
Incluye lo anterior y prepara:
- Android;
- Windows;
- soporte ampliado de aplicaciones.

### Personalizado
Permite seleccionar componentes.

La descarga e instalación de componentes opcionales debe ser automática después de la elección del usuario y debe reutilizar caché local cuando sea seguro hacerlo.

## 9. Perfil adaptativo de hardware

En el primer arranque, MurSchol detecta:

- RAM;
- CPU/núcleos;
- GPU y controladores;
- almacenamiento;
- batería;
- resolución/pantalla táctil.

Con esos datos propone un perfil, que el usuario puede cambiar:

### Ligero
- sin blur;
- sombras mínimas;
- animaciones reducidas;
- servicios opcionales bajo demanda;
- indexación limitada.

### Normal
- efectos moderados;
- Android/Windows bajo demanda;
- indexación normal.

### Rendimiento
- efectos completos opcionales;
- multitarea más agresiva;
- cachés ampliadas.

## 10. Primer inicio

La experiencia de bienvenida debe pedir solo lo necesario:

1. idioma;
2. teclado;
3. zona horaria;
4. nombre de usuario;
5. red opcional;
6. perfil Básico/Completo/Personalizado;
7. privacidad y servicios opcionales.

No debe exigir cuenta online para utilizar el equipo.

## 11. Offline-first

MurSchol debe conservar utilidad plena sin Internet para:

- abrir archivos;
- estudiar;
- utilizar aplicaciones instaladas;
- reproducir multimedia local;
- tomar apuntes;
- gestionar calendario local;
- ejecutar software Linux/Windows/Android ya instalado cuando no dependa de servicios externos.

La conexión a Internet amplía funciones, pero no constituye el sistema.

## 12. Referencias de diseño estudiadas

Las referencias investigadas aportan ideas concretas:

- sistemas ligeros alternativos: disciplina de consumo y evitar capas innecesarias;
- ChromeOS: simplicidad, arranque y experiencia enfocada;
- Haiku/BeOS: coherencia del entorno gráfico;
- gestores centralizados como YaST: configuración técnica agrupada en un solo lugar;
- bibliotecas de imágenes/plantillas: instalación por perfiles y despliegue automatizado;
- sistemas de repositorios separados: estabilidad, actualizaciones y software opcional claramente distinguidos.

Estas son referencias conceptuales. La identidad, interfaz y código de MurSchol deben ser propios.
