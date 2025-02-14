import 'package:flutter/material.dart';
import 'checkbox_option.dart';

class ExpandableSection extends StatelessWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.options,
    required this.onOptionChanged,
    required this.columnCount,
  });

  final String title;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;
  final Map<String, bool> options;
  final Function(String, bool) onOptionChanged;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    final optionsList = options.keys.toList();
    final int itemsPerColumn = (optionsList.length / columnCount).ceil();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(columnCount, (columnIndex) {
                final startIndex = columnIndex * itemsPerColumn;
                final endIndex = (columnIndex + 1) * itemsPerColumn;
                final columnOptions = optionsList
                    .sublist(startIndex,
                    endIndex > optionsList.length ? optionsList.length : endIndex);

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnOptions.map((option) {
                      return CheckboxOption(
                        option: option,
                        isChecked: options[option] ?? false,
                        onChange: (value) {
                          if (value != null) {
                            onOptionChanged(option, value);
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}