import 'package:askngo/pages/auth_page.dart';
import 'package:askngo/pages/create_trip_page.dart';
import 'package:askngo/pages/explore_page.dart';
import 'package:askngo/pages/home_page.dart';
import 'package:askngo/pages/live_trip_page.dart';
import 'package:askngo/pages/trip_details_page.dart';
import 'package:askngo/pages/trip_review_page.dart';
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
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: AuthPage.routeName),
              child: Text('Auth page'),
            ),
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: CreateTripPage.routeName),
              child: Text('Create Trip page'),
            ),
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: ExplorePage.routeName),
              child: Text('Explore page'),
            ),
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: LiveTripPage.routeName),
              child: Text('Live Trip page'),
            ),
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: TripDetailsPage.routeName),
              child: Text('Trip details page'),
            ),
            ElevatedButton(
              onPressed: () => _goToPage(context: context, routeName: TripReviewPage.routeName),
              child: Text('Trip review page'),
            ),
          ],
        ),
      ),
    );
  }
}