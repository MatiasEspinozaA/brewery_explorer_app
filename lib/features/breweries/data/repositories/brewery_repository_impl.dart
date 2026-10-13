import 'package:injectable/injectable.dart';

import '../../domain/entities/brewery.dart';
import '../../domain/repositories/brewery_repository.dart';
import '../datasources/brewery_remote_data_source.dart';

/// Default [BreweryRepository]: delegates to the remote data source and maps
/// DTOs into domain entities.
///
/// Error translation happens in the data source, so this layer just propagates
/// the already-typed [AppException]s. A local cache (offline bonus) would slot
/// in here without touching the domain or presentation layers.
@LazySingleton(as: BreweryRepository)
class BreweryRepositoryImpl implements BreweryRepository {
  const BreweryRepositoryImpl(this._remoteDataSource);

  final BreweryRemoteDataSource _remoteDataSource;

  @override
  Future<List<Brewery>> getBreweries({
    required int page,
    int perPage = 20,
  }) async {
    final dtos = await _remoteDataSource.getBreweries(
      page: page,
      perPage: perPage,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Brewery> getBreweryById(String id) async {
    final dto = await _remoteDataSource.getBreweryById(id);
    return dto.toEntity();
  }

  @override
  Future<List<Brewery>> searchBreweries({
    required String query,
    int perPage = 20,
  }) async {
    final dtos = await _remoteDataSource.searchBreweries(
      query: query,
      perPage: perPage,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }
}
