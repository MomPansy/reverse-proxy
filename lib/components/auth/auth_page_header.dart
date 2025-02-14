import 'package:flutter/material.dart';

class AuthPageHeader extends StatelessWidget {

  const AuthPageHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // SizedBox(height: 128, child: Image.asset(Paths.LOGO_SQR_GREEN)),
        const SizedBox(
          height: 4,
        ),
        Text(
          'Welcome',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: 224,
          child: Text(
            'Sign in',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(
          height:4,
        ),
      ],
    );
  }
}
