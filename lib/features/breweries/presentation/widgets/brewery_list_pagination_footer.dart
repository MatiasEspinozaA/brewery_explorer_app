import 'package:flutter/material.dart';

import '../bloc/brewery_list_bloc.dart';

/// Footer shown at the bottom of the list while an additional page is loading
/// or after it failed.
///
/// On failure it keeps the loaded items untouched and offers a retry that
/// re-dispatches the pagination request.
class BreweryListPaginationFooter extends StatelessWidget {
  const BreweryListPaginationFooter({
    super.key,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
  });

  final PaginationStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: switch (status) {
          PaginationStatus.loadingMore => const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          PaginationStatus.failure => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage ?? 'Could not load more breweries.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
          PaginationStatus.idle => const SizedBox.shrink(),
        },
      ),
    );
  }
}
