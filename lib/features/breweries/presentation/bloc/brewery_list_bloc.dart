import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/brewery.dart';
import '../../domain/repositories/brewery_repository.dart';

part 'brewery_list_event.dart';
part 'brewery_list_state.dart';

/// Drives the paginated brewery list.
///
/// Concurrency (via `bloc_concurrency`):
/// - [BreweryListStarted] is `restartable` — a retry cancels any in-flight
///   initial load.
/// - [BreweryListNextPageRequested] is `droppable` — while a page is loading,
///   extra scroll-triggered requests are ignored, preventing duplicate pages.
///
/// A failed *additional* page keeps the already-loaded items and exposes a
/// retry path (re-dispatch [BreweryListNextPageRequested]) without resetting
/// the list.
@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repository) : super(const BreweryListInitial()) {
    on<BreweryListStarted>(_onStarted, transformer: restartable());
    on<BreweryListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );
  }

  final BreweryRepository _repository;

  static const int _pageSize = 20;

  Future<void> _onStarted(
    BreweryListStarted event,
    Emitter<BreweryListState> emit,
  ) async {
    emit(const BreweryListLoadInProgress());
    try {
      final breweries = await _repository.getBreweries(
        page: 1,
        perPage: _pageSize,
      );
      emit(
        BreweryListLoadSuccess(
          breweries: breweries,
          hasReachedEnd: breweries.length < _pageSize,
        ),
      );
    } on AppException catch (error) {
      emit(BreweryListLoadFailure(_userMessage(error)));
    } catch (_) {
      emit(const BreweryListLoadFailure(_genericMessage));
    }
  }

  Future<void> _onNextPageRequested(
    BreweryListNextPageRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final current = state;
    // Paginate only when we already hold a page and more is expected.
    if (current is! BreweryListLoadSuccess || current.hasReachedEnd) return;
    if (current.paginationStatus == PaginationStatus.loadingMore) return;

    emit(current.toLoadingMore());

    // Pages are uniform (_pageSize) until the final short page, so the next
    // page index can be derived from how many items we already have.
    final nextPage = (current.breweries.length ~/ _pageSize) + 1;
    try {
      final newBreweries = await _repository.getBreweries(
        page: nextPage,
        perPage: _pageSize,
      );
      // A concurrent BreweryListStarted (restartable) may have reset the list
      // while we awaited. Only commit if this pagination is still the active
      // one, so stale results can't clobber a fresh initial load.
      final latest = _ongoingPagination();
      if (latest == null) return;
      emit(
        BreweryListLoadSuccess(
          breweries: [...latest.breweries, ...newBreweries],
          hasReachedEnd: newBreweries.length < _pageSize,
        ),
      );
    } on AppException catch (error) {
      final latest = _ongoingPagination();
      if (latest == null) return;
      emit(latest.toLoadMoreFailure(_userMessage(error)));
    } catch (_) {
      final latest = _ongoingPagination();
      if (latest == null) return;
      emit(latest.toLoadMoreFailure(_genericMessage));
    }
  }

  /// Returns the current state only if it is still our in-flight pagination.
  ///
  /// Since `droppable` allows a single pagination at a time and only this
  /// handler ever sets [PaginationStatus.loadingMore], a `loadingMore` state
  /// uniquely identifies the pagination we started. Anything else means the
  /// state moved on (e.g. a new initial load) and we must not emit.
  BreweryListLoadSuccess? _ongoingPagination() {
    final current = state;
    if (current is BreweryListLoadSuccess &&
        current.paginationStatus == PaginationStatus.loadingMore) {
      return current;
    }
    return null;
  }

  /// Converts a typed [AppException] into user-facing copy.
  String _userMessage(AppException error) => switch (error) {
    NetworkException() =>
      'No internet connection. Check your network and try again.',
    NotFoundException() => "We couldn't find any breweries.",
    ServerException() => 'Something went wrong on our end. Please try again.',
    ParsingException() =>
      'We received an unexpected response. Please try again.',
  };

  static const String _genericMessage =
      'Something unexpected happened. Please try again.';
}
