import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';

/// Provides third-party, non-annotatable instances to the DI container.
///
/// Registering [Dio] here (instead of `new Dio()` scattered around data
/// sources) keeps base URL and timeouts in a single place and makes the client
/// easy to swap or mock in tests.
@module
abstract class DioModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );
}
