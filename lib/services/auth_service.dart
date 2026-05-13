import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists ? snap.data()! : {'role': 'customer'};
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final data = {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'profileImageUrl': '',
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(data);
    return uid;
  }
}
