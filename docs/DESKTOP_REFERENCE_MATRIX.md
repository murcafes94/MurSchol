# Matriz de referencias de escritorio para MurSchol

Este documento sintetiza referencias externas útiles para MurSchol OS. El objetivo no es clonar ninguna distribución, sino identificar decisiones de UX, arquitectura y producto que puedan adaptarse a nuestra base Debian 13 + labwc/wlroots + Qt 6/QML.

## Identidad MurSchol que se mantiene

Paleta principal: blanco, azul, negro y rojo.

- Azul: interacción principal, selección, foco, estados activos.
- Negro: base del modo oscuro y superficies de alto contraste.
- Blanco: base del modo claro y texto de alto contraste.
- Rojo: apagar, eliminar, errores y acciones destructivas.
- Grises neutros: jerarquía, bordes y texto secundario.

## Referencias y qué tomar de cada una

### Deepin / DDE

Tomar:
- Coherencia visual fuerte entre shell, dock, Settings y aplicaciones nativas.
- Centro de control propio y entendible.
- Dock con personalidad de producto.
- Aplicaciones del sistema que parecen pertenecer al mismo ecosistema.
- Animaciones y profundidad visual como capa de pulido, no como sustituto de la usabilidad.

Evitar:
- Convertir MurSchol en un fork de DDE.
- Dependencias pesadas solo por estética.
- Blur y transparencias obligatorias.
- Sacrificar estabilidad de ventanas o lanzamiento de aplicaciones por efectos visuales.

### KDE Plasma / KDE Neon

Tomar:
- Flexibilidad del escritorio y paneles.
- Buen manejo de tareas tradicionales: menú, ventanas, bandeja, archivos y configuración.
- Personalización amplia, pero presentada por niveles.
- Referencia para soporte de múltiples pantallas y configuraciones avanzadas.

Evitar:
- Exponer demasiadas opciones a la vez.
- Convertir Settings en un árbol técnico difícil para usuarios nuevos.

MurSchol debe usar divulgación progresiva: opciones comunes visibles y opciones avanzadas dentro de subapartados.

### Zorin OS

Tomar:
- Reducir la fricción para usuarios que llegan desde Windows.
- Convenciones familiares sin copiar literalmente Windows.
- Layout claro, panel/dock comprensible y navegación predecible.
- Presentar compatibilidad y migración como parte del producto, no como un problema técnico del usuario.

Aplicación en MurSchol:
- Start reconocible.
- Alt+Tab y gestión de ventanas fiables.
- Archivos, Configuración y navegador fáciles de encontrar.
- No mostrar al usuario de forma constante si una app viene de Linux, Flatpak, Android o Windows.

### Linux Mint / Cinnamon

Tomar:
- Convenciones de escritorio tradicionales que no requieren aprendizaje previo.
- Estabilidad de la experiencia por encima de novedades visuales constantes.
- Estructura clara de menú, panel, bandeja y gestor de archivos.

Aplicación en MurSchol:
- Mantener las acciones esenciales siempre previsibles.
- Evitar esconder funciones básicas detrás de gestos o menús poco obvios.

### AnduinOS

Tomar:
- Familiaridad con Windows sin fingir ser Windows.
- Prioridad al flujo de trabajo sobre la imitación visual.

Aplicación en MurSchol:
- El usuario puede venir de Windows y empezar a trabajar sin aprender terminología Linux.
- La identidad visual sigue siendo MurSchol.

### elementary OS

Tomar:
- Guías de interfaz estrictas para mantener coherencia.
- Diseño limpio y centrado en reducir distracciones.
- Privacidad y permisos explicados claramente.

Aplicación en MurSchol:
- Design System obligatorio para apps MurSchol.
- Menos controles simultáneos, mejor jerarquía visual.
- Acciones sensibles claramente explicadas.

### Garuda Linux

Tomar:
- Personalidad visual fuerte.
- Idea de recuperación/snapshots antes de cambios importantes como referencia futura.

Evitar:
- Estética excesiva que aumente consumo o reste legibilidad.
- Convertir efectos y animaciones en una dependencia para que el sistema se sienta moderno.

Aplicación en MurSchol:
- Perfil Ligero reduce o elimina efectos costosos.
- Perfil Normal conserva transiciones discretas.
- Perfil Rendimiento no debe significar más efectos; debe priorizar respuesta.

### blendOS y sistemas multicapa

Tomar como referencia de arquitectura, no como implementación inmediata:
- Unificar diferentes fuentes de aplicaciones detrás de una experiencia común.
- Reducir el riesgo de que el usuario rompa el sistema base.

