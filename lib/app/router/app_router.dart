import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/breweries/presentation/bloc/brewery_detail_bloc.dart';
import '../../features/breweries/presentation/bloc/brewery_list_bloc.dart';
import '../../features/breweries/presentation/pages/brewery_detail_page.dart';
import '../../features/breweries/presentation/pages/brewery_list_page.dart';

/// Route paths, kept as constants to avoid stringly-typed navigation.
class AppRoutes {
  const AppRoutes._();

  /// Brewery list (home).
  static const String breweries = '/';

  /// Brewery detail. Expects an `:id` path parameter.
  static const String breweryDetail = '/breweries/:id';

  /// Builds the concrete detail path for [id] (encodes the id for safety).
  static String breweryDetailPath(String id) =>
      '/breweries/${Uri.encodeComponent(id)}';
}

/// Builds the app's [GoRouter].
///
/// The composition root for each feature lives here: the service locator is
/// read only to construct Blocs, which are then provided to the widget tree.
/// Widgets themselves never touch `getIt`.
class AppRouter {
  const AppRouter._();

  static GoRouter build() {
    return GoRouter(
      initialLocation: AppRoutes.breweries,
      routes: [
        GoRoute(
          path: AppRoutes.breweries,
          builder: (context, state) => BlocProvider(
            create: (_) =>
                getIt<BreweryListBloc>()..add(const BreweryListStarted()),
            child: const BreweryListPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.breweryDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) =>
                  getIt<BreweryDetailBloc>()..add(BreweryDetailStarted(id)),
              child: BreweryDetailPage(breweryId: id),
            );
          },
        ),
      ],
    );
  }
}
