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
