# Transparencia de uso de IA

Este documento registra los prompts utilizados y las decisiones tomadas con
asistencia de IA (Claude Code), con fines de transparencia para la evaluación del test.

_Sesión: 2026-10-09_

## Prompts utilizados (verbatim)

1. **"Levanta la app en el simulador"**
   _(interrumpido por el usuario antes de completarse para pasar al commit)._

2. **"Perfecto, hagamos el primer commit"**

3. **"Quiero mejorar el diseño de las tarjetas del listado creando un componente
   llamado `BreweryCard`, siguiendo los principios de Atomic Design. La tarjeta debe
   mostrar el nombre de la cervecería, su tipo mediante un badge y debajo la ciudad
   junto al país, acompañados de un ícono de ubicación. También quiero incluir una
   flecha que indique que se puede acceder al detalle. Utiliza Material 3, respetando
   el tema de la aplicación, con bordes redondeados, espaciados consistentes y un
   diseño moderno y minimalista. Considera nombres largos, datos opcionales y
   diferentes tamaños de pantalla. Reemplaza `BreweryListTile` por `BreweryCard`,
   manteniendo su comportamiento actual. Reutiliza los componentes existentes cuando
   corresponda y evita abstracciones innecesarias."**

4. **"Sí, commitea los cambios"**

5. **"Vamos a dejar la sesión aquí por hoy, creemos un handoff para anotar lo que se
   hizo y lo pendiente. Recuerda crear el documento de transparencia con los prompts
   utilizados y las decisiones tomadas."**

## Decisiones tomadas

### Repositorio
- **Excluir el PDF del enunciado** (`Forest Senior Mobile Engineer (Flutter) Test.pdf`)
  del control de versiones agregando `*.pdf` al `.gitignore`: es la consigna del test,
  no parte del producto. El resto del `.gitignore` es el estándar de Flutter (ya cubre
  `build/`, `.dart_tool/`, etc.).

### Rediseño de la tarjeta (BreweryCard)
- **Promover el badge a un átomo compartido** (`AppBadge` en
  `shared/presentation/widgets/atoms/`): antes era un widget privado `_BreweryTypeBadge`
  dentro del tile. Es genérico (una "pill" con un label) y reutilizable, por lo que
  encaja como átomo real de Atomic Design — y la carpeta `atoms/` estaba vacía esperando
  su primer componente. No se agregaron parámetros de color/estilo extra para evitar
  abstracción innecesaria; usa tokens del `ColorScheme`.
- **Mantener `BreweryCard` dentro del feature** (`features/breweries/presentation/widgets/`)
  en vez de en `shared/`: conoce la entidad de dominio `Brewery`, por lo que es
  específico del feature (misma justificación que tenía el `BreweryListTile` original).
- **Dejar la fila de ubicación como widget privado** (`_LocationRow`) en el mismo archivo
  del card: se usa una sola vez, así que promoverla a un componente compartido sería una
  abstracción prematura. Se respetó la guía de "evitar abstracciones innecesarias".
- **Ubicación con degradación elegante**: se construye el texto uniendo
  `[ciudad, país]` no vacíos con ", ". Si faltan ambos, se muestra "Location unavailable"
  (se preservó el fallback del tile original, extendiéndolo para incluir el país como
  pedía el enunciado).
- **Nombres largos**: título a 2 líneas máximo con elipsis; la columna de contenido usa
  `Expanded` para adaptarse a distintos anchos de pantalla.
- **Capitalización ligera del tipo** (`micro` → `Micro`): mejora visual mínima; la API
  devuelve los tipos en minúscula. No altera el comportamiento funcional.
- **Material 3**: `Card` con bordes redondeados (16 px), `InkWell` para feedback táctil,
  padding (16 px) y espaciados consistentes, `chevron_right` como indicador de navegación
  al detalle. Todos los colores salen del `ColorScheme` del tema (consistente en claro/oscuro).
- **Comportamiento preservado**: `BreweryCard` mantiene la misma API (`brewery`, `onTap`)
  y el `onTap` sigue sin cablearse (igual que antes), listo para la futura pantalla de detalle.

### Verificación
- Se ejecutó `flutter analyze` (sin issues) y se validó visualmente en el simulador
  iPhone 16 Pro con una captura de pantalla antes de commitear.

## Herramienta

- **Claude Code** (modelo Claude Opus 4.8), ejecutando análisis, edición de archivos y
  el lanzamiento/verificación de la app en el simulador iOS.
