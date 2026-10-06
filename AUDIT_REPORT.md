# Auditoría técnica de ErgoWorkCoach

Fecha: 2026-10-06

## Idea y alcance del proyecto

Aplicación Flutter de autocuidado laboral: registro de molestias por zona e intensidad, catálogo de ejercicios con videos, respiración guiada, avatar y motivación mediante experiencia, logros y rachas. La implementación actual funciona con perfiles y almacenamiento locales; no incluye un proveedor real de identidad ni diagnóstico mediante IA.

Se revisaron arranque, inyección de dependencias, navegación, autenticación local, persistencia, BLoC/Cubit, respiración, catálogo, historial, gamificación, integración de visores y configuración de plataformas. Se mantuvo la arquitectura y no se actualizaron dependencias ni se sustituyó el catálogo clínico.

## Verificación de esta revisión

- Base previa: análisis sin hallazgos y 12 pruebas aprobadas. Esas pruebas no cubrían los errores funcionales descritos abajo.
- Suite ampliada: **54 pruebas aprobadas**.
- `flutter analyze --no-pub`: sin hallazgos.
- `flutter build web --release --no-pub --no-wasm-dry-run`: correcta.
- `flutter build apk --debug --no-pub`: correcta; APK en `build/app/outputs/flutter-apk/app-debug.apk`.
- Pruebas de interfaz con la aplicación real: acceso, cierre de sesión, cambio de perfil, pausa al cambiar de pestaña o pasar al fondo, recompensas al finalizar respiración y formulario de registro a 320 × 640 con texto ampliado al 180 %.
- La alternativa para Windows se comprobó mediante pruebas de widgets con esa plataforma simulada. No se compiló ni ejecutó un binario Windows en esta revisión.
- No se ejecutaron pruebas en dispositivos Android/iOS físicos ni una nueva inspección visual del modelo WebGL y de videos externos. Compilar y validar el catálogo no comprueba la disponibilidad ni la adecuación clínica de esos videos.

## Hallazgos corregidos

| Prioridad | Problema encontrado | Corrección y cobertura |
| --- | --- | --- |
| Alta | Historial y avatar usaban claves globales y se compartían entre perfiles. | Almacenamiento por identidad local estable, limpieza del contexto al salir, captura del propietario antes de escrituras asíncronas y pruebas de separación entre perfiles. |
| Alta | Las rutas internas no comprobaban la sesión y Ajustes navegaba antes de confirmar el cierre. | Redirección central según autenticación; cierre confirmado antes de salir; conservación de sesión y mensaje si falla; operaciones de autenticación serializadas. |
| Alta | Respuestas tardías podían mostrar ejercicios de una zona o EVA anterior. | Invalidación de solicitudes al cambiar zona/intensidad, prioridad de la última consulta y bloqueo de guardados simultáneos desde el BLoC. |
| Media | El cálculo de nivel devolvía 0 para menos de 500 XP, con división por cero en el progreso. | Umbrales corregidos y pruebas en 0, 50, 499, 500, 1499 y 1500 XP. |
| Media | Algunas técnicas terminaban antes de la última pausa y el contador final quedaba en 1. | Ciclos completos, incluida la pausa final, y contador final en 0. Las ocho técnicas se verifican segundo a segundo con reloj virtual. |
| Media | El círculo respiratorio animaba siempre en 800 ms, seguía animándose al pausar y el temporizador continuaba fuera de la pestaña. | Animación ajustada a la duración de fase, pausa visual y temporal, pausa al ocultar la pestaña o la aplicación y reanudación manual. |
| Media | La pantalla anunciaba XP de respiración, pero no se otorgaban; los logros no estaban conectados y el progreso no persistía. | Puntos por sesión completa, logros de dolor/avatar/respiración/nivel, rachas por fecha local y almacenamiento por perfil. Los logros otorgan su recompensa una sola vez. |
| Media | Un registro repetido podía duplicarse y se ignoraba el resultado booleano del almacenamiento. | Escrituras de dolor serializadas, actualización por ID, confirmación de guardado y recuperación de la cola después de un fallo. |
| Media | La consulta por zona filtraba después de limitar a 50 registros, ocultando registros antiguos. | Filtrado sobre el historial completo; se conserva el límite de 50 para la vista general. Se omiten entradas corruptas o EVA fuera de rango. |
| Media | Cerrar el avatar durante una operación podía emitir sobre un Cubit cerrado; una carga tardía podía deshacer cambios. | Comprobación de cierre y revisión de edición; un guardado anterior no marca como guardados los cambios posteriores. |
| Media | Cargar el tema podía sobrescribir una elección reciente o emitir después del cierre. | Prioridad de la elección explícita y comprobaciones del ciclo de vida. |
| Media | El formulario tenía altura fija y los botones se desbordaban con texto ampliado. | Altura natural del formulario, botones con texto flexible y altura mínima; pruebas con validación visible en pantalla pequeña. |
| Media | Windows intentaba construir WebViews sin implementación compatible. | Selección corporal por lista, vista previa alternativa y enlace de video al navegador cuando no hay visor integrado. |
| Baja | Mensajes del visor web se aceptaban sin comprobar origen/ventana; el recurso se resolvía desde la URL actual. | Comprobación de origen y ventana emisora, resolución desde la base del documento y liberación del iframe de video al cerrar. |
| Baja | El splash podía quedarse esperando un cambio de estado ya ocurrido. | Comprobación del estado inicial y cancelación de la navegación pendiente al desmontar. |

