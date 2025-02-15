import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';
import '../components/top_bar.dart';

class TripDetailsPage extends StatelessWidget{
  const TripDetailsPage({super.key});
  static const routeName = '/trip_details';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(hasBackButton: true, title: 'Trip details',),
        bottomNavigationBar: BottomNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}