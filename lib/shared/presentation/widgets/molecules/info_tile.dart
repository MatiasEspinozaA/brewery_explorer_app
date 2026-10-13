import 'package:flutter/material.dart';

/// A labelled piece of information: a leading icon, a small caption label and
/// one or more value lines, optionally tappable to trigger an action.
///
/// A molecule (icon + two text styles) reusable across features — e.g. the
/// brewery detail screen's address, phone and website rows. When [onTap] is
/// provided the whole row becomes tappable (Material ink) and an [actionIcon]
/// can hint at what tapping does (open in browser, call, show on a map).
/// Colors come from the [ColorScheme] so it reads well in light and dark.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.lines,
    this.onTap,
    this.actionIcon,
  }) : assert(lines.length > 0, 'InfoTile needs at least one value line');

  /// Convenience for the common single-value case.
  InfoTile.single({
    Key? key,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    IconData? actionIcon,
  }) : this(
         key: key,
         icon: icon,
         label: label,
         lines: [value],
         onTap: onTap,
         actionIcon: actionIcon,
       );

  final IconData icon;
  final String label;

  /// One display line per entry; callers omit missing data upstream.
  final List<String> lines;

  /// When provided, the row is tappable and triggers this action.
  final VoidCallback? onTap;

  /// Optional trailing icon hinting at the action (e.g. open-in-new, call).
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final interactive = onTap != null;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              for (final line in lines)
                Text(line, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        if (actionIcon != null) ...[
          const SizedBox(width: 12),
          Icon(
            actionIcon,
            size: 20,
            color: interactive ? colors.primary : colors.onSurfaceVariant,
          ),
        ],
      ],
    );

    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    if (!interactive) return Padding(padding: padding, child: row);

    return InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: row),
    );
  }
}
