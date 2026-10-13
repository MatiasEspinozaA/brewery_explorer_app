import 'package:brewery_explorer_app/shared/presentation/widgets/molecules/info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('renders the label and every value line', (tester) async {
    await pump(
      tester,
      InfoTile(
        icon: Icons.location_on_outlined,
        label: 'Address',
        lines: const ['Line A', 'Line B', 'Country'],
      ),
    );

    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Line A'), findsOneWidget);
    expect(find.text('Line B'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
  });

  testWidgets('shows the action icon and triggers onTap when interactive', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      InfoTile.single(
        icon: Icons.language_outlined,
        label: 'Website',
        value: 'https://example.test',
        actionIcon: Icons.open_in_new,
        onTap: () => taps++,
      ),
    );

    expect(find.byIcon(Icons.open_in_new), findsOneWidget);

    await tester.tap(find.byType(InfoTile));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('is not wrapped in an InkWell when no action is given', (
    tester,
  ) async {
    await pump(
      tester,
      InfoTile.single(
        icon: Icons.location_on_outlined,
        label: 'Address',
        value: 'Address unavailable',
      ),
    );

    expect(
      find.descendant(
        of: find.byType(InfoTile),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });
}
