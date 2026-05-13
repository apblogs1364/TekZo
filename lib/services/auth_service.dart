import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Store logged-in user data locally
  Map<String, dynamic>? _loggedInUserData;
  Map<String, dynamic>? get loggedInUserData => _loggedInUserData;
  bool get isLoggedIn => _loggedInUserData != null;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No user found with this email');
    }

    final userDoc = querySnapshot.docs.first;
    final userData = userDoc.data();

    if (userData['password'] != password) {
      throw Exception('Incorrect password');
    }

    _loggedInUserData = userData;
    return userData;
  }

  Future<void> signOut() async {
    _loggedInUserData = null;
  }

  Future<String> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
    required String phone,
    File? profileImageFile,
    String role = 'customer',
  }) async {
    // Check if email already exists
    final existing = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Email already in use');
    }

    final docRef = _db.collection('users').doc();
    final data = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'profileImageUrl': '',
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await docRef.set(data);
    return docRef.id;
  }
}
