# MurSchol Calculator

MurSchol Calculator es la calculadora nativa ligera de MurSchol OS. La versión 0.1 prioriza apertura rápida, uso por teclado y una interfaz única para cálculo cotidiano, científico, conversiones y bases numéricas.

## Arquitectura

- Interfaz: Qt 6 / QML.
- Backend: C++20.
- Motor matemático: `libqalculate` mediante `pkg-config`.
- Historial y preferencia DEG/RAD: `QSettings` local.
- Sin red obligatoria.

El motor se mantiene separado de la interfaz para poder reutilizarlo desde búsqueda universal u otras superficies del sistema en el futuro sin duplicar lógica matemática.

## Modos 0.1

### Estándar

Operaciones básicas, porcentaje, paréntesis, ANS, entrada por teclado y resultado copiable.

### Científica

Funciones trigonométricas, inversas, logaritmos, raíz, potencias, factorial, constantes π/e y selector de ángulo DEG/RAD. El selector se transmite a las opciones de análisis de libqalculate.

### Convertir

Primera selección de unidades para longitud, masa, temperatura, velocidad, área, tiempo y almacenamiento. La expresión se resuelve como conversión real de unidades en libqalculate.

### Programador

Primera fase con conversión de resultados a binario, octal, decimal y hexadecimal. La entrada acepta la sintaxis del motor, incluyendo prefijos como `0x` y `0b`.

## Entrada natural

La barra de expresión admite directamente expresiones que entienda libqalculate, por ejemplo cálculos con unidades, constantes y conversiones. La interfaz de botones no limita las capacidades del motor.

## Historial

Se conservan localmente hasta 50 operaciones recientes. No se sincronizan ni salen del dispositivo en la versión inicial.

## Rendimiento

Calculator no mantiene servicios en segundo plano. La aplicación carga el motor al abrirse y persiste únicamente preferencias e historial local. No se añadirá a la Live ISO como predeterminada hasta validar compilación y comportamiento real.

## Siguientes fases

- Entrada de bases más visual en modo Programador.
- Memoria MC/MR/M+/M-.
- Favoritos de conversiones.
- Conversión de moneda opcional y explícitamente online.
- Cálculo simbólico avanzado: ecuaciones, derivadas, integrales y matrices.
- Gráficos opcionales sin cargar el componente cuando no se usa.
- Integración con la búsqueda universal de MurSchol.

## Licencia

MurSchol Calculator enlaza con libqalculate, por lo que su distribución debe mantenerse compatible con la licencia de esa biblioteca. La decisión se conserva explícita para empaquetado y publicación.
