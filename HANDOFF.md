# Handoff — Brewery Explorer App

_Última actualización: 2026-10-13_

## Contexto

App Flutter para explorar cervecerías usando la API pública de Open Brewery DB.
Clean Architecture por feature (data / domain / presentation), BLoC para estado,
`get_it` + `injectable` para inyección de dependencias, `go_router` para navegación y
Material 3 con tema por `ColorScheme.fromSeed`. Ver [README.md](README.md) para la
documentación completa.

## Estado actual

Desarrollo **finalizado**; se cumplieron los objetivos del proyecto (incluido el bonus de
búsqueda). Rama `main`, working tree limpio.

### Funcionalidades implementadas

- **Listado** con scroll infinito y control de concurrencia (`restartable` + `droppable`;
  una paginación en vuelo no sobrescribe una recarga).
- **Detalle** por ID: nombre, dirección (multilínea), teléfono y sitio web, con acciones
  de **Maps**, **llamar** y **abrir web** (`url_launcher`). AppBar sin título (nombre como
  hero), tarjeta agrupada M3 y botón de volver.
- **Búsqueda con debounce (400 ms)** sobre `/breweries/search`, con cancelación de
  resultados obsoletos (`debounce` + `restartable`). Al limpiar se restaura el listado
  normal con su scroll infinito.
- **Estados** de carga, error (con reintento), vacío y "sin resultados" en todas las
  pantallas.

### Tests

- **43 tests** (`flutter test`) y `flutter analyze` sin issues.
- Cubren: BLoCs de listado y detalle (carga/errores/reintentos/paginación/concurrencia y
  debounce), mapeo del DTO, `addressLines` de la entidad y widgets (`BreweryCard`,
  `InfoTile`, `BrewerySearchBar`).

### Historial de commits (rama `main`)

- `8640337` scaffold inicial → `133d47d` BreweryCard → `a1a9820`/`a863933` docs →
  `e1a4a74` pantalla de detalle + navegación + acciones → `9156753` suite de tests →
  `9eb7caa` bonus de búsqueda con debounce → (docs: README + este handoff).

## Documentación

- [README.md](README.md) — ejecución, arquitectura, funcionalidades, tests, decisiones,
  trade-offs y mejoras futuras.
- [AI_TRANSPARENCY.md](AI_TRANSPARENCY.md) — prompts (verbatim) y decisiones por sesión.

## Mejoras futuras (no abordadas, fuera de alcance)

- Caché/offline en el repositorio y pull-to-refresh.
- Internacionalización (`intl`); hoy los strings están en inglés hardcodeados.
- Paginación de resultados de búsqueda.
- Más tests (widget de `BreweryDetailPage`, golden, integración lista → detalle).
- Acotar ancho en tablets/pantallas anchas y verificación visual de dark mode.

## Cómo correr

```bash
flutter pub get
dart run build_runner build   # solo si se cambian anotaciones @injectable
flutter run -d <id-del-dispositivo>
```
