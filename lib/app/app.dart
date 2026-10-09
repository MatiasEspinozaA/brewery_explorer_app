import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget: wires the Material 3 theme and the go_router configuration.
class BreweryExplorerApp extends StatelessWidget {
  BreweryExplorerApp({super.key});

  // Built once per app instance so navigation state is preserved.
  final GoRouter _router = AppRouter.build();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brewery Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
