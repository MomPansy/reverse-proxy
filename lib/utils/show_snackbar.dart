import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
      .showSnackBar(snackBarWithText(text));
}

SnackBar snackBarWithText(String message) {
  return SnackBar(
    content: Text(message),
  );
}