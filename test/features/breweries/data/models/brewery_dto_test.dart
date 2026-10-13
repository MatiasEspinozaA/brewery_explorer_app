import 'package:brewery_explorer_app/features/breweries/data/models/brewery_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BreweryDto.fromJson', () {
    test('parses a full payload including all address lines', () {
      final json = <String, dynamic>{
        'id': 'abc-123',
        'name': '(405) Brewing Co',
        'brewery_type': 'micro',
        'address_1': '1716 Topeka St',
        'address_2': 'Suite 100',
        'address_3': 'Building B',
        'street': '1716 Topeka St',
        'city': 'Norman',
        'state_province': 'Oklahoma',
        'postal_code': '73069-8224',
        'country': 'United States',
        'phone': '4058160490',
        'website_url': 'http://www.405brewing.com',
        'latitude': 35.25738891,
        'longitude': -97.46818222,
      };

      final dto = BreweryDto.fromJson(json);

      expect(dto.id, 'abc-123');
      expect(dto.name, '(405) Brewing Co');
      expect(dto.breweryType, 'micro');
      expect(dto.address1, '1716 Topeka St');
      expect(dto.address2, 'Suite 100');
      expect(dto.address3, 'Building B');
      expect(dto.street, '1716 Topeka St');
      expect(dto.city, 'Norman');
      expect(dto.stateProvince, 'Oklahoma');
      expect(dto.postalCode, '73069-8224');
      expect(dto.country, 'United States');
      expect(dto.phone, '4058160490');
      expect(dto.websiteUrl, 'http://www.405brewing.com');
      expect(dto.latitude, 35.25738891);
      expect(dto.longitude, -97.46818222);
    });

    test('keeps optional fields null when absent', () {
      final dto = BreweryDto.fromJson(<String, dynamic>{
        'id': 'id',
        'name': 'Nameless',
        'brewery_type': 'planning',
      });

      expect(dto.address1, isNull);
      expect(dto.address2, isNull);
      expect(dto.address3, isNull);
      expect(dto.street, isNull);
      expect(dto.city, isNull);
      expect(dto.phone, isNull);
      expect(dto.websiteUrl, isNull);
      expect(dto.latitude, isNull);
      expect(dto.longitude, isNull);
    });

    test('parses coordinates from numbers, strings, and rejects garbage', () {
      final asNumbers = BreweryDto.fromJson(_coords(lat: 10.5, lng: -20.25));
      expect(asNumbers.latitude, 10.5);
      expect(asNumbers.longitude, -20.25);

      final asStrings = BreweryDto.fromJson(_coords(lat: '10.5', lng: '-20.25'));
      expect(asStrings.latitude, 10.5);
      expect(asStrings.longitude, -20.25);

      final garbage = BreweryDto.fromJson(_coords(lat: 'N/A', lng: null));
      expect(garbage.latitude, isNull);
      expect(garbage.longitude, isNull);
    });
  });

  group('BreweryDto.toEntity', () {
    test('maps every field onto the domain entity', () {
      final entity = BreweryDto.fromJson(<String, dynamic>{
        'id': 'id',
        'name': 'Brew',
        'brewery_type': 'micro',
        'address_1': 'A1',
        'address_2': 'A2',
        'address_3': 'A3',
        'street': 'S',
        'city': 'City',
        'state_province': 'State',
        'postal_code': '0000',
        'country': 'Country',
        'phone': '123',
        'website_url': 'https://x.test',
        'latitude': 1.0,
        'longitude': 2.0,
      }).toEntity();

      expect(entity.id, 'id');
      expect(entity.name, 'Brew');
      expect(entity.breweryType, 'micro');
      expect(entity.address1, 'A1');
      expect(entity.address2, 'A2');
      expect(entity.address3, 'A3');
      expect(entity.street, 'S');
      expect(entity.city, 'City');
      expect(entity.stateProvince, 'State');
      expect(entity.postalCode, '0000');
      expect(entity.country, 'Country');
      expect(entity.phone, '123');
      expect(entity.websiteUrl, 'https://x.test');
      expect(entity.latitude, 1.0);
      expect(entity.longitude, 2.0);
    });
  });
}

Map<String, dynamic> _coords({dynamic lat, dynamic lng}) => <String, dynamic>{
  'id': 'id',
  'name': 'Brew',
  'brewery_type': 'micro',
  'latitude': lat,
  'longitude': lng,
};
