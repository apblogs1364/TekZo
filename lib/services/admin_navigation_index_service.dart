import 'package:flutter/material.dart';

class AdminNavigationIndexService extends ChangeNotifier {
  static final AdminNavigationIndexService _instance =
      AdminNavigationIndexService._internal();

  int _currentIndex = 0;

  AdminNavigationIndexService._internal();

  factory AdminNavigationIndexService() {
    return _instance;
  }

  static AdminNavigationIndexService get instance => _instance;

  static int get currentIndex => _instance._currentIndex;

  static void setIndex(int index) {
    if (_instance._currentIndex != index) {
      _instance._currentIndex = index;
      _instance.notifyListeners();
    }
  }

  // Index mapping for admin screens
  static const int DASHBOARD = 0;
  static const int ITEMS = 1;
  static const int ORDERS = 2;
  static const int USERS = 3;
  static const int CONFIG = 4;
}
