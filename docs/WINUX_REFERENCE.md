# Winux como referencia para MurSchol OS

Winux (antes Linuxfx/Windowsfx) se analiza aquí como referencia de UX y estrategia de migración desde Windows, no como base técnica ni como dependencia de MurSchol.

## Qué resulta útil

### 1. Familiaridad para usuarios que vienen de Windows

Winux prioriza que el usuario reconozca de inmediato menú de inicio, barra de tareas, iconografía, configuración y flujos de escritorio. Para MurSchol esto confirma una regla ya adoptada: las convenciones conocidas reducen la curva de aprendizaje, pero la identidad visual debe seguir siendo propia.

Aplicación en MurSchol:
- Start reconocible y predecible;
- dock con apps fijadas, abiertas y recientes;
- Settings con jerarquía similar a sistemas de escritorio conocidos;
- nombres comprensibles, evitando jerga Linux en la interfaz normal;
- Alt+Tab, cerrar/minimizar/maximizar y cambio entre ventanas como funciones de máxima prioridad.

### 2. Compatibilidad multicapa presentada como producto

La versión actual de Winux promociona compatibilidad con aplicaciones Windows mediante Wine/WinBoat y soporte Android, además de aplicaciones Linux normales.

MurSchol ya va en esa dirección, pero mantendrá una arquitectura más explícita:
- Linux nativo;
- Flatpak;
- Android mediante Waydroid cuando el hardware/kernel lo permitan;
- Windows mediante Wine/Bottles;
- etiquetas de compatibilidad: Nativa, Excelente, Compatible, Experimental y No compatible.

La interfaz normal no debe obligar al usuario a entender de qué plataforma procede cada aplicación.

### 3. Restauración rápida de la experiencia

Winux incluye una función de restauración de ajustes visuales en un clic. Esta idea sí merece entrar en MurSchol.

Propuesta futura:
- `Restablecer apariencia` en Settings;
- restaurar tema, color, dock/panel, animaciones y disposición visual;
- no borrar archivos personales;
- no reiniciar configuraciones de red, cuentas o aplicaciones salvo que el usuario lo solicite explícitamente.

A medio plazo, esta función puede convivir con snapshots/rollback del sistema, pero son niveles distintos: uno restaura UX y otro restaura el sistema base.

### 4. Hardware antiguo sin barreras artificiales

Winux promociona BIOS/UEFI, ausencia de requisito TPM/Secure Boot y soporte para equipos que no cumplen requisitos de sistemas propietarios recientes.

MurSchol mantiene la misma filosofía general:
- PC x86-64 razonablemente antiguo debe poder arrancar si el kernel Debian lo soporta;
- evitar requisitos artificiales de hardware;
- perfil Ligero para equipos con pocos recursos;
- no sacrificar seguridad real solo para ampliar compatibilidad.

## Qué NO copiar

### No imitar Windows literalmente

Winux busca una semejanza muy alta con Windows 11. MurSchol no debe llegar a ese nivel de clonación.

Razones:
- identidad de producto propia;
- evitar dependencia visual de cambios de Microsoft;
- menos riesgo de confusión para el usuario;
- libertad para diseñar una experiencia más limpia y académica;
- evitar iconografía o activos que puedan generar problemas de licencia o marca.

La fórmula de MurSchol sigue siendo: **familiaridad sin clonación**.

### No preinstalar demasiadas aplicaciones

Winux promociona varias aplicaciones y capas preinstaladas. MurSchol debe seguir una política más ligera:
- ISO base pequeña y funcional;
- extras opcionales desde MurSchol Store;
- perfiles Básico / Completo / Personalizado en el instalador futuro;
- no instalar software pesado solo para presumir compatibilidad.

### No mezclar herramientas cerradas con control sensible del sistema sin auditabilidad

La historia de Linuxfx/Winux incluye críticas públicas sobre antiguos sistemas de activación, exposición de datos y componentes propietarios. Por ello MurSchol debe mantener una regla estricta:
- configuración del sistema auditable;
- nada de activación obligatoria para funciones básicas;
- no almacenar datos personales innecesarios;
- helpers privilegiados pequeños y limitados;
- preferencia por componentes abiertos y protocolos estándar;
- cualquier servicio en línea debe ser opcional y explicado claramente.

No se debe repetir sin verificación la afirmación comercial de que una distribución "no espía". La privacidad se evalúa por arquitectura, código, servicios activos y flujo de datos, no por una etiqueta de marketing.

## Ideas concretas que añadimos al roadmap

1. **Restablecer apariencia** en Settings.
2. Indicadores reales de apps abiertas y selector de ventanas en Dock.
3. Migración de usuarios de Windows como caso de uso explícito en onboarding.
4. Compatibilidad Linux/Flatpak/Android/Windows presentada de forma unificada.
5. ISO base ligera; aplicaciones pesadas opcionales.
6. Sin requisitos artificiales tipo TPM para instalar MurSchol.
7. Política de privacidad local-first y auditable.
8. Evitar cualquier sistema de activación obligatorio para el escritorio o apps base.

## Referencias revisadas

- https://www.winux.is/
- https://www.winux.is/news/
- https://www.softzone.es/noticias/open-source/winux-linux-imita-windows-11/

Fecha de revisión: septiembre de 2026.
