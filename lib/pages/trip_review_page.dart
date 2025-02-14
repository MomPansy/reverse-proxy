import 'package:flutter/material.dart';

import '../Components/bottom_nav_bar.dart';
import '../Components/top_bar.dart';

class TripReviewPage extends StatelessWidget{
  const TripReviewPage({super.key});
  static const routeName = '/trip_review';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(hasBackButton: true, title: 'Trip review',),
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