# Transparencia de uso de IA

Este documento registra, con fines de transparencia para la evaluación del test, los
prompts utilizados y las decisiones tomadas con asistencia de IA (Claude Code) durante
el desarrollo de la app. Se recupera desde el primer prompt del proyecto.

Herramienta: **Claude Code** (modelo Claude Opus 4.8).

---

## Sesión 1 — 2026-10-09 · Scaffold, capas Domain/Data y pantalla de listado

### Prompts utilizados (verbatim)

> _Nota: el primer prompt fue interrumpido y reenviado con los datos del repositorio;
> se incluye la versión completa (P1)._

**P1.**
"Vamos a desarrollar una aplicación pequeña pero funcional en Flutter utilizando la API
de Open Brewery DB. Te adjunto un PDF con los requisitos que debemos considerar.
Quiero que trabajemos de forma incremental, revisando cada etapa antes de continuar.
Para comenzar, necesito que prepares la estructura base del proyecto utilizando Clean
Architecture organizada por features y separada en Data, Domain y Presentation.
Utilizaremos flutter_bloc para manejar los estados, Dio para las peticiones HTTP, get_it
e injectable para la inyección de dependencias y Material 3 para la interfaz.
En cuanto a la UI, quiero que consideres SafeArea para respetar las áreas seguras de los
dispositivos y que utilicemos los principios de Atomic Design para organizar los
componentes reutilizables en átomos, moléculas y organismos cuando corresponda, evitando
crear componentes o niveles de abstracción innecesarios.
Utilizaremos Git y GitHub para el control de versiones, trabajando con el siguiente
repositorio: git@github.com:MatiasEspinozaA/brewery_explorer_app.git
Quiero que mantengamos un historial de commits claro y descriptivo, separando los cambios
por funcionalidades o etapas. No realices commits ni pushes sin consultarme previamente.
Por ahora enfócate únicamente en configurar las dependencias, organizar las carpetas y
preparar la estructura inicial. No implementes todavía las funcionalidades ni los tests,
ya que iremos avanzando y tomando decisiones juntos. Prioriza un código limpio,
mantenible y sin sobreingeniería.
También quiero que tengas presente que documentaremos de forma transparente el uso de IA
en el README, incluyendo nuestra conversación como parte de la entrega. Quiero que actúes
como mi asistente de desarrollo, proponiendo mejoras cuando sea necesario, pero
consultándome antes de tomar decisiones importantes."

**P2.**
"Vamos a prescindir de los Use Cases por ahora, ya que no tenemos lógica de negocio que
justifique incorporarlos. Los Bloc consumirán directamente las interfaces de repositorio
definidas en Domain.
Utilizaremos Bloc en ambas pantallas pensando en la escalabilidad y futuras
funcionalidades, manteniendo una gestión de estados consistente. Para el listado
consideraremos infinite scroll y control de concurrencia.
Puedes avanzar con Domain y Data, implementando entidades, DTO con mapping, contratos de
repositorio, datasource y manejo de errores tipados con Dio. Considera también los campos
opcionales de la API.
Por ahora no implementes los Bloc ni las pantallas, primero revisaremos estas capas."

**P3.**
"Estoy de acuerdo con las decisiones tomadas y con detectar el final de la paginación
cuando recibamos menos elementos que el límite solicitado.
Puedes avanzar con BreweryListBloc utilizando eventos y estados sellados, considerando
infinite scroll, control de concurrencia con bloc_concurrency y manejo de errores. Si
falla una carga adicional, debemos conservar los elementos anteriores y permitir
reintentar sin reiniciar el listado.
Por ahora implementa únicamente el Bloc con sus eventos y estados. Revisaremos su
funcionamiento antes de continuar con la interfaz."

**P4.**
"Me parece correcto derivar la siguiente página desde la cantidad de elementos cargados,
no necesitamos agregar un campo adicional al estado.
Solo verifica que una petición de paginación en curso no pueda sobrescribir los
resultados de una nueva carga inicial, considerando que restartable y droppable gestionan
eventos diferentes.
Puedes avanzar con la interfaz del listado utilizando Material 3, SafeArea y Atomic
Design para los componentes reutilizables. Considera los estados de carga, error y lista
vacía, además del infinite scroll con su indicador de carga y opción de reintentar.
Evitemos FutureBuilder, ya que Bloc gestionará los estados. Por ahora enfoquémonos
únicamente en la pantalla del listado, sin implementar todavía el detalle ni los tests."

