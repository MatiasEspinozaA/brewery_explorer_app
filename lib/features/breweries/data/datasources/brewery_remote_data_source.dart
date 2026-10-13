import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/brewery_dto.dart';

/// Talks to the Open Brewery DB HTTP API and returns [BreweryDto]s.
///
/// Every method throws a typed [AppException] on failure — transport errors are
/// mapped via [mapDioException], parsing errors become [ParsingException].
abstract interface class BreweryRemoteDataSource {
  Future<List<BreweryDto>> getBreweries({
    required int page,
    required int perPage,
  });

  Future<BreweryDto> getBreweryById(String id);

  Future<List<BreweryDto>> searchBreweries({
    required String query,
    required int perPage,
  });
}

@LazySingleton(as: BreweryRemoteDataSource)
class BreweryRemoteDataSourceImpl implements BreweryRemoteDataSource {
  const BreweryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<BreweryDto>> getBreweries({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.breweries,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data ?? const [];
      return data
          .cast<Map<String, dynamic>>()
          .map(BreweryDto.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ParsingException('Failed to parse brewery list: $error');
    }
  }

  @override
  Future<BreweryDto> getBreweryById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.breweryById(id),
      );
      final data = response.data;
      if (data == null) {
        throw const NotFoundException();
      }
      return BreweryDto.fromJson(data);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ParsingException('Failed to parse brewery $id: $error');
    }
  }

  @override
  Future<List<BreweryDto>> searchBreweries({
    required String query,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.breweriesSearch,
        queryParameters: {'query': query, 'per_page': perPage},
      );
      final data = response.data ?? const [];
      return data
          .cast<Map<String, dynamic>>()
          .map(BreweryDto.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ParsingException('Failed to parse search results: $error');
    }
  }
}
