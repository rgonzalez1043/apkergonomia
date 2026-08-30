# Auditoria tecnica de ErgoWorkCoach

Fecha: 2026-08-30

## Resultado actual

- `flutter analyze`: sin problemas.
- `flutter test`: 12 pruebas aprobadas.
- `flutter build web --release`: compilacion de produccion correcta.
- `flutter build apk --debug`: compilacion Android correcta.
- Validacion visual con Playwright: movil 390 x 844 y escritorio 1280 x 900.
- Reproduccion validada: iframe 16:9 activo, controles visibles y cambio de fotograma tras iniciar el video.
- Recursos HTTP durante los recorridos principales: sin respuestas 404.
- Modelo corporal GLB: carga y presenta pixeles no vacios en movil y escritorio.
- Canvas Three.js: 192 muestras, 43 colores unicos y 192 pixeles no transparentes.

## Correcciones realizadas

- El modelo 3D ahora permite seleccionar directamente las 27 regiones corporales y mantiene la lista como alternativa accesible.
- Se validaron cuello, rodilla, lateralidad anatomica, espalda superior, giro por arrastre y cambio Frente/Espalda.
- Se reemplazo el sistema de dibujos, GIF y fotografias por un catalogo centralizado de videos con personas reales.
- Los 66 ejercicios tienen un video trazable; hay 35 movimientos unicos sin archivos audiovisuales reempaquetados.
- Se agregaron guia de postura, dosis, seguridad y control manual de repeticiones.
- Se agregaron controles de video, subtitulos, pantalla completa, atribucion y enlaces a la fuente original.
- Se corrigieron la ruta web, la orientacion y el estado de carga del modelo GLB.
- Se corrigieron la persistencia de sesion, el cierre de sesion y el onboarding persistente.
- Se elimino la carrera entre guardar dolor y solicitar ejercicios.
- Se corrigieron temporizadores y transiciones de la sesion de respiracion.
- Se repararon estados, mensajes, acciones sin respuesta y desbordamientos en movil.
- Se adapto inicio y avatar para pantallas amplias y estrechas.
- Se eliminaron dependencias y recursos obsoletos del sistema visual anterior.

## Cobertura agregada

- Correspondencia entre los 66 ejercicios y su video.
- Formato de los identificadores, fuente HTTPS y presencia de personas reales.
- Regresion para evitar cruzar los videos de balanceo de rodillas y elevacion de pierna.
- Guia de ejercicio en un viewport movil y registro de repeticion.
- Restauracion y limpieza de sesiones locales.
- Persistencia del onboarding.
- Cancelacion del temporizador al cambiar de tecnica respiratoria.

## Requisitos antes de produccion clinica

1. Un fisioterapeuta o profesional habilitado debe validar cada asignacion de video, instruccion, dosis y contraindicacion antes de una publicacion clinica.
2. Los videos dependen de internet y de la disponibilidad del proveedor original. Se debe definir un proceso periodico para detectar enlaces retirados o modificados.
3. La autenticacion actual es una implementacion local de desarrollo. Debe sustituirse por un proveedor real y almacenamiento seguro.
4. Politica de privacidad, terminos, suscripcion y notificaciones son pantallas informativas o funciones pendientes; no deben anunciarse como operativas.
5. Deben realizarse pruebas en dispositivos Android/iOS reales, accesibilidad con lector de pantalla y una evaluacion de seguridad antes de publicar.

## Alcance medico

La aplicacion ofrece orientacion general de autocuidado. No diagnostica ni reemplaza una evaluacion medica o de fisioterapia. La interfaz indica detener el movimiento si aumenta el dolor o aparecen hormigueo, mareo o debilidad.
