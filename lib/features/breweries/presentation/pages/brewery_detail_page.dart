import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/presentation/widgets/atoms/app_badge.dart';
import '../../../../shared/presentation/widgets/molecules/info_tile.dart';
import '../../../../shared/presentation/widgets/molecules/message_view.dart';
import '../../domain/entities/brewery.dart';
import '../bloc/brewery_detail_bloc.dart';

/// Brewery detail screen.
///
/// Pure view: it expects a [BreweryDetailBloc] provided above it (see the
/// router) and renders the sealed states via a [BlocBuilder]. The [breweryId]
/// is only used to re-dispatch [BreweryDetailStarted] on retry.
///
/// The name is shown once — as the content hero — so the [AppBar] stays title-
/// less (just the back affordance) rather than repeating it.
class BreweryDetailPage extends StatelessWidget {
  const BreweryDetailPage({super.key, required this.breweryId});

  final String breweryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<BreweryDetailBloc, BreweryDetailState>(
          builder: (context, state) {
            return switch (state) {
              BreweryDetailInitial() ||
              BreweryDetailLoadInProgress() => const Center(
                child: CircularProgressIndicator(),
              ),
              BreweryDetailLoadFailure(:final message) => MessageView(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                message: message,
                onRetry: () => context.read<BreweryDetailBloc>().add(
                  BreweryDetailStarted(breweryId),
                ),
              ),
              BreweryDetailLoadSuccess(:final brewery) => _BreweryDetailBody(
                brewery: brewery,
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Scrollable detail content: the name/type hero, a grouped card of contact
/// info (address, phone, website) and a trailing back action. Each contact row
/// is omitted when its data is missing, and tappable when it has an action.
class _BreweryDetailBody extends StatelessWidget {
  const _BreweryDetailBody({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          brewery.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: AppBadge(label: _formatType(brewery.breweryType)),
        ),
        const SizedBox(height: 28),
        _ContactCard(brewery: brewery),
        const SizedBox(height: 32),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ),
      ],
    );
  }

  /// `micro` -> `Micro`. The API returns types lowercased.
  String _formatType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }
}

/// Groups the contact rows in a single Material 3 surface, separated by
/// dividers. Only the rows with data are rendered.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    final addressLines = brewery.addressLines;
    final hasPhone = _hasText(brewery.phone);
    final hasWebsite = _hasText(brewery.websiteUrl);
    final canOpenMap = addressLines.isNotEmpty || brewery.hasCoordinates;

    final tiles = <Widget>[
      // Address is always shown (falls back to a non-tappable placeholder) so
      // the card is never empty.
      InfoTile(
        icon: Icons.location_on_outlined,
        label: 'Address',
        lines: addressLines.isEmpty ? const ['Address unavailable'] : addressLines,
        actionIcon: canOpenMap ? Icons.map_outlined : null,
        onTap: canOpenMap ? () => _openMap(context) : null,
      ),
      if (hasPhone)
        InfoTile.single(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: brewery.phone!.trim(),
          actionIcon: Icons.call,
          onTap: () => _call(context),
        ),
      if (hasWebsite)
        InfoTile.single(
          icon: Icons.language_outlined,
          label: 'Website',
          value: brewery.websiteUrl!.trim(),
          actionIcon: Icons.open_in_new,
          onTap: () => _openWebsite(context),
        ),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            tiles[i],
          ],
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context) {
    final digits = brewery.phone!.replaceAll(RegExp(r'[^\d+]'), '');
    return _launch(context, Uri(scheme: 'tel', path: digits));
  }

  Future<void> _openWebsite(BuildContext context) {
    final raw = brewery.websiteUrl!.trim();
    final uri = raw.startsWith('http') ? Uri.parse(raw) : Uri.parse('https://$raw');
    return _launch(context, uri);
  }

  Future<void> _openMap(BuildContext context) {
    final query = brewery.hasCoordinates
        ? '${brewery.latitude},${brewery.longitude}'
        : brewery.addressLines.join(', ');
    final encoded = Uri.encodeComponent(query);
    // Apple Maps on iOS feels native; everywhere else a universal Google Maps
    // search URL opens the Maps app or the browser.
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://maps.apple.com/?q=$encoded')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    return _launch(context, uri);
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Couldn't open this link.")),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open this link.")),
      );
    }
  }

  static bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
