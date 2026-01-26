import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? imageUrl;
  // 견적 정보 추가
  final String? estimateId;
  final String? estimateDamage;
  final String? estimatePrice;
  final String? estimateRealPrice;
  final String? estimateImageUrl;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.imageUrl,
    this.estimateId,
    this.estimateDamage,
    this.estimatePrice,
    this.estimateRealPrice,
    this.estimateImageUrl,
  });

  factory Review.fromMap(Map<String, dynamic> map, String docId) {
    return Review(
      id: docId,
      userName: map['userName'] ?? '익명',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      estimateId: map['estimateId'],
      estimateDamage: map['estimateDamage'],
      estimatePrice: map['estimatePrice'],
      estimateRealPrice: map['estimateRealPrice'],
      estimateImageUrl: map['estimateImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'estimateId': estimateId,
      'estimateDamage': estimateDamage,
      'estimatePrice': estimatePrice,
      'estimateRealPrice': estimateRealPrice,
      'estimateImageUrl': estimateImageUrl,
    };
  }
}
