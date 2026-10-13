part of 'brewery_detail_bloc.dart';

sealed class BreweryDetailState extends Equatable {
  const BreweryDetailState();

  @override
  List<Object?> get props => [];
}

/// Nothing requested yet.
final class BreweryDetailInitial extends BreweryDetailState {
  const BreweryDetailInitial();
}

/// The brewery is being fetched (full-screen loader).
final class BreweryDetailLoadInProgress extends BreweryDetailState {
  const BreweryDetailLoadInProgress();
}

/// The brewery loaded successfully.
final class BreweryDetailLoadSuccess extends BreweryDetailState {
  const BreweryDetailLoadSuccess(this.brewery);

  final Brewery brewery;

  @override
  List<Object?> get props => [brewery];
}

/// The load failed. Retry re-runs [BreweryDetailStarted].
final class BreweryDetailLoadFailure extends BreweryDetailState {
  const BreweryDetailLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
