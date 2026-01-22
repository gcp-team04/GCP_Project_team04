import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gcp_project_team_04/screens/nearby_shops_screen.dart';

void main() {
  group('ServiceCenter Model Tests', () {
    test(
      'ServiceCenter.fromMap correctly parses nested position data (Migration Format)',
      () {
        // 1. DataMigrationService가 변환하는 형태의 데이터 시뮬레이션
        final Map<String, dynamic> migratedData = {
          'name': '테스트 정비소',
          'address': '서울시 강남구',
          'tel': '02-1234-5678',
          'position': {
            'geohash': 'wydm1234',
            'geopoint': const GeoPoint(37.5665, 126.9780), // 서울 시청 좌표 예시
          },
        };

        // 2. 모델 파싱 실행
        final center = ServiceCenter.fromMap('doc_id_123', migratedData, 2.5);

        // 3. 검증
        expect(center.id, 'doc_id_123');
        expect(center.name, '테스트 정비소');
        expect(center.latitude, 37.5665);
        expect(center.longitude, 126.9780);
        expect(center.distanceFromUser, 2.5);
        expect(center.isOpen, true); // 기본값 확인
      },
    );

    test('ServiceCenter.fromMap handles missing position data gracefully', () {
      // 위치 정보가 없는 경우 (예외 상황)
      final Map<String, dynamic> incompleteData = {
        'name': '위치 없는 정비소',
        'address': '주소 미상',
      };

      final center = ServiceCenter.fromMap('doc_id_456', incompleteData, 0.0);

      expect(center.name, '위치 없는 정비소');
      expect(center.latitude, 0.0);
      expect(center.longitude, 0.0);
    });
  });
}
