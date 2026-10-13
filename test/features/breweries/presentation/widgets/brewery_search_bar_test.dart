import 'package:brewery_explorer_app/features/breweries/presentation/widgets/brewery_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrewerySearchBar(
            controller: controller,
            onChanged: onChanged ?? (_) {},
            onClear: onClear ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('reports text changes through onChanged', (tester) async {
    final changes = <String>[];
    await pump(tester, onChanged: changes.add);

    await tester.enterText(find.byType(TextField), 'dog');

    expect(changes, contains('dog'));
  });

  testWidgets('shows the clear button only when there is text', (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'dog');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('invokes onClear when the clear button is tapped', (tester) async {
    var cleared = 0;
    await pump(tester, onClear: () => cleared++);

    await tester.enterText(find.byType(TextField), 'dog');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(cleared, 1);
  });
}
