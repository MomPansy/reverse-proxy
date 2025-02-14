import 'package:flutter/material.dart';

class CheckboxOption extends StatelessWidget {
  const CheckboxOption({
    super.key,
    required this.option,
    required this.isChecked,
    required this.onChange,
  });

  final String option;
  final bool isChecked;
  final Function(bool?) onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onChange,
        ),
        Expanded(
          child: Text(option),
        ),
      ],
    );
  }
}