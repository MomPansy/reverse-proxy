import 'package:askngo/components/live/location_info.dart';
import 'package:askngo/components/live/location_map.dart';
import 'package:flutter/material.dart';

import '../../types/location.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  Location _focusedLocation = StubData.locations[0];

  void _changeLocation(Location newLocation) {
    setState(() {
      _focusedLocation = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LocationMap(onTapLocation: _changeLocation),
        LocationDetails(location: _focusedLocation),
      ],
    );
  }
}
