import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/presentation/widgets/molecules/message_view.dart';
import '../bloc/brewery_list_bloc.dart';
import '../widgets/brewery_card.dart';
import '../widgets/brewery_list_pagination_footer.dart';

/// Brewery list screen.
///
/// Pure view: it expects a [BreweryListBloc] provided above it (see the router)
/// and never touches the service locator itself. State is rendered via a
/// [BlocBuilder] over the sealed states — no `FutureBuilder`.
class BreweryListPage extends StatefulWidget {
  const BreweryListPage({super.key});

  @override
  State<BreweryListPage> createState() => _BreweryListPageState();
}

class _BreweryListPageState extends State<BreweryListPage> {
  final ScrollController _scrollController = ScrollController();

  /// How close to the bottom (in px) triggers loading the next page.
  static const double _scrollThreshold = 300;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _scrollThreshold) {
      // The bloc's droppable transformer + guards dedupe repeated requests.
      context.read<BreweryListBloc>().add(const BreweryListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breweries')),
      body: SafeArea(
        child: BlocBuilder<BreweryListBloc, BreweryListState>(
          builder: (context, state) {
            return switch (state) {
              BreweryListInitial() ||
              BreweryListLoadInProgress() => const Center(
                child: CircularProgressIndicator(),
              ),
              BreweryListLoadFailure(:final message) => MessageView(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                message: message,
                onRetry: () => context.read<BreweryListBloc>().add(
                  const BreweryListStarted(),
                ),
              ),
              BreweryListLoadSuccess() => _BreweryListBody(
                state: state,
                scrollController: _scrollController,
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Renders the loaded list (or the empty state) plus the pagination footer.
class _BreweryListBody extends StatelessWidget {
  const _BreweryListBody({required this.state, required this.scrollController});

  final BreweryListLoadSuccess state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) {
      return const MessageView(
        icon: Icons.sports_bar_outlined,
        title: 'No breweries found',
        message: 'There are no breweries to show right now.',
      );
    }

    final showFooter = state.paginationStatus != PaginationStatus.idle;
    final itemCount = state.breweries.length + (showFooter ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= state.breweries.length) {
          return BreweryListPaginationFooter(
            status: state.paginationStatus,
            errorMessage: state.paginationError,
            onRetry: () => context.read<BreweryListBloc>().add(
              const BreweryListNextPageRequested(),
            ),
          );
        }
        return BreweryCard(brewery: state.breweries[index]);
      },
    );
  }
}
