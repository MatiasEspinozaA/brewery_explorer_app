import 'package:flutter/material.dart';

import '../../domain/entities/brewery.dart';

/// List row for a single brewery: name, city and a type badge.
///
/// Feature-specific (knows the [Brewery] entity), so it lives with the feature
/// rather than in the shared widgets. [onTap] is wired when the detail screen
/// is added.
class BreweryListTile extends StatelessWidget {
  const BreweryListTile({super.key, required this.brewery, this.onTap});

  final Brewery brewery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(
          brewery.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          brewery.city ?? 'Location unavailable',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _BreweryTypeBadge(type: brewery.breweryType),
      ),
    );
  }
}

/// Small Material 3 pill showing the brewery type. Private: only the tile uses
/// it today, so it isn't promoted to a shared atom yet.
class _BreweryTypeBadge extends StatelessWidget {
  const _BreweryTypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
        ),
      ),
    );
  }
}
