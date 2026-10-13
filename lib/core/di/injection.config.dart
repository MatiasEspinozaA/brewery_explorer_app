// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:brewery_explorer_app/core/network/dio_module.dart' as _i162;
import 'package:brewery_explorer_app/features/breweries/data/datasources/brewery_remote_data_source.dart'
    as _i3;
import 'package:brewery_explorer_app/features/breweries/data/repositories/brewery_repository_impl.dart'
    as _i431;
import 'package:brewery_explorer_app/features/breweries/domain/repositories/brewery_repository.dart'
    as _i369;
import 'package:brewery_explorer_app/features/breweries/presentation/bloc/brewery_detail_bloc.dart'
    as _i428;
import 'package:brewery_explorer_app/features/breweries/presentation/bloc/brewery_list_bloc.dart'
    as _i715;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.lazySingleton<_i3.BreweryRemoteDataSource>(
      () => _i3.BreweryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i369.BreweryRepository>(
      () => _i431.BreweryRepositoryImpl(gh<_i3.BreweryRemoteDataSource>()),
    );
    gh.factory<_i428.BreweryDetailBloc>(
      () => _i428.BreweryDetailBloc(gh<_i369.BreweryRepository>()),
    );
    gh.factoryParam<_i715.BreweryListBloc, Duration?, dynamic>(
      (searchDebounce, _) => _i715.BreweryListBloc(
        gh<_i369.BreweryRepository>(),
        searchDebounce: searchDebounce,
      ),
    );
    return this;
  }
}

class _$DioModule extends _i162.DioModule {}
