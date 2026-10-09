import 'package:equatable/equatable.dart';

/// Core domain model for a brewery.
///
/// Framework- and transport-agnostic: no JSON, no Dio. The data layer maps the
/// API DTO into this type (see `BreweryDto.toEntity`).
///
/// Only [id], [name] and [breweryType] are guaranteed by the API; every other
/// field is optional and may be `null`, so the UI must handle missing data.
class Brewery extends Equatable {
  const Brewery({
    required this.id,
    required this.name,
    required this.breweryType,
    this.street,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;

  /// e.g. `micro`, `brewpub`, `regional`. Kept as a [String] (not an enum) so
  /// new types added server-side don't break parsing.
  final String breweryType;

  final String? street;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;

  /// Geographic coordinates, when the API provides them.
  final double? latitude;
  final double? longitude;

  /// Whether both coordinates are available (useful for map/distance features).
  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    id,
    name,
    breweryType,
    street,
    city,
    stateProvince,
    postalCode,
    country,
    phone,
    websiteUrl,
    latitude,
    longitude,
  ];
}
