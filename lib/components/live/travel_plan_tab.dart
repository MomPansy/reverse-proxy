import 'package:flutter/material.dart';

class TravelPlanTab extends StatelessWidget {
  const TravelPlanTab({super.key});

  static const routeName = '/live_trip';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Plan for today'),
      ],
    );
  }
}
