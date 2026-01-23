import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

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
  final int reviewCount;
  final List<Review> latestReviews;

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
    this.reviewCount = 12,
    List<Review>? latestReviews,
  }) : this.latestReviews = latestReviews ?? _generateMockReviews();

  static List<Review> _generateMockReviews() {
    return [
      Review(
        id: '1',
        userName: '김철수',
        rating: 5.0,
        comment: '사장님이 정말 친절하시고 수리도 완벽합니다!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: '2',
        userName: '이영희',
        rating: 4.5,
        comment: '가격이 합리적이고 작업 속도가 빨라요.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: '3',
        userName: '박민수',
        rating: 4.0,
        comment: '깔끔한 정비소입니다. 다음에도 방문할게요.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  factory ServiceCenter.fromGeoDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
    double distanceInKm,
  ) {
    final data = document.data()!;
    final positionMap = data['position'] as Map<String, dynamic>? ?? {};
    final geoPoint = positionMap['geopoint'] as GeoPoint?;

    return ServiceCenter(
      id: document.id,
      name: data['name'] ?? '이름 없음',
      address: data['address'] ?? '주소 정보 없음',
      tel: data['tel'] ?? '',
      latitude: geoPoint?.latitude ?? 0.0,
      longitude: geoPoint?.longitude ?? 0.0,
      distanceFromUser: distanceInKm,
      rating: 4.5,
      isOpen: true,
      reviewCount: 10 + (document.id.hashCode % 50), // Mock review count
    );
  }
}
