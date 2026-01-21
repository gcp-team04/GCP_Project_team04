import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ServiceCenterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> searchServiceCenters(
    String keyword,
  ) async {
    final String trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];

    // 1. 띄어쓰기로 키워드 분리
    final parts = trimmed.split(RegExp(r'\s+'));
    Map<String, String> fieldMap = {};

    for (var p in parts) {
      if (p.endsWith('도') || p.contains('특별자치도')) {
        fieldMap['addr_sido'] = p;
      } else if (p.endsWith('시') || p.endsWith('군')) {
        // '서울특별시', '부산광역시' 등은 시도 단위로 처리
        if (p.contains('특별') || p.contains('광역')) {
          fieldMap['addr_sido'] = p;
        } else {
          fieldMap['addr_sigungu'] = p;
        }
      } else if (p.endsWith('구')) {
        fieldMap['addr_gu'] = p;
      } else if (p.endsWith('읍') || p.endsWith('면')) {
        fieldMap['addr_eupmyeon'] = p;
      } else if (p.endsWith('동')) {
        fieldMap['addr_dong'] = p;
      }
    }

    final ref = _firestore.collection('service_centers');

    // 2. 검색 우선순위 (가장 구체적인 단위부터)
    const specificityOrder = [
      'addr_dong',
      'addr_eupmyeon',
      'addr_gu',
      'addr_sigungu',
      'addr_sido',
    ];

    String? primaryField;
    for (var f in specificityOrder) {
      if (fieldMap.containsKey(f)) {
        primaryField = f;
        break;
      }
    }

    // 3. 주소 키워드가 없는 경우 (예: "조은카") 전체 주소 텍스트 검색 시도
    if (primaryField == null) {
      return (await ref
              .where('address', isGreaterThanOrEqualTo: trimmed)
              .where('address', isLessThan: trimmed + '\uf8ff')
              .get())
          .docs;
    }

    try {
      // 4. 가장 구체적인 지역으로 1차 검색 (인덱스 이슈 방지)
      final QuerySnapshot result = await ref
          .where(primaryField, isEqualTo: fieldMap[primaryField])
          .get();

      // 5. 나머지 키워드가 있다면 메모리에서 추가 필터링
      final filteredDocs = result.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        bool matches = true;

        fieldMap.forEach((field, value) {
          if (field != primaryField) {
            // 데이터가 null이거나 입력한 값과 다르면 탈락
            if (data[field] == null ||
                !data[field].toString().contains(value)) {
              matches = false;
            }
          }
        });
        return matches;
      }).toList();

      return filteredDocs;
    } catch (e) {
      debugPrint('검색 중 오류 발생: $e');
      return [];
    }
  }
}
