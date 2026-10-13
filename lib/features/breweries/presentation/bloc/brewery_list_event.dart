part of 'brewery_list_bloc.dart';

sealed class BreweryListEvent extends Equatable {
  const BreweryListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page. Re-dispatch to retry after an initial load failure.
final class BreweryListStarted extends BreweryListEvent {
  const BreweryListStarted();
}

/// Requests the next page (infinite scroll).
///
/// Re-dispatch this same event to retry a failed additional page — the
/// existing items are preserved.
final class BreweryListNextPageRequested extends BreweryListEvent {
  const BreweryListNextPageRequested();
}

/// The search query changed. Debounced in the bloc; an empty [query] restores
/// the normal paginated list.
final class BreweryListSearchChanged extends BreweryListEvent {
  const BreweryListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
