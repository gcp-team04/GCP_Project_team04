import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Verify Geohash for coordinates', () {
    // User's Shop Coordinates
    const double lat = 37.644190;
    const double lng = 126.782318;

    // Create GeoFirePoint
    final GeoFirePoint center = GeoFirePoint(const GeoPoint(lat, lng));

    // Print logic
    print('Latitude: $lat, Longitude: $lng');
    print('Generated Geohash: ${center.geohash}');
    print('User Provided Geohash: wydnjhbj6');

    // Check match
    // Note: User provided 9 digits. center.geohash usually generates 9 chars by default.
    expect(
      center.geohash.startsWith('wydnjh'),
      true,
      reason: "Geohash prefix should match for the same location",
    );
  });
}