También se corrigió la selección de ejercicios cuando falta una etapa exacta: se usa la etapa anterior más cercana de la misma zona, sin mezclar todas las etapas disponibles. Las 27 regiones y las tres etapas están cubiertas por pruebas del catálogo. No se modificaron instrucciones, dosis ni contraindicaciones.

## Migración de datos existentes

- Si al actualizar existe una sesión válida guardada, sus datos globales anteriores se copian al perfil restaurado.
- Los datos originales permanecen como copia. Un marcador impide asignarlos después a otro perfil.
- Sin una sesión previa identificable, se conservan los datos antiguos sin asignarlos automáticamente a un nuevo usuario. No es posible determinar su propietario a partir del formato anterior.
- Los identificadores locales dejan de depender de `String.hashCode`: se derivan de un correo normalizado, de forma determinista entre ejecuciones.
- La separación de perfiles evita mezclas accidentales. **No proporciona autenticación real ni cifrado**: el acceso sigue siendo una demostración local, ahora explicitada en la pantalla de acceso.

## Pendientes del producto

1. **Identidad y protección de datos:** implementar un proveedor real de autenticación, almacenamiento apropiado para datos de salud y políticas de privacidad. Las contraseñas actuales no se verifican contra una cuenta real. No se añadieron contraseñas en texto plano ni un backend improvisado.
2. **Avatar:** las preferencias se guardan, pero piel, pelo y ropa se muestran principalmente como etiquetas/colores de configuración; todavía no transforman los materiales o la geometría del GLB. La personalización visual completa requiere un modelo preparado para ello.
3. **Seguimiento de ejercicios:** el contador de repeticiones pertenece a la serie abierta. Completarla alimenta las rachas, pero falta guardar un historial detallado de series/repeticiones asociado a cada registro de dolor (`exercisesCompleted` sigue sin flujo de actualización).
4. **Funciones anunciadas como futuras:** perfil ampliado, suscripción, notificaciones, Work Coach y documentos legales siguen pendientes. No hay un servicio de IA conectado.
5. **Validación del contenido:** el catálogo, la correspondencia entre video y ejercicio, las dosis y las afirmaciones de las técnicas requieren revisión profesional. La comprobación automatizada de IDs no sustituye esa revisión ni garantiza licencias o disponibilidad externas.
6. **Distribución:** Android release todavía usa la configuración de firma debug. Faltan firma de publicación, comprobación en dispositivos reales, revisión con lector de pantalla y validación específica de iOS.
7. **Escalabilidad:** SharedPreferences es la persistencia actual. Un historial creciente y sincronización entre dispositivos requerirán una capa de datos más apropiada. Las rachas locales dependen del reloj del dispositivo.

Los resultados de esta auditoría describen las comprobaciones realizadas; no afirman ausencia total de errores ni preparación clínica/comercial.
