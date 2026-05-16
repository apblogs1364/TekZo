import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    _loggedInUserData = {...userData, 'id': userDoc.id};
    return _loggedInUserData!;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('Invalid email');
      }
      if (e.code == 'user-not-found') {
        throw Exception('User not found');
      }
      throw Exception(e.message ?? 'Failed to send password reset email');
    } catch (_) {
      throw Exception('Failed to send password reset email');
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> signOut() async {
    _loggedInUserData = null;
  }

  Future<Map<String, dynamic>> updateLoggedInUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String dob,
    required String location,
    File? profileImageFile,
  }) async {
    final currentUser = _loggedInUserData;
    if (currentUser == null) {
      throw Exception('No logged-in user found');
    }

    final email = currentUser['email']?.toString();
    if (email == null || email.isEmpty) {
      throw Exception('Logged-in user email is missing');
    }

    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('User record not found');
    }

    final documentRef = querySnapshot.docs.first.reference;
    String profileImageUrl = currentUser['profileImageUrl']?.toString() ?? '';

    if (profileImageFile != null) {
      profileImageUrl = await _saveProfileImageLocally(
        profileImageFile,
        documentRef.id,
      );
    }

    final updatedFields = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dob': dob,
      'location': location,
      'profileImageUrl': profileImageUrl,
    };

    await documentRef.update(updatedFields);

    _loggedInUserData = {...currentUser, ...updatedFields};
    return _loggedInUserData!;
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
    final existing = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Email already in use');
    }

    final docRef = _db.collection('users').doc();
    String profileImageUrl = '';

    if (profileImageFile != null) {
      profileImageUrl = await _saveProfileImageLocally(
        profileImageFile,
        docRef.id,
      );
    }

    final data = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
    return docRef.id;
  }

  Future<String> _saveProfileImageLocally(File file, String userId) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDocDir.path}/profile_images');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final filePath = '${profileDir.path}/$userId.jpg';
    final savedFile = await file.copy(filePath);
    return savedFile.path;
  }
}
