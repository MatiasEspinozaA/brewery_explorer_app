import 'package:brewery_explorer_app/features/breweries/domain/entities/brewery.dart';
import 'package:brewery_explorer_app/features/breweries/presentation/widgets/brewery_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    Brewery brewery, {
    VoidCallback? onTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BreweryCard(brewery: brewery, onTap: onTap)),
      ),
    );
  }

  testWidgets('shows name, capitalized type badge and "City, Country"', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Brewery(
        id: 'id',
        name: '(405) Brewing Co',
        breweryType: 'micro',
        city: 'Norman',
        country: 'United States',
      ),
    );

    expect(find.text('(405) Brewing Co'), findsOneWidget);
    expect(find.text('Micro'), findsOneWidget);
    expect(find.text('Norman, United States'), findsOneWidget);
  });

  testWidgets('falls back to "Location unavailable" without city/country', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Brewery(id: 'id', name: 'Nameless', breweryType: 'micro'),
    );

    expect(find.text('Location unavailable'), findsOneWidget);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = 0;
    await pumpCard(
      tester,
      const Brewery(id: 'id', name: 'Tappable', breweryType: 'micro'),
      onTap: () => tapped++,
    );

    await tester.tap(find.byType(BreweryCard));
    await tester.pump();

    expect(tapped, 1);
  });
}
