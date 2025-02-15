import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../types/location.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({super.key, required this.onTapLocation});
  final Function onTapLocation;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  Completer<GoogleMapController> mapController = Completer();
  final LatLng center = LatLng(45.521563, -122.677433);
  final MapType _currentMapType = MapType.normal;
  final Map<Marker, Location> _markedLocations = <Marker, Location>{};
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 11.0,
        ),
        mapType: _currentMapType,
        markers: _markers,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
      ),
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    if (!context.mounted) return;
    mapController.complete(controller);
    var markers = <Marker>{};
    for (var location in StubData.locations) {
      markers.add(await _createLocationMarker(location));
    }
    setState(() {
      _markers.addAll(markers);
    });

    _zoomToFitSelectedCategory();
  }

  void _zoomToFitSelectedCategory() {
    _zoomToFitLocations(StubData.locations);
  }

  Future<Marker> _createLocationMarker(Location location) async {
    final marker = Marker(
      markerId: MarkerId(location.latLng.toString()),
      position: location.latLng,
      infoWindow: InfoWindow(
        title: location.name,
        snippet: 'Tap here to play audio',
        onTap: () {
          print('Tap here to play audio');
        },
      ),
      icon: await _getLocationMarkerIcon(),
      onTap: () => widget.onTapLocation(location)
    );
    _markedLocations[marker] = location;
    return marker;
  }

  Future<void> _zoomToFitLocations(List<Location> locations) async {
    var controller = await mapController.future;

    var minLat = center.latitude;
    var maxLat = center.latitude;
    var minLong = center.longitude;
    var maxLong = center.longitude;

    for (var location in locations) {
      minLat = min(minLat, location.latitude);
      maxLat = max(maxLat, location.latitude);
      minLong = min(minLong, location.longitude);
      maxLong = max(maxLong, location.longitude);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong),
          ),
          48.0,
        ),
      );
    });
  }

  Future<BitmapDescriptor> _getLocationMarkerIcon() =>
      BitmapDescriptor.asset(
          createLocalImageConfiguration(context, size: const Size.square(32)),
          'assets/images/heart.png');
}

class StubData {
  static const List<Location> locations = [
    Location(
      id: '1',
      latLng: LatLng(45.524676, -122.681922),
      name: 'Deschutes Brewery',
      description:
          'Beers brewed on-site & gourmet pub grub in a converted auto-body shop with a fireLocation & wood beams.',
      category: LocationCategory.favorite,
      starRating: 5,
    ),
    Location(
      id: '2',
      latLng: LatLng(45.516887, -122.675417),
      name: 'Luc Lac Vietnamese Kitchen',
      description:
          'Popular counter-serve offering pho, banh mi & other Vietnamese favorites in a stylish setting.',
      category: LocationCategory.favorite,
      starRating: 5,
    ),
    Location(
      id: '3',
      latLng: LatLng(45.528952, -122.698344),
      name: 'Salt & Straw',
      description:
          'Quirky flavors & handmade waffle cones draw crowds to this artisinal ice cream maker\'s 3 parlors.',
      category: LocationCategory.favorite,
      starRating: 5,
    ),
    Location(
      id: '4',
      latLng: LatLng(45.525253, -122.684423),
      name: 'TILT',
      description:
          'This stylish American eatery offers unfussy breakfast fare, cocktails & burgers in industrial-themed digs.',
      category: LocationCategory.favorite,
      starRating: 4,
    ),
    Location(
      id: '5',
      latLng: LatLng(45.513485, -122.657982),
      name: 'White Owl Social Club',
      description:
          'Chill haunt with local beers, burgers & vegan eats, plus live music & an airy patio with a fire pit.',
      category: LocationCategory.favorite,
      starRating: 4,
    ),
    Location(
      id: '6',
      latLng: LatLng(45.487137, -122.799940),
      name: 'Buffalo Wild Wings',
      description:
          'Lively sports-bar chain dishing up wings & other American pub grub amid lots of large-screen TVs.',
      category: LocationCategory.visited,
      starRating: 5,
    ),
    Location(
      id: '7',
      latLng: LatLng(45.416986, -122.743171),
      name: 'Chevys',
      description:
          'Lively, informal Mexican chain with a colorful, family-friendly setting plus tequilas & margaritas.',
      category: LocationCategory.visited,
      starRating: 4,
    ),
    Location(
      id: '8',
      latLng: LatLng(45.430489, -122.831802),
      name: 'Cinetopia',
      description:
          'Moviegoers can take food from the on-site eatery to their seats, with table service in 21+ theaters.',
      category: LocationCategory.visited,
      starRating: 4,
    ),
    Location(
      id: '9',
      latLng: LatLng(45.383030, -122.758372),
      name: 'Thai Cuisine',
      description:
          'Informal restaurant offering Thai standards in a modest setting, plus takeout & delivery.',
      category: LocationCategory.visited,
      starRating: 4,
    ),
    Location(
      id: '10',
      latLng: LatLng(45.493321, -122.669330),
      name: 'The Old Spaghetti Factory',
      description:
          'Family-friendly chain eatery featuring traditional Italian entrees amid turn-of-the-century decor.',
      category: LocationCategory.visited,
      starRating: 4,
    ),
    Location(
      id: '11',
      latLng: LatLng(45.548606, -122.675286),
      name: 'Mississippi Pizza',
      description:
          'Music, trivia & other all-ages events featured at pizzeria with lounge & vegan & gluten-free pies.',
      category: LocationCategory.wantToGo,
      starRating: 4,
    ),
    Location(
      id: '12',
      latLng: LatLng(45.420226, -122.740347),
      name: 'Oswego Grill',
      description:
          'Wood-grilled steakhouse favorites served in a casual, romantic restaurant with a popular happy hour.',
      category: LocationCategory.wantToGo,
      starRating: 4,
    ),
    Location(
      id: '13',
      latLng: LatLng(45.541202, -122.676432),
      name: 'The Widmer Brothers Brewery',
      description:
          'Popular, enduring gastropub serving craft beers, sandwiches & eclectic entrees in a laid-back space.',
      category: LocationCategory.wantToGo,
      starRating: 4,
    ),
    Location(
      id: '14',
      latLng: LatLng(45.559783, -122.924103),
      name: 'TopGolf',
      description:
          'Sprawling entertainment venue with a high-tech driving range & swanky lounge with drinks & games.',
      category: LocationCategory.wantToGo,
      starRating: 5,
    ),
    Location(
      id: '15',
      latLng: LatLng(45.485612, -122.784733),
      name: 'Uwajimaya Beaverton',
      description:
          'Huge Asian grocery outpost stocking meats, produce & prepared foods plus gifts & home goods.',
      category: LocationCategory.wantToGo,
      starRating: 5,
    ),
  ];

  static const reviewStrings = [
    'My favorite Location in Portland. The employees are wonderful and so is the food. I go here at least once a month!',
    'Staff was very friendly. Great atmosphere and good music. Would recommend.',
    'Best. Location. In. Town. Period.'
  ];
}
