import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_center.dart';

class ShopProvider with ChangeNotifier {
  List<ServiceCenter> _shops = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<ServiceCenter> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 초기화 및 데이터 페칭 시작
  Future<void> initialize() async {
    await fetchNearbyShops();
  }

  Future<void> fetchNearbyShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. 권한 및 로케이션 서비스 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = '위치 서비스가 꺼져 있습니다.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = '위치 권한이 거부되었습니다.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 2. 현재 위치 확보 (최신 데이터 보장)
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final double myLat = position.latitude;
      final double myLng = position.longitude;

      // 3. Geo-Query 설정 및 구독
      final GeoCollectionReference<Map<String, dynamic>> geoCollectionRef =
          GeoCollectionReference<Map<String, dynamic>>(
            FirebaseFirestore.instance.collection('service_centers'),
          );

      final GeoFirePoint center = GeoFirePoint(GeoPoint(myLat, myLng));

      _subscription?.cancel();
      _subscription = geoCollectionRef
          .subscribeWithin(
            center: center,
            radiusInKm: 10.0,
            field: 'position',
            geopointFrom: (data) =>
                (data['position'] as Map<String, dynamic>)['geopoint']
                    as GeoPoint,
            strictMode: true,
          )
          .listen(
            (snapshots) {
              final List<ServiceCenter> fetchedShops = snapshots
                  .map((shot) {
                    final data = shot.data();
                    if (data == null) return null;

                    final positionMap =
                        data['position'] as Map<String, dynamic>?;
                    if (positionMap == null) return null;

                    final geoPoint = positionMap['geopoint'] as GeoPoint?;
                    if (geoPoint == null) return null;

                    final distInMeters = Geolocator.distanceBetween(
                      myLat,
                      myLng,
                      geoPoint.latitude,
                      geoPoint.longitude,
                    );
                    final dist = distInMeters / 1000;

                    return ServiceCenter.fromGeoDocument(shot, dist);
                  })
                  .whereType<ServiceCenter>()
                  .toList();

              // 거리순 정렬 후 최대 20개로 제한
              fetchedShops.sort(
                (a, b) => a.distanceFromUser.compareTo(b.distanceFromUser),
              );

              _shops = fetchedShops.take(40).toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (e) {
              _error = '데이터 로딩 중 오류 발생: $e';
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _error = '위치 확인 중 오류 발생: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
