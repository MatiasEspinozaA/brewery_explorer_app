import 'package:flutter/material.dart';

/// Centralised Material 3 theme.
///
/// A single seed color drives the full [ColorScheme] in both brightnesses,
/// keeping the UI consistent without hand-picking individual colors.
class AppTheme {
  const AppTheme._();

  /// Amber/brown seed — a nod to the brewery domain.
  static const Color _seed = Color(0xFFB4530A);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
    );
  }
}
