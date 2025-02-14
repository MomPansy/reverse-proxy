import 'package:askngo/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget{
  const LandingPage({super.key});
  static const routeName = '/';

  void _goToPage({
    required BuildContext context,
    required String routeName,
  }) {
    context.push(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: HomePage.routeName),
              child: Text('Home page'),
            ),
          ],
        ),
      ),
    );
  }
}