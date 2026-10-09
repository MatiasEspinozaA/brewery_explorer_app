part of 'brewery_list_bloc.dart';

/// Status of an in-list pagination (append) operation.
///
/// Tracked separately from the top-level state so already-loaded items stay
/// visible while the next page loads or fails.
enum PaginationStatus { idle, loadingMore, failure }

sealed class BreweryListState extends Equatable {
  const BreweryListState();

  @override
  List<Object?> get props => [];
}

/// Nothing requested yet.
final class BreweryListInitial extends BreweryListState {
  const BreweryListInitial();
}

/// First page loading; no items yet (full-screen loader).
final class BreweryListLoadInProgress extends BreweryListState {
  const BreweryListLoadInProgress();
}

/// First page failed with no items to show. Retry re-runs the initial load.
final class BreweryListLoadFailure extends BreweryListState {
  const BreweryListLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// At least one page loaded successfully.
///
/// An empty result is represented here with an empty [breweries] list and
/// [hasReachedEnd] == true; the UI renders its empty state from [isEmpty].
final class BreweryListLoadSuccess extends BreweryListState {
  const BreweryListLoadSuccess({
    required this.breweries,
    required this.hasReachedEnd,
    this.paginationStatus = PaginationStatus.idle,
    this.paginationError,
  });

  final List<Brewery> breweries;

  /// True once a page returned fewer items than requested (no more to fetch).
  final bool hasReachedEnd;

  /// Status of a pending/failed *additional* page load.
  final PaginationStatus paginationStatus;

  /// User-facing message when [paginationStatus] is [PaginationStatus.failure].
  final String? paginationError;

  bool get isEmpty => breweries.isEmpty;

  /// Same items, now showing an append-in-progress indicator.
  BreweryListLoadSuccess toLoadingMore() => BreweryListLoadSuccess(
    breweries: breweries,
    hasReachedEnd: hasReachedEnd,
    paginationStatus: PaginationStatus.loadingMore,
  );

  /// Same items, flagged with a retriable pagination failure.
  BreweryListLoadSuccess toLoadMoreFailure(String message) =>
      BreweryListLoadSuccess(
        breweries: breweries,
        hasReachedEnd: hasReachedEnd,
        paginationStatus: PaginationStatus.failure,
        paginationError: message,
      );

  @override
  List<Object?> get props => [
    breweries,
    hasReachedEnd,
    paginationStatus,
    paginationError,
  ];
}