**P5.** "Levanta la app en el simulador" _(se ejecutó y verificó con capturas de pantalla)._

### Decisiones tomadas

- **Arquitectura**: Clean Architecture por feature, separada en Data / Domain /
  Presentation. Stack: `flutter_bloc`, `dio`, `get_it` + `injectable`, Material 3.
- **Sin Use Cases**: no hay lógica de negocio que los justifique; los Bloc consumen
  directamente las interfaces de repositorio del Domain (evitar sobreingeniería).
- **Atomic Design** para componentes reutilizables (atoms/molecules/organisms), creando
  niveles solo cuando corresponde.
- **SafeArea** para respetar áreas seguras.
- **Data/Domain**: entidades, DTO con mapping, contratos de repositorio, datasource y
  **errores tipados** con Dio. Se contemplan los campos opcionales de la API.
- **Paginación**: fin de la paginación detectado cuando llegan menos elementos que el
  límite solicitado; la siguiente página se **deriva de la cantidad de elementos
  cargados** (sin campo extra en el estado).
- **Concurrencia**: `bloc_concurrency`; una petición de paginación en curso no debe
  sobrescribir una nueva carga inicial (`restartable` vs `droppable` para eventos
  distintos).
- **Resiliencia**: si falla una carga adicional, se conservan los elementos previos y se
  permite reintentar sin reiniciar el listado.
- **BLoC con eventos y estados sellados**; se evita `FutureBuilder` (el Bloc gestiona los
  estados).
- **Estados de UI** del listado: carga, error y lista vacía; infinite scroll con
  indicador de carga y opción de reintentar.
- **Control de versiones**: historial de commits claro y descriptivo, separado por
  etapa/funcionalidad; no commitear/pushear sin consultar.

---

## Sesión 2 — 2026-10-09 · Primer commit, BreweryCard y documentación

### Prompts utilizados (verbatim)

**P1.** "Levanta la app en el simulador" _(interrumpido por el usuario para pasar al commit)._

**P2.** "Perfecto, hagamos el primer commit"

**P3.** "Quiero mejorar el diseño de las tarjetas del listado creando un componente
llamado `BreweryCard`, siguiendo los principios de Atomic Design. La tarjeta debe mostrar
el nombre de la cervecería, su tipo mediante un badge y debajo la ciudad junto al país,
acompañados de un ícono de ubicación. También quiero incluir una flecha que indique que
se puede acceder al detalle. Utiliza Material 3, respetando el tema de la aplicación, con
bordes redondeados, espaciados consistentes y un diseño moderno y minimalista. Considera
nombres largos, datos opcionales y diferentes tamaños de pantalla. Reemplaza
`BreweryListTile` por `BreweryCard`, manteniendo su comportamiento actual. Reutiliza los
componentes existentes cuando corresponda y evita abstracciones innecesarias."

**P4.** "Sí, commitea los cambios"

**P5.** "Vamos a dejar la sesión aquí por hoy, creemos un handoff para anotar lo que se
hizo y lo pendiente. Recuerda crear el documento de transparencia con los prompts
utilizados y las decisiones tomadas."

### Decisiones tomadas

- **Excluir el PDF del enunciado** (`Forest Senior Mobile Engineer (Flutter) Test.pdf`)
  del control de versiones vía `.gitignore` (`*.pdf`): es la consigna del test, no parte
  del producto. El resto del `.gitignore` es el estándar de Flutter.
- **Promover el badge a un átomo compartido** (`AppBadge` en `shared/.../atoms/`): antes
  era un widget privado dentro del tile; es genérico y reutilizable, por lo que encaja
  como átomo real de Atomic Design. Sin parámetros de estilo extra para evitar abstracción
  innecesaria; usa tokens del `ColorScheme`.
- **Mantener `BreweryCard` dentro del feature**: conoce la entidad `Brewery`, así que es
  específico del feature (misma lógica que el `BreweryListTile` original).
- **Dejar la fila de ubicación como widget privado** (`_LocationRow`): se usa una sola
  vez; promoverla sería abstracción prematura.
- **Ubicación con degradación elegante**: se unen `[ciudad, país]` no vacíos con ", "; si
  faltan ambos, "Location unavailable" (se preserva el fallback original y se extiende con
  el país).
- **Nombres largos**: título a 2 líneas con elipsis; columna con `Expanded` para adaptarse
  a distintos anchos.
