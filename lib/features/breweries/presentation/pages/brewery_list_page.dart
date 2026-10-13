import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/presentation/widgets/molecules/message_view.dart';
import '../bloc/brewery_list_bloc.dart';
import '../widgets/brewery_card.dart';
import '../widgets/brewery_list_pagination_footer.dart';
import '../widgets/brewery_search_bar.dart';

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
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _scrollThreshold) {
      // The bloc's droppable transformer + guards dedupe repeated requests and
      // ignore pagination while a search is active.
      context.read<BreweryListBloc>().add(const BreweryListNextPageRequested());
    }
  }

  void _onSearchChanged(String query) {
    context.read<BreweryListBloc>().add(BreweryListSearchChanged(query));
  }

  void _onSearchCleared() {
    _searchController.clear();
    context.read<BreweryListBloc>().add(const BreweryListSearchChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breweries')),
      body: SafeArea(
        child: Column(
          children: [
            BrewerySearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onSearchCleared,
            ),
            Expanded(
              child: BlocBuilder<BreweryListBloc, BreweryListState>(
                builder: (context, state) {
                  return switch (state) {
                    BreweryListInitial() ||
                    BreweryListLoadInProgress() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    BreweryListLoadFailure() => MessageView(
                      icon: Icons.error_outline,
                      title: 'Something went wrong',
                      message: state.message,
                      onRetry: () => _retry(context, state),
                    ),
                    BreweryListLoadSuccess() => _BreweryListBody(
                      state: state,
                      scrollController: _scrollController,
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retry re-runs the search when the failure happened during a search, or the
  /// initial load otherwise.
  void _retry(BuildContext context, BreweryListLoadFailure state) {
    final bloc = context.read<BreweryListBloc>();
    if (state.query.isNotEmpty) {
      bloc.add(BreweryListSearchChanged(state.query));
    } else {
      bloc.add(const BreweryListStarted());
    }
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
      return state.isSearch
          ? MessageView(
              icon: Icons.search_off,
              title: 'No results',
              message: 'No breweries match "${state.query}".',
            )
          : const MessageView(
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
        final brewery = state.breweries[index];
        return BreweryCard(
          brewery: brewery,
          onTap: () => context.push(AppRoutes.breweryDetailPath(brewery.id)),
        );
      },
    );
  }
}
