// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'colours.dart';

class TextStyles {
  static const TextStyle FONT_20_BOLD = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle FONT_20_WHITE = TextStyle(
    fontSize: 20,
    color: Colors.white,
  );
  static const TextStyle FONT_20_BOLD_BLACK = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
}

TextStyle FONT_20_SUBHEADING() {
  return TextStyle(
    fontSize: 20,
    color: HexColor(AppHexColors.FONT_SUBHEADING),
  );
}

TextStyle FONT_20_SUBHEADING_BOLD() {
  return TextStyle(
    color: HexColor(AppHexColors.FONT_SUBHEADING),
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
