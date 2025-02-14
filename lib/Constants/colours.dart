// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class AppHexColors {
  static const String SCAFFOLD_BACKGROUND = "#F2F2F2";
  static const String BIZBULK_GREEN = "#06AA90";
  static const String FONT_HEADING = "#2A2A2A";
  static const String FONT_SUBHEADING = "#6A6A6A";
  static const String FONT_FADED = "#CACACA";
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

MaterialColor CreateMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final double r = color.r, g = color.g, b = color.b;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      (r + ((ds < 0 ? r : (255 - r)) * ds).round()) as int,
      (g + ((ds < 0 ? g : (255 - g)) * ds).round()) as int,
      (b + ((ds < 0 ? b : (255 - b)) * ds).round()) as int,
      1,
    );
  }

  int floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  int value(a, r, g, b) {
    return floatToInt8(a) << 24 |
    floatToInt8(r) << 16 |
    floatToInt8(g) << 8 |
    floatToInt8(b) << 0;
  }

  int colourValue = value(color.a, color.r, color.g, color.b);

  return MaterialColor(colourValue, swatch);
}