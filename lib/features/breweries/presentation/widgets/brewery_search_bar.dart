import 'package:flutter/material.dart';

/// Material 3 search field for the brewery list.
///
/// Presentation-only: it reports text changes and a clear action through
/// callbacks, staying decoupled from the bloc so it is easy to reuse and test.
/// The clear button appears only while there is text (driven by [controller]).
class BrewerySearchBar extends StatelessWidget {
  const BrewerySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search breweries',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return SearchBar(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
            leading: const Icon(Icons.search),
            trailing: [
              if (value.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                  onPressed: onClear,
                ),
            ],
          );
        },
      ),
    );
  }
}