Aplicación en MurSchol:
- MurSchol Store y Settings deben presentar apps Linux, Flatpak, Android/Waydroid y Windows/Wine-Bottles de forma unificada.
- Mantener etiquetas de compatibilidad: Nativa, Excelente, Compatible, Experimental y No compatible.
- Considerar a futuro mecanismos de sistema base protegido o recuperación, pero no introducir inmutabilidad durante la alpha sin una estrategia completa de actualización y rollback.

### Labwc / escritorios ligeros Wayland

MurSchol usa labwc como compositor base. La referencia más útil aquí no es estética sino arquitectónica: labwc está diseñado para apilar ventanas con pocos componentes y delegar panel, fondo, capturas y otras funciones a clientes independientes.

Aplicación en MurSchol:
- Mantener el compositor simple y estable.
- Implementar identidad, panel, dock y aplicaciones en procesos separados.
- No cargar el compositor con animaciones o servicios que pueden vivir en el shell.
- Probar con especial cuidado múltiples pantallas, foco, Alt+Tab, decoraciones y cierre de ventanas.

DistroWatch permite descubrir imágenes Debian ligeras recientes basadas en labwc, sway, wayfire y otros compositores. Entre las referencias a vigilar está LajtLinux, que publica imágenes Debian 13 con labwc; sirve como comparación práctica de arranque, tamaño de ISO y selección de componentes, no como base de MurSchol.

## DistroWatch como fuente de descubrimiento

DistroWatch se incorpora como catálogo para descubrir distribuciones, lanzamientos, screenshots y combinaciones de escritorio/compositor que merezcan análisis posterior.

No se utilizará su **Page Hit Ranking** como medida de calidad, cuota de mercado ni número real de usuarios. Ese ranking mide accesos a páginas dentro de DistroWatch y es útil principalmente como señal de curiosidad o interés de sus visitantes.

Uso previsto en MurSchol:
- localizar distros nuevas con propuestas de UX interesantes;
- vigilar escritorios ligeros Debian/Wayland;
- comparar screenshots y decisiones de layout;
- detectar nuevas combinaciones con labwc, LXQt, Wayfire, Sway o similares;
- después contrastar cualquier idea importante con documentación oficial, repositorios y pruebas reales.

## Fuente G2

La página de alternativas de G2 no es una referencia útil para comparar escritorios Linux: clasifica Deepin principalmente dentro de VDI/DaaS y propone productos como Citrix, VMware Horizon, Amazon WorkSpaces o VirtualBox. Puede servir como señal de que la categorización comercial es ambigua, pero no debe usarse para decisiones de UX de MurSchol.

## Señal de comunidades Linux

Las discusiones comunitarias alrededor de Deepin muestran una lección útil: una interfaz puede ser considerada muy atractiva y bien pensada en UX, pero si el dock, el movimiento de ventanas o el lanzamiento de aplicaciones son inestables, la percepción del sistema cae rápidamente.

Esto es especialmente relevante para MurSchol: la prioridad de la alpha debe ser que abrir, cerrar, cambiar y recuperar ventanas sea totalmente fiable antes de añadir más efectos visuales.

## Prioridades de producto resultantes

1. Fiabilidad del shell y gestión de ventanas.
2. MurSchol Design System compartido.
3. Start + Dock + Settings como núcleo visual coherente.
4. Files, Photos, Capture y Reader bajo el mismo lenguaje visual.
5. Compatibilidad de apps presentada de forma simple al usuario.
6. Perfiles de rendimiento que reduzcan coste visual sin degradar funciones.
7. Instalador y recuperación simples.
8. Store unificada.
9. Soporte táctil y adaptación futura a MurSchol Mobile.

## Regla de diseño

MurSchol debe sentirse familiar sin ser un clon de Windows, elegante sin depender de efectos pesados, configurable sin ser abrumador y coherente sin obligar al usuario a entender la plataforma técnica de cada aplicación.

## Referencias revisadas

- https://www.deepin.org/en/
- https://www.profesionalreview.com/2026/04/05/estas-son-las-distribuciones-mas-bonitas-en-linux/
- https://www.g2.com/es/products/deepin/competitors/alternatives
- https://www.reddit.com/r/linuxquestions/comments/ked9hs/the_best_linux_distro_for_deepin_de/
- https://www.zdnet.com/article/most-windows-like-linux-distros/
- https://www.youtube.com/watch?v=4629-IzQOIA&t=41
- https://distrowatch.com/?language=ES
- https://labwc.github.io/