- **Capitalización ligera del tipo** (`micro` → `Micro`): mejora visual mínima, sin
  cambiar el comportamiento funcional.
- **Material 3**: `Card` con bordes redondeados (16 px), `InkWell` para feedback táctil,
  padding/espaciados consistentes y `chevron_right` como indicador de navegación al
  detalle. Colores desde el `ColorScheme` (consistente en claro/oscuro).
- **Comportamiento preservado**: `BreweryCard` mantiene la API (`brewery`, `onTap`); el
  `onTap` sigue sin cablearse, listo para la futura pantalla de detalle.
- **Verificación**: `flutter analyze` sin issues y validación visual en el simulador
  iPhone 16 Pro antes de commitear.
- **Documentación de cierre**: se creó `HANDOFF.md` (estado y pendientes) y este
  documento de transparencia.

---

## Sesión 3 — 2026-10-13 · Pantalla de detalle y navegación

### Prompts utilizados (verbatim)

**P1.** "Leeamos el ultimo handoff"

**P2.** "Continuemos con la pantalla de detalle. Primero verifica que el DTO y la entidad
incluyan todos los campos de la API, especialmente las direcciones.
Implementa BreweryDetailBloc con estados y eventos sellados, consultando el detalle por ID
y manejando loading, success, error y reintentos.
Conecta BreweryCard con la pantalla mediante go_router y muestra nombre, dirección,
teléfono y sitio web, considerando valores nulos. Mantén Material 3, SafeArea y Atomic
Design, reutilizando componentes existentes.
Por ahora solo implementemos el detalle y su navegación. Después revisaremos el resultado
en el simulador."

### Decisiones tomadas

- **Campos de dirección faltantes**: se consultó la API real y se confirmó que el detalle
  expone `address_1`, `address_2`, `address_3` (líneas canónicas), además del legacy
  `street`. El DTO/entidad solo tenían `street`; se agregaron `address1/2/3` al DTO (con
  su mapping) y a la entidad. `state` se omitió por ser un duplicado legacy de
  `state_province` (evitar ruido).
- **Dirección formateada en el Domain**: la entidad expone un getter `addressLines` que
  arma las líneas visibles (calle → `address1` con fallback a `street`; luego `address2/3`;
  "City, State PostalCode"; país), omitiendo lo ausente. La lógica de presentación del
  dato vive en el dominio, no en el widget.
- **BreweryDetailBloc** con eventos/estados **sellados**, espejando el patrón del
  `BreweryListBloc`: estados `Initial / LoadInProgress / LoadSuccess / LoadFailure`;
  evento único `BreweryDetailStarted(id)`. El **id viaja en el evento** (no se inyecta),
  así el Bloc sigue siendo un factory que solo depende del repositorio. Transformer
  `restartable` para que un reintento cancele una carga en vuelo. Reintento = re-despachar
  `BreweryDetailStarted`. Mensajes de error tipados reutilizando el mismo mapeo de
  `AppException`.
- **Navegación con go_router**: nueva `GoRoute` `/breweries/:id`; el `BlocProvider` se crea
  en el router (composition root) y despacha `BreweryDetailStarted(id)`. Se agregó
  `AppRoutes.breweryDetailPath(id)` (con `Uri.encodeComponent`) para navegación tipada; la
  lista usa `context.push(...)` en el `onTap` de `BreweryCard` (ya existía el parámetro).
