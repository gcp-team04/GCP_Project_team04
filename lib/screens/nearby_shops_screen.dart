import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/data_migration_service.dart';

// [모델 클래스: ServiceCenter]
class ServiceCenter {
  final String id;
  final String name;
  final String address;
  final String tel;
  final double latitude;
  final double longitude;
  final double distanceFromUser;
  final double rating;
  final bool isOpen;

  ServiceCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.tel,
    required this.latitude,
    required this.longitude,
    required this.distanceFromUser,
    this.rating = 4.5,
    this.isOpen = true,
  });

  factory ServiceCenter.fromMap(
    String id,
    Map<String, dynamic> data,
    double distanceInKm,
  ) {
    final positionMap = data['position'] as Map<String, dynamic>? ?? {};
    final geoPoint = positionMap['geopoint'] as GeoPoint?;

    return ServiceCenter(
      id: id,
      name: data['name'] ?? '이름 없음',
      address: data['address'] ?? '주소 정보 없음',
      tel: data['tel'] ?? '',
      latitude: geoPoint?.latitude ?? 0.0,
      longitude: geoPoint?.longitude ?? 0.0,
      distanceFromUser: distanceInKm,
      rating: 4.5,
      isOpen: true,
    );
  }

  factory ServiceCenter.fromGeoDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
    double distanceInKm,
  ) {
    return ServiceCenter.fromMap(document.id, document.data()!, distanceInKm);
  }
}

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  static const double _searchRadiusInKm = 50.0; // 원복

  Stream<List<ServiceCenter>>? _shopsStream;

  // [추가] 로딩 상태를 알려줄 메시지 변수
  String _statusMessage = '데이터 확인 및 위치 권한 요청 중...';

  @override
  void initState() {
    super.initState();
    _initializeLocationAndQuery();
  }

  Future<void> _initializeLocationAndQuery() async {
    try {
      // 0. 데이터 마이그레이션 (필요시)
      await DataMigrationService().migrateServiceCenters();

      // 1. 위치 확보 시도
      final position = await _determinePosition();
      debugPrint('📍 현재 내 위치: ${position.latitude}, ${position.longitude}');

      // ---------------------------------------------------------
      // [진단 로직]
      try {
        final debugSnap = await FirebaseFirestore.instance
            .collection('service_centers')
            .limit(1)
            .get();

        if (debugSnap.docs.isNotEmpty) {
          final doc = debugSnap.docs.first;
          debugPrint('🔍 [Debug] DB 연결 성공. 첫 번째 문서 ID: ${doc.id}');

          // ... (진단 로직 간소화/생략 또는 유지) ...
        }
      } catch (e) {
        debugPrint('🔍 [Debug] 진단 중 오류 발생: $e');
      }
      // ---------------------------------------------------------

      // 3. 쿼리 및 스트림 설정 (임시: 단순 5개 조회)
      // GeoQuery 로직 대신 일반 쿼리를 사용하여 5개만 가져옵니다.

      debugPrint('🔍 [Debug] 임시 모드: 정비소 5개 단순 조회 시작 (GeoHash 쿼리 중단)');

      final stream = FirebaseFirestore.instance
          .collection('service_centers')
          .limit(5)
          .snapshots()
          .map((snapshot) {
            debugPrint('🔍 [Debug] 단순 쿼리 조회된 문서 수: ${snapshot.docs.length}');
            final List<ServiceCenter> shops = [];

            for (final doc in snapshot.docs) {
              try {
                final data = doc.data();

                // 위치 정보 파싱 (Robust Parsing)
                GeoPoint? geoPoint;
                if (data.containsKey('position') && data['position'] is Map) {
                  final posMap = data['position'] as Map;
                  if (posMap.containsKey('geopoint')) {
                    final rawGeo = posMap['geopoint'];
                    if (rawGeo is GeoPoint) {
                      geoPoint = rawGeo;
                    } else if (rawGeo is Map) {
                      final lat = (rawGeo['latitude'] ?? rawGeo['lat']) as num?;
                      final lng =
                          (rawGeo['longitude'] ?? rawGeo['lng']) as num?;
                      if (lat != null && lng != null) {
                        geoPoint = GeoPoint(lat.toDouble(), lng.toDouble());
                      }
                    }
                  }
                }

                // 거리 계산
                double distInKm = 0.0;
                if (geoPoint != null) {
                  final distInMeters = Geolocator.distanceBetween(
                    position.latitude,
                    position.longitude,
                    geoPoint.latitude,
                    geoPoint.longitude,
                  );
                  distInKm = distInMeters / 1000;
                  debugPrint(
                    '    -> ${doc.id} 거리: ${distInKm.toStringAsFixed(1)}km',
                  );
                } else {
                  debugPrint('⚠️ 문서 ${doc.id}에 유효한 위치 정보가 없습니다.');
                }

                // ServiceCenter 객체 생성
                shops.add(ServiceCenter.fromMap(doc.id, data, distInKm));
              } catch (e) {
                debugPrint('❌ 파싱 에러 (${doc.id}): $e');
              }
            }

            // [요청 사항] 정렬 하지 않음
            // shops.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));

            return shops;
          });

      if (mounted) {
        setState(() {
          _shopsStream = stream;
          _statusMessage = '임시 데이터(5개)를 표시합니다.\n(거리 정렬 없음)';
        });
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '위치 정보를 가져오는데 실패했습니다.\n$e';
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 꺼져 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '내 근처 정비소 (임시 5개)',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          // _shopsStream이 준비되지 않았으면 로딩 화면 표시
          child: _shopsStream == null
              ? _buildLoadingView()
              : StreamBuilder<List<ServiceCenter>>(
                  stream: _shopsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('오류 발생: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingView();
                    }

                    final shops = snapshot.data ?? [];

                    if (shops.isEmpty) {
                      return const Center(child: Text('표시할 정비소가 없습니다.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: shops.length,
                      itemBuilder: (context, index) {
                        return _buildShopItem(context, shops[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, ServiceCenter shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.mapPin, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shop.address,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (shop.tel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    shop.tel,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      shop.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${shop.distanceFromUser.toStringAsFixed(1)}km',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: shop.isOpen
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              shop.isOpen ? '영업중' : '영업종료',
              style: TextStyle(
                color: shop.isOpen ? Colors.green : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
