// ignore: unused_import — referenced by doc comments to document error contract.
import '../../../../core/error/exceptions.dart';
import '../entities/brewery.dart';

/// Contract the presentation layer depends on.
///
/// Blocs consume this interface directly (we deliberately skip use cases — no
/// business logic yet to justify them). The implementation lives in the data
/// layer and is bound via `injectable`.
abstract interface class BreweryRepository {
  /// Returns one page of breweries.
  ///
  /// Throws an [AppException] subtype on failure; never returns `null`.
  Future<List<Brewery>> getBreweries({required int page, int perPage = 20});

  /// Returns a single brewery by its [id].
  ///
  /// Throws a `NotFoundException` when the id does not exist, or another
  /// [AppException] subtype on other failures.
  Future<Brewery> getBreweryById(String id);
}
