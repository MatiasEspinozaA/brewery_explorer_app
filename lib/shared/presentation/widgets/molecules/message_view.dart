import 'package:flutter/material.dart';

/// Centered icon + message with an optional retry action.
///
/// Reusable across features for error and empty states (and later the detail
/// screen). A molecule: it composes an icon, text and an optional button.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final IconData? icon;
  final String? title;

  /// When provided, a retry button is shown that invokes this callback.
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
