/// Static configuration for the Open Brewery DB REST API.
///
/// Paths are relative to [baseUrl] and are consumed by the data layer.
/// See: https://www.openbrewerydb.org/documentation
class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://api.openbrewerydb.org/v1';

  /// Paginated list of breweries, e.g. `/breweries?per_page=20&page=1`.
  static const String breweries = '/breweries';

  /// Full-text search, e.g. `/breweries/search?query=dog`.
  static const String breweriesSearch = '/breweries/search';

  /// Single brewery by id, e.g. `/breweries/{id}`.
  static String breweryById(String id) => '/breweries/$id';
}
