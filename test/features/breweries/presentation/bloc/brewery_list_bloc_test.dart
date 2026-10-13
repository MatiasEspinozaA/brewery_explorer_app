import 'package:bloc_test/bloc_test.dart';
import 'package:brewery_explorer_app/core/error/exceptions.dart';
import 'package:brewery_explorer_app/features/breweries/domain/entities/brewery.dart';
import 'package:brewery_explorer_app/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:brewery_explorer_app/features/breweries/presentation/bloc/brewery_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  late _MockBreweryRepository repository;

  setUp(() => repository = _MockBreweryRepository());

  BreweryListBloc build() => BreweryListBloc(repository);

  final page1 = _breweries(20);
  final page2Short = _breweries(5, from: 20);

  group('BreweryListStarted', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'emits [loading, success] with more pages expected on a full page',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => page1),
      build: build,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'marks the end when the first page is shorter than the page size',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => page2Short),
      build: build,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(breweries: page2Short, hasReachedEnd: true),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'treats an empty result as a (finished) empty success',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => const <Brewery>[]),
      build: build,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        const BreweryListLoadSuccess(breweries: [], hasReachedEnd: true),
      ],
      verify: (bloc) {
        expect((bloc.state as BreweryListLoadSuccess).isEmpty, isTrue);
      },
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'maps a NetworkException to the connection failure message',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenThrow(const NetworkException()),
      build: build,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        const BreweryListLoadFailure(
          'No internet connection. Check your network and try again.',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'maps an unexpected (non-AppException) error to the generic message',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenThrow(Exception('boom')),
      build: build,
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        const BreweryListLoadFailure(
          'Something unexpected happened. Please try again.',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      're-running the load after a failure reloads the first page (retry)',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => page1),
      build: build,
      seed: () => const BreweryListLoadFailure('previous error'),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      ],
    );
  });

  group('BreweryListNextPageRequested', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'appends the next page and detects the end',
      setUp: () => when(
        () => repository.getBreweries(page: 2, perPage: 20),
      ).thenAnswer((_) async => page2Short),
      build: build,
      seed: () => BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => [
        BreweryListLoadSuccess(
          breweries: page1,
          hasReachedEnd: false,
          paginationStatus: PaginationStatus.loadingMore,
        ),
        BreweryListLoadSuccess(
          breweries: [...page1, ...page2Short],
          hasReachedEnd: true,
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'keeps items and flags a retriable failure when a page fails',
      setUp: () => when(
        () => repository.getBreweries(page: 2, perPage: 20),
      ).thenThrow(const ServerException()),
      build: build,
      seed: () => BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => [
        BreweryListLoadSuccess(
          breweries: page1,
          hasReachedEnd: false,
          paginationStatus: PaginationStatus.loadingMore,
        ),
        BreweryListLoadSuccess(
          breweries: page1,
          hasReachedEnd: false,
          paginationStatus: PaginationStatus.failure,
          paginationError: 'Something went wrong on our end. Please try again.',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'does nothing once the end has been reached',
      build: build,
      seed: () => BreweryListLoadSuccess(breweries: page1, hasReachedEnd: true),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => const <BreweryListState>[],
      verify: (_) => verifyNever(
        () => repository.getBreweries(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ),
    );
  });

  group('concurrency', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'droppable ignores duplicate next-page requests while one is in flight',
      setUp: () => when(
        () => repository.getBreweries(page: 2, perPage: 20),
      ).thenAnswer((_) async {
        // Keep the first request in flight so the extra ones can pile up.
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return page2Short;
      }),
      build: build,
      seed: () => BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      act: (bloc) => bloc
        ..add(const BreweryListNextPageRequested())
        ..add(const BreweryListNextPageRequested())
        ..add(const BreweryListNextPageRequested()),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        BreweryListLoadSuccess(
          breweries: page1,
          hasReachedEnd: false,
          paginationStatus: PaginationStatus.loadingMore,
        ),
        BreweryListLoadSuccess(
          breweries: [...page1, ...page2Short],
          hasReachedEnd: true,
        ),
      ],
      // The two extra requests were dropped: only one network call happened.
      verify: (_) =>
          verify(() => repository.getBreweries(page: 2, perPage: 20)).called(1),
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'a pending pagination does not overwrite a fresh restart of the list',
      setUp: () {
        // Pagination (page 2) is slow; the restart (page 1) resolves first.
        when(() => repository.getBreweries(page: 2, perPage: 20)).thenAnswer((
          _,
        ) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return page2Short;
        });
        when(
          () => repository.getBreweries(page: 1, perPage: 20),
        ).thenAnswer((_) async => _breweries(10, from: 100));
      },
      build: build,
      seed: () => BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      act: (bloc) => bloc
        ..add(const BreweryListNextPageRequested())
        ..add(const BreweryListStarted()),
      wait: const Duration(milliseconds: 150),
      // loadingMore (pagination) -> restart loads page 1 fresh; the late page-2
      // result is discarded because the list is no longer paginating.
      expect: () => [
        BreweryListLoadSuccess(
          breweries: page1,
          hasReachedEnd: false,
          paginationStatus: PaginationStatus.loadingMore,
        ),
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(
          breweries: _breweries(10, from: 100),
          hasReachedEnd: true,
        ),
      ],
    );
  });

  group('search', () {
    // Short debounce keeps these tests fast and deterministic.
    BreweryListBloc buildFast() =>
        BreweryListBloc(repository, searchDebounce: debounce);

    final results = _breweries(3, from: 500);

    blocTest<BreweryListBloc, BreweryListState>(
      'emits results as a single, non-paginated page',
      setUp: () => when(
        () => repository.searchBreweries(query: 'dog', perPage: 20),
      ).thenAnswer((_) async => results),
      build: buildFast,
      act: (bloc) => bloc.add(const BreweryListSearchChanged('dog')),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(
          breweries: results,
          hasReachedEnd: true,
          query: 'dog',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'reports an empty search as a (search) no-results success',
      setUp: () => when(
        () => repository.searchBreweries(query: 'zzz', perPage: 20),
      ).thenAnswer((_) async => const <Brewery>[]),
      build: buildFast,
      act: (bloc) => bloc.add(const BreweryListSearchChanged('zzz')),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        const BreweryListLoadInProgress(),
        const BreweryListLoadSuccess(
          breweries: [],
          hasReachedEnd: true,
          query: 'zzz',
        ),
      ],
      verify: (bloc) {
        final state = bloc.state as BreweryListLoadSuccess;
        expect(state.isEmpty, isTrue);
        expect(state.isSearch, isTrue);
      },
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'maps a search error to a failure that remembers the query',
      setUp: () => when(
        () => repository.searchBreweries(query: 'dog', perPage: 20),
      ).thenThrow(const NetworkException()),
      build: buildFast,
      act: (bloc) => bloc.add(const BreweryListSearchChanged('dog')),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        const BreweryListLoadInProgress(),
        const BreweryListLoadFailure(
          'No internet connection. Check your network and try again.',
          query: 'dog',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'debounces rapid keystrokes: only the last query hits the network once',
      setUp: () => when(
        () => repository.searchBreweries(query: 'abc', perPage: 20),
      ).thenAnswer((_) async => results),
      build: buildFast,
      act: (bloc) async {
        bloc.add(const BreweryListSearchChanged('a'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(const BreweryListSearchChanged('ab'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(const BreweryListSearchChanged('abc'));
      },
      wait: const Duration(milliseconds: 80),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(
          breweries: results,
          hasReachedEnd: true,
          query: 'abc',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.searchBreweries(query: 'abc', perPage: 20),
        ).called(1);
        verifyNever(
          () => repository.searchBreweries(query: 'a', perPage: 20),
        );
        verifyNever(
          () => repository.searchBreweries(query: 'ab', perPage: 20),
        );
      },
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'restartable: a newer query wins and the slow stale result is discarded',
      setUp: () {
        when(
          () => repository.searchBreweries(query: 'slow', perPage: 20),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 150));
          return _breweries(2, from: 900);
        });
        when(
          () => repository.searchBreweries(query: 'fast', perPage: 20),
        ).thenAnswer((_) async => results);
      },
      build: buildFast,
      act: (bloc) async {
        bloc.add(const BreweryListSearchChanged('slow'));
        // Let 'slow' pass the debounce and start before 'fast' supersedes it.
        await Future<void>.delayed(const Duration(milliseconds: 40));
        bloc.add(const BreweryListSearchChanged('fast'));
      },
      wait: const Duration(milliseconds: 250),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(
          breweries: results,
          hasReachedEnd: true,
          query: 'fast',
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'clearing the search restores the normal first page',
      setUp: () => when(
        () => repository.getBreweries(page: 1, perPage: 20),
      ).thenAnswer((_) async => page1),
      build: buildFast,
      seed: () => BreweryListLoadSuccess(
        breweries: results,
        hasReachedEnd: true,
        query: 'dog',
      ),
      act: (bloc) => bloc.add(const BreweryListSearchChanged('')),
      wait: const Duration(milliseconds: 80),
      expect: () => [
        const BreweryListLoadInProgress(),
        BreweryListLoadSuccess(breweries: page1, hasReachedEnd: false),
      ],
      verify: (_) =>
          verify(() => repository.getBreweries(page: 1, perPage: 20)).called(1),
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'does not paginate while showing search results',
      build: buildFast,
      seed: () => BreweryListLoadSuccess(
        breweries: results,
        hasReachedEnd: true,
        query: 'dog',
      ),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => const <BreweryListState>[],
      verify: (_) => verifyNever(
        () => repository.getBreweries(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ),
    );
  });
}

const debounce = Duration(milliseconds: 20);

List<Brewery> _breweries(int count, {int from = 0}) {
  return List.generate(
    count,
    (i) => Brewery(
      id: 'id-${from + i}',
      name: 'Brewery ${from + i}',
      breweryType: 'micro',
    ),
    growable: false,
  );
}
