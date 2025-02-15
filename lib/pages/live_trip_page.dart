import 'package:askngo/components/live/live_trip_tabs.dart';
import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';
import '../components/top_bar.dart';

class LiveTripPage extends StatelessWidget {
  const LiveTripPage({super.key});

  static const routeName = '/live_trip';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(
          hasBackButton: true,
          title: 'Live Trip',
        ),
        bottomNavigationBar: BottomNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: LiveTripTabs(),
        ),
      ),
    );
  }
}
