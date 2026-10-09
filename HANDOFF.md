# Handoff — Brewery Explorer App

_Última actualización: 2026-10-09_

## Contexto

App Flutter para explorar cervecerías usando la API pública de Open Brewery DB.
Arquitectura limpia (data / domain / presentation) por feature, BLoC para estado,
`get_it` + `injectable` para inyección de dependencias y Material 3 con tema por
`ColorScheme.fromSeed`.

## Estado actual

### Hecho en esta sesión
- **Primer commit** del scaffold del proyecto (`8640337`). Se excluyó del repo el
  PDF del enunciado del test vía `.gitignore` (`*.pdf`), por no ser parte de la app.
- **Rediseño de la tarjeta del listado** (`133d47d`): se reemplazó `BreweryListTile`
  por un nuevo `BreweryCard` en Material 3 siguiendo Atomic Design.
  - `lib/shared/presentation/widgets/atoms/app_badge.dart` — nuevo átomo `AppBadge`
    (pill reutilizable) promovido desde el antiguo badge privado.
  - `lib/features/breweries/presentation/widgets/brewery_card.dart` — nueva tarjeta
    del feature: nombre, badge de tipo, ubicación (ciudad + país con ícono de pin) y
    chevron de acceso al detalle. Maneja nombres largos (2 líneas + elipsis), campos
    opcionales y distintos anchos de pantalla.
  - `lib/features/breweries/presentation/pages/brewery_list_page.dart` — usa `BreweryCard`.
  - Se eliminó `brewery_list_tile.dart`.
  - Verificado con `flutter analyze` (sin issues) y visualmente en el simulador
    iPhone 16 Pro.

### Estado del repo
- Rama `main`, working tree limpio.
- Commits: `8640337` (scaffold) → `133d47d` (BreweryCard).

## Pendiente / próximos pasos

- **Pantalla de detalle**: `BreweryCard.onTap` ya existe pero no está cableado. Falta
  crear la ruta/página de detalle y pasarle el `onTap` desde `brewery_list_page.dart`.
- **Tests**: no hay tests de widget/unidad para `BreweryCard` ni `AppBadge`. Sugerido:
  casos de nombre largo, ciudad/país ausentes (fallback "Location unavailable") y
  render del badge.
- **Pantallas grandes / tablets**: la tarjeta flexa al ancho disponible, pero el
  `ListView` no limita el ancho máximo. Considerar centrar/acotar la lista en pantallas
  anchas.
- **Dark mode**: el tema y los componentes usan tokens del `ColorScheme`, pero no se
  verificó visualmente en oscuro.
- **Localización**: strings en inglés hardcodeados ("Breweries", "Location unavailable",
  etc.). Evaluar `intl` si se requiere i18n.

## Cómo correr

```bash
flutter pub get
flutter run -d <id-del-simulador>   # p.ej. iPhone 16 Pro
```
