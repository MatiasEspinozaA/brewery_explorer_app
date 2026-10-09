import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global service locator instance.
///
/// Widgets must not read from this directly; dependencies are injected into
/// Blocs/repositories by `injectable`, and Blocs are provided to the widget
/// tree via `BlocProvider`.
final GetIt getIt = GetIt.instance;

/// Wires up every `@injectable` dependency.
///
/// Call once from `main()` before `runApp`. The implementation lives in the
/// generated `injection.config.dart` (produced by `build_runner`).
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