- **UI del detalle**: `Scaffold` + `SafeArea` + `BlocBuilder` sobre estados sellados
  (loader / `MessageView` con reintento / contenido). Se muestra nombre, badge de tipo,
  dirección, teléfono y sitio web; cada sección se omite si el dato falta ("Address
  unavailable" cuando no hay ninguna línea). El `AppBar` muestra el nombre solo tras cargar.
- **Nuevo molecule compartido `InfoTile`** (ícono + etiqueta + valor/líneas): genérico y
  reutilizable (dirección/teléfono/web), encaja en Atomic Design. Se reutilizaron
  `AppBadge` y `MessageView`.
- **Teléfono/web como texto** (sin acciones `tel:`/`http`): `url_launcher` no está en las
  dependencias y el alcance de la sesión era "solo detalle y navegación"; no se agregaron
  dependencias nuevas.
- **Verificación**: `flutter analyze` sin issues; DI regenerada con `build_runner`
  (registra `BreweryDetailBloc`). Pendiente revisar en el simulador (acordado para después).

**P3.** "Levantemos la aplicación en el simulador para validar el flujo completo desde el
listado hasta el detalle. Revisemos la navegación, los estados de carga y error, el manejo
de campos nulos y la adaptación de la interfaz a diferentes contenidos. Verifica también
que addressLines priorice address_1 y utilice street como alternativa para evitar
direcciones duplicadas. Por ahora no agregues nuevas funcionalidades. Si encontramos
problemas, los corregimos antes de continuar."

### Validación en simulador (iPhone 16 Pro, iOS 18.3)

- **`addressLines` (verificado con un arnés Dart temporal, luego eliminado)**: con
  `address_1` == `street` produce **una sola** línea (sin duplicar); con `address_1` nulo
  usa `street` como alternativa; con ambos distintos **gana `address_1`**; sin datos de
  ubicación devuelve lista vacía (la UI muestra "Address unavailable"). Confirmado también
  en vivo: "'s" renderiza "Friesener Straße 1" una sola vez.
- **Navegación**: lista → detalle (tap en `BreweryCard`) y vuelta atrás (chevron del
  `AppBar`) funcionan. ✓
- **Detalle con datos completos**: dirección multilínea ("City, State PostalCode" + país),
  teléfono y sitio web; se verificó con varias cervecerías (US y europeas, incluyendo
  Unicode "Straße"). El `AppBar` muestra "Brewery" durante la carga y el nombre tras cargar. ✓
- **Estado de carga**: spinner centrado visible durante el fetch del detalle. ✓
- **Estado de error + reintento**: con Wi‑Fi apagado, el detalle muestra `MessageView` con
  "No internet connection…" (mensaje tipado de `NetworkException`) y botón **Retry**; al
  restaurar la red y tocar Retry, carga el detalle correctamente. ✓
- **Limitación de tooling (no de la app)**: no se logró capturar en vivo un detalle con
  teléfono/web nulos porque el scroll por entrada sintética (drag/rueda) no se engancha de
  forma fiable con el `ListView` de Flutter en este simulador, impidiendo llegar a esas
  cervecerías (están más abajo en la lista). El manejo de nulos quedó verificado por la
  lógica (`addressLines` + render condicional de secciones) y por el estado de error en vivo.
- **Resultado**: no se encontraron problemas en la app; `flutter analyze` sin issues.

**P4.** "Mejoremos la UI/UX de BreweryDetailPage manteniendo Material 3, SafeArea y Atomic
Design. Agrega url_launcher para abrir el sitio web y llamar al teléfono directamente, con
íconos que indiquen estas acciones. También permite abrir la dirección en Maps cuando sea
posible. Mejora los espaciados y la jerarquía visual, evitando repetir el nombre en el
AppBar y el contenido. Agrega un botón «Volver» al final de la información para facilitar
la navegación. Mantén el diseño minimalista, considera los campos opcionales y reutiliza
los componentes existentes sin agregar complejidad innecesaria."

### Decisiones tomadas (mejora UI/UX del detalle)

- **`url_launcher`** agregado (`^6.3.1`). Acciones: web → abre el navegador
  (`LaunchMode.externalApplication`), teléfono → `tel:` (dígitos saneados), dirección →
  Maps. Se usa `launchUrl` directo con `try/catch` + `SnackBar` de fallback
  ("Couldn't open this link."), sin `canLaunchUrl`, por lo que **no hubo que tocar
  Info.plist** ni listar esquemas.
- **Maps "cuando sea posible"**: si hay coordenadas se usan; si no, la dirección formateada.
  En iOS se abre **Apple Maps** (`maps.apple.com`), en el resto una URL universal de Google
  Maps (`defaultTargetPlatform`, sin `dart:io`). La fila de dirección solo es accionable si
  hay dirección o coordenadas.
- **Sin repetir el nombre**: el `AppBar` quedó **sin título** (solo el botón atrás) y el
  nombre se muestra una sola vez como *hero* del contenido. Se eliminó el `BlocBuilder` del
  título.
- **Jerarquía/espaciado**: las filas de contacto se agrupan en un **`Card` M3** con
  divisores; cada fila es un `InfoTile` con ícono de categoría (leading) y un **ícono de
  acción** (trailing: mapa / llamar / abrir-en-nuevo). Se agregó `onTap` + `actionIcon` al
  molecule `InfoTile` (reutilizado, sin romper usos previos).
- **Botón de volver al final**: `OutlinedButton.icon` centrado con `context.pop()`. Etiqueta
  en **inglés ("Back")** por consistencia con el resto de la UI (todo el texto actual está
  en inglés; la i18n sigue pendiente). Si se prefiere «Volver» literal, es un cambio trivial.
- **Campos opcionales**: teléfono/web se omiten si faltan; la dirección cae a "Address
  unavailable" (no accionable) si no hay datos.

### Validación en simulador (nueva UI)

- Detalle rediseñado: AppBar sin título, hero nombre+badge, `Card` agrupada con íconos de
  acción, botón "Back". ✓
- **Abrir en Maps**: tap en la dirección abre **Apple Maps** con la consulta. ✓
- **Abrir web**: tap en Website abre **Safari** en la URL. ✓
- **Llamar**: en el simulador no hay app de teléfono → degrada con `SnackBar`
  ("Couldn't open this link.") sin crash; en dispositivo real abriría el marcador. ✓
- **Botón "Back"**: vuelve al listado. ✓
- `flutter analyze` sin issues; reconstrucción con `pod install` (plugin nativo) OK.

**P5.** "Implementemos el bonus de búsqueda con debounce utilizando el endpoint de búsqueda
de Open Brewery DB. Agrega un SearchBar de Material 3 al listado y utiliza BreweryListBloc
con bloc_concurrency para gestionar las búsquedas, aplicando un debounce de 400 ms y
evitando solicitudes innecesarias o resultados obsoletos. Considera los estados de carga,
error y sin resultados. Al limpiar la búsqueda debe restaurarse el listado normal con su
infinite scroll, evitando conflictos entre ambos modos. Mantén nuestra arquitectura,
Atomic Design y componentes reutilizables. Agrega pruebas para el debounce y la
concurrencia, y valida con flutter test y flutter analyze."

### Decisiones tomadas (búsqueda con debounce)

- **Capa de datos**: nuevo `searchBreweries(query, perPage)` en datasource y repositorio
  (endpoint `/breweries/search`), con el mismo mapeo de errores tipados.
- **Mismo `BreweryListBloc`** (como se pidió): nuevo evento `BreweryListSearchChanged(query)`
  con transformer **debounce (400 ms) + restartable** (`stream_transform.debounce` encadenado
  con `bloc_concurrency.restartable`). El debounce colapsa las pulsaciones (evita solicitudes
  innecesarias) y `restartable` cancela una búsqueda en vuelo cuando llega una más nueva
  (evita resultados obsoletos).
- **Sin conflicto entre modos**: los resultados de búsqueda se emiten como una sola página
  (`hasReachedEnd: true`), así el `NextPageRequested` queda deshabilitado por la guarda
  existente mientras se busca. Al limpiar (`query` vacío) se recarga la primera página normal,
  restaurando el infinite scroll. La guarda `_ongoingPagination()` además descarta una
  paginación en vuelo si el modo cambió.
- **Estado**: se añadió `query` a `LoadSuccess`/`LoadFailure` (getter `isSearch`) para
  distinguir resultados de búsqueda, su estado "sin resultados" y para que el reintento
  re-ejecute la búsqueda (no la lista normal).
- **Debounce testeable**: el bloc recibe `searchDebounce` como `@factoryParam` (fuera de DI;
  `getIt` usa el default de 400 ms, los tests inyectan 20 ms para ser rápidos y
  deterministas).
- **UI (Atomic Design)**: nuevo widget `BrewerySearchBar` (molecule, Material 3 `SearchBar`,
  desacoplado del bloc vía callbacks; botón de limpiar condicional). La página lo coloca
  sobre la lista dentro de `SafeArea`; estados de carga/error/sin-resultados reutilizan
  `MessageView`. El reintento distingue búsqueda vs lista por `state.query`.
- **Tests**: debounce (solo la última query pega a la red, una vez), restartable (gana la
  query más nueva y se descarta el resultado lento), limpiar restaura la primera página,
  éxito/vacío/error de búsqueda, y que no pagina en modo búsqueda. Más widget tests de
  `BrewerySearchBar`. Total 43 tests, `flutter analyze` sin issues.

### Validación en simulador

- SearchBar M3 renderiza; escribir "dog" (rápido) dispara **una** búsqueda tras el debounce
  y muestra resultados. Estado de carga (spinner), sin-resultados ("No breweries match
  …"), y limpiar (X) restaura el listado normal — todo verificado. ✓
