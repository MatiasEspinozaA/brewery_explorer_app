import 'package:bloc_test/bloc_test.dart';
import 'package:brewery_explorer_app/core/error/exceptions.dart';
import 'package:brewery_explorer_app/features/breweries/domain/entities/brewery.dart';
import 'package:brewery_explorer_app/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:brewery_explorer_app/features/breweries/presentation/bloc/brewery_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  late _MockBreweryRepository repository;

  setUp(() => repository = _MockBreweryRepository());

  BreweryDetailBloc build() => BreweryDetailBloc(repository);

  const id = 'abc-123';
  const brewery = Brewery(id: id, name: 'Test Brewery', breweryType: 'micro');

  blocTest<BreweryDetailBloc, BreweryDetailState>(
    'emits [loading, success] when the brewery is found',
    setUp: () =>
        when(() => repository.getBreweryById(id)).thenAnswer((_) async => brewery),
    build: build,
    act: (bloc) => bloc.add(const BreweryDetailStarted(id)),
    expect: () => const [
      BreweryDetailLoadInProgress(),
      BreweryDetailLoadSuccess(brewery),
    ],
    verify: (_) => verify(() => repository.getBreweryById(id)).called(1),
  );

  blocTest<BreweryDetailBloc, BreweryDetailState>(
    'maps a NotFoundException to a detail-specific message',
    setUp: () =>
        when(() => repository.getBreweryById(id)).thenThrow(const NotFoundException()),
    build: build,
    act: (bloc) => bloc.add(const BreweryDetailStarted(id)),
    expect: () => const [
      BreweryDetailLoadInProgress(),
      BreweryDetailLoadFailure("We couldn't find this brewery."),
    ],
  );

  blocTest<BreweryDetailBloc, BreweryDetailState>(
    'maps a NetworkException to the connection failure message',
    setUp: () =>
        when(() => repository.getBreweryById(id)).thenThrow(const NetworkException()),
    build: build,
    act: (bloc) => bloc.add(const BreweryDetailStarted(id)),
    expect: () => const [
      BreweryDetailLoadInProgress(),
      BreweryDetailLoadFailure(
        'No internet connection. Check your network and try again.',
      ),
    ],
  );

  blocTest<BreweryDetailBloc, BreweryDetailState>(
    'maps an unexpected error to the generic message',
    setUp: () =>
        when(() => repository.getBreweryById(id)).thenThrow(Exception('boom')),
    build: build,
    act: (bloc) => bloc.add(const BreweryDetailStarted(id)),
    expect: () => const [
      BreweryDetailLoadInProgress(),
      BreweryDetailLoadFailure(
        'Something unexpected happened. Please try again.',
      ),
    ],
  );

  blocTest<BreweryDetailBloc, BreweryDetailState>(
    're-dispatching after a failure retries the load (retry)',
    setUp: () =>
        when(() => repository.getBreweryById(id)).thenAnswer((_) async => brewery),
    build: build,
    seed: () => const BreweryDetailLoadFailure('previous error'),
    act: (bloc) => bloc.add(const BreweryDetailStarted(id)),
    expect: () => const [
      BreweryDetailLoadInProgress(),
      BreweryDetailLoadSuccess(brewery),
    ],
  );
}
