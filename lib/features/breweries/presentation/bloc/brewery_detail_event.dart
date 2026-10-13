part of 'brewery_detail_bloc.dart';

sealed class BreweryDetailEvent extends Equatable {
  const BreweryDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the brewery with [id]. Re-dispatch to retry after a failure.
final class BreweryDetailStarted extends BreweryDetailEvent {
  const BreweryDetailStarted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
