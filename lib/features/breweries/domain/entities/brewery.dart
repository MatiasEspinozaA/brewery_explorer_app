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
    this.address1,
    this.address2,
    this.address3,
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

  /// Street-address lines as returned by the API (`address_1/2/3`).
  final String? address1;
  final String? address2;
  final String? address3;

  /// Legacy single-line street; usually mirrors [address1]. Kept as a fallback.
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

  /// The address as a list of display lines, skipping any missing fields.
  ///
  /// Line 1 is the street ([address1], falling back to the legacy [street]),
  /// followed by [address2]/[address3] when present, then a
  /// "City, State PostalCode" line and finally the [country]. Returns an empty
  /// list when the brewery has no usable location data at all, so the UI can
  /// decide how to render "no address".
  List<String> get addressLines {
    return [
      _firstNonBlank([address1, street]),
      _firstNonBlank([address2]),
      _firstNonBlank([address3]),
      _cityLine,
      _firstNonBlank([country]),
    ].whereType<String>().where((line) => line.isNotEmpty).toList();
  }

  /// "City, State PostalCode", with each part omitted when missing.
  String get _cityLine {
    final cityState = [
      _firstNonBlank([city]),
      _firstNonBlank([stateProvince]),
    ].whereType<String>().join(', ');
    final postal = _firstNonBlank([postalCode]) ?? '';
    return [cityState, postal].where((part) => part.isNotEmpty).join(' ');
  }

  static String? _firstNonBlank(List<String?> candidates) {
    for (final candidate in candidates) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    breweryType,
    address1,
    address2,
    address3,
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
