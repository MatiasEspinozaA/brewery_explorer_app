import 'package:brewery_explorer_app/features/breweries/domain/entities/brewery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Brewery.addressLines', () {
    test('uses address_1 and does not duplicate the legacy street', () {
      final brewery = _brewery(
        address1: '1716 Topeka St',
        street: '1716 Topeka St',
        city: 'Norman',
        stateProvince: 'Oklahoma',
        postalCode: '73069',
        country: 'United States',
      );

      expect(brewery.addressLines, [
        '1716 Topeka St',
        'Norman, Oklahoma 73069',
        'United States',
      ]);
    });

    test('falls back to street when address_1 is missing', () {
      final brewery = _brewery(
        address1: null,
        street: '55 Legacy Rd',
        city: 'Portland',
      );

      expect(brewery.addressLines.first, '55 Legacy Rd');
    });

    test('prefers address_1 over a differing street', () {
      final brewery = _brewery(
        address1: 'New 10 Main St',
        street: 'Old 99 Side St',
      );

      expect(brewery.addressLines, contains('New 10 Main St'));
      expect(brewery.addressLines, isNot(contains('Old 99 Side St')));
    });

    test('includes address_2 and address_3 lines when present', () {
      final brewery = _brewery(
        address1: 'Line A',
        address2: 'Line B',
        address3: 'Line C',
        city: 'Gilbert',
      );

      expect(brewery.addressLines.take(3), ['Line A', 'Line B', 'Line C']);
    });

    test('returns an empty list when there is no location data', () {
      expect(_brewery().addressLines, isEmpty);
    });

    test('ignores blank/whitespace-only fields', () {
      final brewery = _brewery(address1: '   ', street: '  ', city: 'Berlin');
      expect(brewery.addressLines, ['Berlin']);
    });
  });

  group('Brewery.hasCoordinates', () {
    test('is true only when both latitude and longitude are present', () {
      expect(_brewery(latitude: 1, longitude: 2).hasCoordinates, isTrue);
      expect(_brewery(latitude: 1).hasCoordinates, isFalse);
      expect(_brewery(longitude: 2).hasCoordinates, isFalse);
      expect(_brewery().hasCoordinates, isFalse);
    });
  });
}

Brewery _brewery({
  String? address1,
  String? address2,
  String? address3,
  String? street,
  String? city,
  String? stateProvince,
  String? postalCode,
  String? country,
  double? latitude,
  double? longitude,
}) {
  return Brewery(
    id: 'id',
    name: 'Test Brewery',
    breweryType: 'micro',
    address1: address1,
    address2: address2,
    address3: address3,
    street: street,
    city: city,
    stateProvince: stateProvince,
    postalCode: postalCode,
    country: country,
    latitude: latitude,
    longitude: longitude,
  );
}
