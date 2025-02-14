import 'package:askngo/components/bottom_nav_bar.dart';
import 'package:askngo/components/top_bar.dart';
import 'package:flutter/material.dart';

import '../components/trips/create_trip_form.dart';

class CreateTripPage extends StatelessWidget{
  const CreateTripPage({super.key});
  static const routeName = '/trips';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(hasBackButton: true, title: 'Create New Trip',),
        bottomNavigationBar: BottomNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CreateTripForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}