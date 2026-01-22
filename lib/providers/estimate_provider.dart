import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Estimate {
  final String id;
  final String date;
  final String damage;
  final String price;
  final String status;

  Estimate({
    required this.id,
    required this.date,
    required this.damage,
    required this.price,
    required this.status,
  });
}

class EstimateProvider with ChangeNotifier {
  List<Estimate> _estimates = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  List<Estimate> get estimates => _estimates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _subscribeToEstimates(user.uid);
      } else {
        _subscription?.cancel();
        _estimates = [];
        notifyListeners();
      }
    });
  }

  void _subscribeToEstimates(String uid) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('estimates')
        .snapshots()
        .listen(
          (snapshot) {
            _estimates = snapshot.docs.map((doc) {
              final data = doc.data();
              return Estimate(
                id: doc.id,
                date: data['date'] ?? '알 수 없음',
                damage: data['damage'] ?? '알 수 없음',
                price: data['estimatedPrice'] ?? '알 수 없음',
                status: '저장됨',
              );
            }).toList();

            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
