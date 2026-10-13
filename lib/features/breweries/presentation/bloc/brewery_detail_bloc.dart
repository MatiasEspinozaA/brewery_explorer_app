import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/brewery.dart';
import '../../domain/repositories/brewery_repository.dart';

part 'brewery_detail_event.dart';
part 'brewery_detail_state.dart';

/// Loads a single brewery's detail by id.
///
/// The id is carried on [BreweryDetailStarted] rather than injected, so the
/// bloc stays a plain factory (one per detail route) that only needs the
/// repository. Re-dispatching [BreweryDetailStarted] retries after a failure;
/// the `restartable` transformer cancels any in-flight load so a retry can't
/// be clobbered by a stale response.
@injectable
class BreweryDetailBloc extends Bloc<BreweryDetailEvent, BreweryDetailState> {
  BreweryDetailBloc(this._repository) : super(const BreweryDetailInitial()) {
    on<BreweryDetailStarted>(_onStarted, transformer: restartable());
  }

  final BreweryRepository _repository;

  Future<void> _onStarted(
    BreweryDetailStarted event,
    Emitter<BreweryDetailState> emit,
  ) async {
    emit(const BreweryDetailLoadInProgress());
    try {
      final brewery = await _repository.getBreweryById(event.id);
      emit(BreweryDetailLoadSuccess(brewery));
    } on AppException catch (error) {
      emit(BreweryDetailLoadFailure(_userMessage(error)));
    } catch (_) {
      emit(const BreweryDetailLoadFailure(_genericMessage));
    }
  }

  /// Converts a typed [AppException] into user-facing copy.
  String _userMessage(AppException error) => switch (error) {
    NetworkException() =>
      'No internet connection. Check your network and try again.',
    NotFoundException() => "We couldn't find this brewery.",
    ServerException() => 'Something went wrong on our end. Please try again.',
    ParsingException() =>
      'We received an unexpected response. Please try again.',
  };

  static const String _genericMessage =
      'Something unexpected happened. Please try again.';
}
