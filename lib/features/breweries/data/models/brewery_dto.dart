import '../../domain/entities/brewery.dart';

/// Data Transfer Object mirroring an Open Brewery DB JSON object.
///
/// Lives in the data layer and is the only place that knows the API's field
/// names and quirks. [toEntity] maps it to the framework-agnostic [Brewery].
class BreweryDto {
  const BreweryDto({
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
  final String breweryType;
  final String? street;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  factory BreweryDto.fromJson(Map<String, dynamic> json) {
    return BreweryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      breweryType: json['brewery_type'] as String,
      street: json['street'] as String?,
      city: json['city'] as String?,
      stateProvince: json['state_province'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      websiteUrl: json['website_url'] as String?,
      // The API has shipped coordinates both as numbers and as strings over
      // time; accept either (or null) rather than assuming one shape.
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
    );
  }

  Brewery toEntity() => Brewery(
    id: id,
    name: name,
    breweryType: breweryType,
    street: street,
    city: city,
    stateProvince: stateProvince,
    postalCode: postalCode,
    country: country,
    phone: phone,
    websiteUrl: websiteUrl,
    latitude: latitude,
    longitude: longitude,
  );

  static double? _parseCoordinate(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
