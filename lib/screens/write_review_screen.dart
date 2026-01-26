import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/service_center.dart';
import '../services/storage_service.dart';
import '../models/review.dart';
import '../providers/estimate_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final ServiceCenter shop;

  const WriteReviewScreen({super.key, required this.shop});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  XFile? _image;
  bool _isUploading = false;
  final StorageService _storageService = StorageService();
  Estimate? _selectedEstimate;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('리뷰 내용을 입력해주세요.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _storageService.uploadCrashedCarPicture(_image!);
      }

      final review = Review(
        id: '', // Firestore will generate
        userName: user.displayName ?? '익명',
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        estimateId: _selectedEstimate?.id,
        estimateDamage: _selectedEstimate?.damage,
        estimatePrice: _selectedEstimate?.price,
        estimateRealPrice: _selectedEstimate?.realPrice,
        estimateImageUrl: _selectedEstimate?.imageUrl,
      );

      final shopRef = FirebaseFirestore.instance
          .collection('service_centers')
          .doc(widget.shop.id);

      final reviewsRef = shopRef.collection('reviews');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final shopSnap = await transaction.get(shopRef);

        final newReviewRef = reviewsRef.doc();
        transaction.set(newReviewRef, {...review.toMap(), 'userId': user.uid});

        if (shopSnap.exists) {
          final data = shopSnap.data()!;
          final currentRating = (data['rating'] ?? 0.0).toDouble();
          final currentCount = (data['reviewCount'] ?? 0) as int;

          final newCount = currentCount + 1;
          final newRating =
              ((currentRating * currentCount) + _rating) / newCount;

          transaction.update(shopRef, {
            'rating': newRating,
            'reviewCount': newCount,
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('리뷰가 등록되었습니다.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('리뷰 등록 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showEstimatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<EstimateProvider>(
          builder: (context, provider, child) {
            final estimates = provider.estimates;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '결합할 견적 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (estimates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('저장된 견적이 없습니다.')),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: estimates.length,
                        itemBuilder: (context, index) {
                          final est = estimates[index];
                          final isSelected = _selectedEstimate?.id == est.id;

                          return ListTile(
                            onTap: () {
                              setState(() {
                                _selectedEstimate = isSelected ? null : est;
                              });
                              Navigator.pop(context);
                            },
                            leading: est.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      est.imageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      LucideIcons.image,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                            title: Text(est.damage),
                            subtitle: Text(
                              '예상: ${est.price}${est.realPrice != null ? ' / 실제: ${est.realPrice}' : ''}',
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blueAccent,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shop.name} 리뷰 작성'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정비 서비스는 어떠셨나요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    LucideIcons.star,
                    color: index < _rating ? Colors.amber : Colors.grey[300],
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // 견적 정보 선택 영역 추가
            const Text(
              '견적 정보 연결 (선택)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showEstimatePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedEstimate != null
                      ? Colors.blueAccent.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedEstimate != null
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedEstimate != null
                          ? LucideIcons.checkCircle
                          : LucideIcons.fileText,
                      color: _selectedEstimate != null
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedEstimate != null
                                ? _selectedEstimate!.damage
                                : '견적 내역에서 가져오기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedEstimate != null
                                  ? Colors.blueAccent
                                  : Colors.black87,
                            ),
                          ),
                          if (_selectedEstimate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '총 ${_selectedEstimate!.realPrice ?? _selectedEstimate!.price}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              '리뷰 내용',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '작업 내용, 친절도, 가격 등에 대한 후기를 남겨주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '사진 추가',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(LucideIcons.camera, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '리뷰 등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
