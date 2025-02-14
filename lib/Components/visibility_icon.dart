// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class VisibilityIcon extends StatelessWidget {
  final bool isVisible;

  const VisibilityIcon({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isVisible
          ? Icons.visibility
          : Icons.visibility_off,
      color: Theme.of(context).primaryColorDark,
    );
  }
}
