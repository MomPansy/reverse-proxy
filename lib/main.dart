import 'package:askngo/pages/auth_page.dart';
import 'package:askngo/pages/create_trip_page.dart';
import 'package:askngo/pages/explore_page.dart';
import 'package:askngo/pages/home_page.dart';
import 'package:askngo/pages/landing_page.dart';
import 'package:askngo/pages/live_trip_page.dart';
import 'package:askngo/pages/trip_details_page.dart';
import 'package:askngo/pages/trip_review_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final router = GoRouter(
      initialLocation: LandingPage.routeName,
      routes: [
        GoRoute(
          path: LandingPage.routeName,
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: HomePage.routeName,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AuthPage.routeName,
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: CreateTripPage.routeName,
          builder: (context, state) => const CreateTripPage(),
        ),
        GoRoute(
          path: ExplorePage.routeName,
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: LiveTripPage.routeName,
          builder: (context, state) => const LiveTripPage(),
        ),
        GoRoute(
          path: TripDetailsPage.routeName,
          builder: (context, state) => const TripDetailsPage(),
        ),
        GoRoute(
          path: TripReviewPage.routeName,
          builder: (context, state) => const TripReviewPage(),
        ),
      ],
    );
    return MaterialApp.router(
      title: 'Askngo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
