import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/atoms/app_badge.dart';
import '../../domain/entities/brewery.dart';

/// Card for a single brewery in the list: name, a type badge, the location
/// (city + country) and a trailing chevron hinting at the detail screen.
///
/// Feature-specific (knows the [Brewery] entity), so it lives with the feature
/// rather than in the shared widgets. [onTap] is wired when the detail screen
/// is added. Built to cope with long names (wraps to two lines), missing
/// optional fields and varying widths (the content column flexes).
class BreweryCard extends StatelessWidget {
  const BreweryCard({super.key, required this.brewery, this.onTap});

  final Brewery brewery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      brewery.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppBadge(label: _formatType(brewery.breweryType)),
                    const SizedBox(height: 12),
                    _LocationRow(brewery: brewery),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  /// `micro` -> `Micro`. Light polish; the API returns types lowercased.
  String _formatType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }
}

/// Location line: a pin icon followed by "City, Country", degrading gracefully
/// when either field is missing (and showing a fallback when both are).
class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    final parts = [brewery.city, brewery.country]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toList();
    final label = parts.isEmpty ? 'Location unavailable' : parts.join(', ');

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
