import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class DataMigrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 기존 데이터 형식을 geoflutterfire_plus 형식으로 마이그레이션합니다.
  Future<void> migrateServiceCenters() async {
    try {
      debugPrint('🔄 데이터 마이그레이션 확인 중...');

      // 1. 모든 정비소 데이터 가져오기 (데이터가 아주 많지 않다고 가정)
      final QuerySnapshot snapshot = await _db
          .collection('service_centers')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ 마이그레이션할 데이터가 없습니다.');
        return;
      }

      int updateCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // 이미 새로운 형식이 적용되어 있는지 확인
        if (data.containsKey('position') &&
            data['position'] is Map &&
            (data['position'] as Map).containsKey('geohash')) {
          continue;
        }

        double? lat;
        double? lng;

        // 1. 이미 'position' 필드는 있지만 'geohash'가 없는 경우 (중요: 이 케이스가 누락되어 있었음)
        if (data.containsKey('position') && data['position'] is Map) {
          final posMap = data['position'] as Map;
          if (posMap.containsKey('geopoint') &&
              posMap['geopoint'] is GeoPoint) {
            final gp = posMap['geopoint'] as GeoPoint;
            lat = gp.latitude;
            lng = gp.longitude;
          }
        }

        // 2. 구 버전 데이터 확인 (geopoint 필드가 List 형태인 경우)
        if (lat == null || lng == null) {
          if (data.containsKey('geopoint') && data['geopoint'] is List) {
            final List geoList = data['geopoint'];
            if (geoList.length >= 2) {
              lat = (geoList[0] as num).toDouble();
              lng = (geoList[1] as num).toDouble();
            }
          }
          // 3. 혹은 lat, lng 필드로 따로 있는 경우
          else if (data.containsKey('lat') && data.containsKey('lng')) {
            lat = (data['lat'] as num?)?.toDouble();
            lng = (data['lng'] as num?)?.toDouble();
          }
        }

        // 유효한 좌표를 찾았다면 업데이트 진행
        if (lat != null && lng != null) {
          // GeoFirePoint 생성
          final GeoFirePoint geoPoint = GeoFirePoint(GeoPoint(lat, lng));

          // 업데이트할 데이터 준비
          // geoflutterfire_plus는 {'geohash': '...', 'geopoint': GeoPoint(...)} 구조를 사용
          await _db.collection('service_centers').doc(doc.id).update({
            'position': {
              'geohash': geoPoint.geohash,
              'geopoint': GeoPoint(lat, lng),
            }, // geoPoint.data 대신 명시적으로 구조 생성 (버전 호환성 확보)
          });

          updateCount++;
        }
      }

      if (updateCount > 0) {
        debugPrint('✅ 총 $updateCount 개의 정비소 데이터가 성공적으로 변환되었습니다.');
      } else {
        debugPrint('✨ 모든 데이터가 이미 최신 형식입니다.');
      }
    } catch (e) {
      debugPrint('❌ 데이터 마이그레이션 중 오류 발생: $e');
    }
  }
}
