// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  final String id;
  final LatLng latLng;
  final String name;
  final LocationCategory category;
  final String? description;
  final int starRating;

  const Location({
    required this.id,
    required this.latLng,
    required this.name,
    required this.category,
    this.description,
    this.starRating = 0,
  }) : assert(starRating >= 0 && starRating <= 5);

  double get latitude => latLng.latitude;

  double get longitude => latLng.longitude;

  Location copyWith({
    String? id,
    LatLng? latLng,
    String? name,
    LocationCategory? category,
    String? description,
    int? starRating,
  }) {
    return Location(
      id: id ?? this.id,
      latLng: latLng ?? this.latLng,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      starRating: starRating ?? this.starRating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Location &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              latLng == other.latLng &&
              name == other.name &&
              category == other.category &&
              description == other.description &&
              starRating == other.starRating;

  @override
  int get hashCode =>
      id.hashCode ^
      latLng.hashCode ^
      name.hashCode ^
      category.hashCode ^
      description.hashCode ^
      starRating.hashCode;
}

enum LocationCategory {
  favorite,
  visited,
  wantToGo,
}
