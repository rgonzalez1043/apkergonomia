# Changelog

## Unreleased

### Revisión del 6 de octubre de 2026

- Separados historial, avatar y progreso por perfil local; migración conservando los datos anteriores.
- Protegidas las rutas internas y serializadas las operaciones de sesión; el cierre espera su confirmación.
- Corregidos nivel 0, cálculo de progreso, pausa final de respiración y contador al completar.
- Sincronizada la animación respiratoria y pausadas las sesiones al ocultar la pestaña o la app.
- Conectados y persistidos XP, logros y rachas a partir de acciones reales, sin duplicar recompensas.
- Corregidas respuestas tardías de ejercicios, guardados simultáneos, duplicados por ID y filtrado del historial por región.
- Protegidos los Cubit de avatar y tema frente a operaciones tardías y cierre de pantallas.
- Adaptados formularios y botones a texto ampliado y pantallas pequeñas.
- Añadidas alternativas en Windows para visores no compatibles y comprobaciones de origen del mapa web.
- Ampliada la suite de 12 a 54 pruebas, con compilaciones Web release y APK debug verificadas.

### Cambios anteriores

- Convertido el humano 3D en un mapa corporal interactivo con raycasting, 27 zonas, resaltado y vistas frontal/posterior.
- Corregido el reproductor web dentro del panel desplazable con un iframe 16:9 estable de `youtube-nocookie.com`.
- Sustituido el sistema de imágenes por videos de personas reales en los 66 ejercicios.
- Integrado un reproductor YouTube 16:9 con controles, subtítulos, pantalla completa y modo de privacidad mejorada.
- Añadida atribución visible y enlace a la fuente original de cada movimiento.
- Eliminadas las imágenes generadas y cualquier fotografía de respaldo en ejercicios.
- Incorporados contador de repeticiones, progreso, reinicio y avisos de seguridad.
- Documentadas fuentes, disponibilidad y revisión clínica de los videos.
- Corregidos guardado/carga concurrentes en el flujo de dolor y EVA 0.
- Añadida persistencia local de sesión y cierre de sesión real.
- Persistido el estado de onboarding y protegida la navegación del splash.
- Corregido el temporizador al cambiar o reanudar técnicas de respiración.
- Mejorados tema del sistema, iconografía, historial y manejo de datos corruptos.
- Reemplazadas las pruebas de ejemplo por pruebas de catálogo, sesión, estado y UI.

## 1.0.0

- Versión inicial.
