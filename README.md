# Brewery Explorer

Aplicación Flutter para explorar cervecerías usando la API pública de
[Open Brewery DB](https://www.openbrewerydb.org/). Permite listar cervecerías con
scroll infinito, ver el detalle de cada una (con acciones de mapa, llamada y sitio web)
y buscar por nombre con _debounce_.

Construida con **Clean Architecture** por feature, **BLoC** para la gestión de estado,
**Material 3** y **Atomic Design** para la UI.

---

## Funcionalidades

- **Listado de cervecerías** con paginación por _scroll infinito_ y control de
  concurrencia (sin páginas duplicadas; una paginación en vuelo no sobrescribe una
  recarga).
- **Detalle de cervecería** por ID con nombre, dirección (multilínea), teléfono y sitio
  web. Acciones: **abrir en Maps**, **llamar** y **abrir el sitio web** (`url_launcher`).
- **Búsqueda con _debounce_ (400 ms)** sobre el endpoint `/breweries/search`, con
  cancelación de resultados obsoletos. Al limpiar se restaura el listado normal con su
  scroll infinito.
- **Estados de UI** consistentes en todas las pantallas: carga, error (con reintento),
  vacío y "sin resultados".
- **Material 3** con tema por `ColorScheme.fromSeed` (claro/oscuro) y `SafeArea`.

---

## Cómo ejecutar

### Requisitos

- Flutter **3.44+** (Dart SDK `^3.12.2`).
- Un emulador/simulador o dispositivo (probado en iPhone 16 Pro, iOS 18.3).

### Pasos

```bash
# 1. Dependencias
flutter pub get

# 2. Generar el código de inyección de dependencias (injectable)
#    Solo necesario si se modifican anotaciones @injectable; el archivo
#    generado (injection.config.dart) ya está versionado.
dart run build_runner build

# 3. Ejecutar
flutter run -d <device-id>      # p. ej. un simulador iPhone
```

Lista los dispositivos disponibles con `flutter devices`.

> **iOS:** la app usa `url_launcher` (plugin nativo); la primera build ejecuta
> `pod install` automáticamente.

---

## Arquitectura

**Clean Architecture** organizada por _feature_, con tres capas de dependencia
unidireccional (`presentation → domain ← data`):

| Capa | Responsabilidad | Ejemplos |
|------|-----------------|----------|
| **domain** | Modelo de negocio y contratos, sin dependencias de framework | `Brewery` (entidad), `BreweryRepository` (interfaz) |
| **data** | Acceso a la API y mapeo a entidades | `BreweryRemoteDataSource` (Dio), `BreweryDto`, `BreweryRepositoryImpl` |
| **presentation** | Estado y UI | BLoCs, páginas, widgets |

Principios aplicados:

- **BLoC** (`flutter_bloc`) con **eventos y estados sellados** (`sealed`), consumidos con
  `switch` exhaustivo. No se usa `FutureBuilder`.
- **Sin Use Cases**: no hay lógica de negocio que los justifique; los BLoC consumen
  directamente las interfaces de repositorio (evitar sobreingeniería).
- **Inyección de dependencias** con `get_it` + `injectable`. La _composition root_ está en
  el router: el `getIt` solo se lee ahí para construir BLoCs; los widgets nunca lo tocan.
- **Navegación** con `go_router` (`/` listado, `/breweries/:id` detalle).
- **Errores tipados**: la capa de datos traduce errores de Dio/parsing a un `sealed
  AppException` (`NetworkException`, `ServerException`, `NotFoundException`,
  `ParsingException`); la presentación los mapea a copys para el usuario.
- **Atomic Design** para componentes reutilizables: _atoms_ (`AppBadge`), _molecules_
  (`InfoTile`, `MessageView`, `BrewerySearchBar`), más widgets específicos de feature
  (`BreweryCard`).

### Concurrencia (`bloc_concurrency` + `stream_transform`)

El `BreweryListBloc` combina tres _transformers_ según el evento:

- `BreweryListStarted` → **`restartable`** (un reintento cancela la carga inicial en vuelo).
- `BreweryListNextPageRequested` → **`droppable`** (ignora solicitudes de paginación
  duplicadas mientras una está en curso).
- `BreweryListSearchChanged` → **`debounce` (400 ms) + `restartable`** (coalescing de
  pulsaciones para evitar solicitudes innecesarias; una query más nueva cancela la anterior
  para descartar resultados obsoletos).

Los resultados de búsqueda se emiten como una sola página (`hasReachedEnd == true`), de
modo que la paginación por scroll queda deshabilitada sin lógica extra, y ambos modos
(lista/búsqueda) no entran en conflicto.

### Estructura de carpetas

```
lib/
├── app/                      # App root, tema y router
├── core/                     # Infra transversal (DI, red, errores, constantes)
└── features/breweries/
    ├── data/                 # datasources, models (DTO), repositories (impl)
    ├── domain/               # entities, repositories (interfaces)
    └── presentation/         # bloc, pages, widgets
lib/shared/presentation/widgets/  # atoms / molecules reutilizables
```

---

## Tests

```bash
flutter test       # 43 tests
flutter analyze    # sin issues
```

Cobertura (significativa, no exhaustiva):

- **`BreweryListBloc`** — carga exitosa (página llena/corta/vacía), errores tipados,
  reintento, paginación (append + fin de lista), fallo de paginación retriable, y
  **concurrencia**: `droppable` evita duplicados, una paginación pendiente no sobrescribe
  un reinicio, y la **búsqueda** (debounce dispara una sola petición con la última query;
  `restartable` descarta la respuesta lenta obsoleta; limpiar restaura la lista; no pagina
  en modo búsqueda).
- **`BreweryDetailBloc`** — éxito, errores (not-found/red/genérico) y reintento.
- **`BreweryDto`** — mapeo JSON, campos opcionales y parseo de coordenadas.
- **`Brewery.addressLines`** — prioridad de `address_1` con _fallback_ a `street` (sin
  duplicados), y `hasCoordinates`.
- **Widgets** — `BreweryCard`, `InfoTile` y `BrewerySearchBar`.

> El _debounce_ se inyecta como `@factoryParam` (default 400 ms en producción; los tests
> usan una duración corta para ser rápidos y deterministas).

---

## Decisiones técnicas y trade-offs

- **Sin Use Cases / sin caché por ahora.** Se prioriza simplicidad; el repositorio es el
  punto natural para añadir una caché offline sin tocar domain/presentation.
- **Paginación derivada del estado.** La siguiente página se calcula a partir de la
  cantidad de ítems cargados y el fin se detecta cuando una página trae menos del tamaño
  solicitado. Evita un campo de "página" extra, a cambio de asumir páginas uniformes.
- **Búsqueda como una sola página.** Mantiene la implementación simple y evita conflictos
  con el scroll infinito. _Trade-off_: no hay paginación de resultados de búsqueda.
- **`url_launcher` con `launchUrl` directo** (sin `canLaunchUrl`): evita configurar
  `LSApplicationQueriesSchemes` en `Info.plist`. En el simulador, `tel:` no abre el
  marcador y degrada con un `SnackBar` (en dispositivo real sí marca).
- **Maps nativo por plataforma.** Apple Maps en iOS y URL universal de Google Maps en el
  resto (`defaultTargetPlatform`), usando coordenadas si existen.
- **Strings en inglés _hardcodeados_.** La UI está en inglés y la i18n quedó como mejora
  futura (ver abajo). El botón "Back" usa inglés por consistencia con el resto de la UI.
- **`injection.config.dart` versionado.** Permite clonar y ejecutar sin correr
  `build_runner`, a costa de regenerarlo al cambiar anotaciones.

---

## Mejoras futuras

- **Caché/offline** en el repositorio (p. ej. `Hive`/`drift`) y _pull-to-refresh_.
- **Internacionalización** (`intl`) para externalizar los strings.
- **Paginación de resultados de búsqueda** (scroll infinito también en modo búsqueda).
- **Más tests**: widget test de `BreweryDetailPage` por estados, _golden tests_ y un test
  de integración del flujo lista → detalle.
- **Tablets / pantallas anchas**: acotar el ancho máximo del listado.
- **Verificación visual de _dark mode_** y pulido de accesibilidad.

---

## Uso de IA y documentación

Esta entrega documenta de forma transparente el uso de IA (Claude Code):

- **[AI_TRANSPARENCY.md](AI_TRANSPARENCY.md)** — registro de las conversaciones: los
  _prompts_ utilizados (verbatim) y las decisiones tomadas en cada sesión, desde el primer
  prompt del proyecto.
- **[HANDOFF.md](HANDOFF.md)** — notas de estado y pendientes entre sesiones.

El historial de commits está separado por etapas/funcionalidades para reflejar el avance
incremental.
