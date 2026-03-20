import 'package:flutter/material.dart';

class NavigationIndexService extends ChangeNotifier {
  static final NavigationIndexService _instance =
      NavigationIndexService._internal();

  int _currentIndex = 0;

  NavigationIndexService._internal();

  factory NavigationIndexService() {
    return _instance;
  }

  static NavigationIndexService get instance => _instance;

  static int get currentIndex => _instance._currentIndex;

  static void setIndex(int index) {
    if (_instance._currentIndex != index) {
      _instance._currentIndex = index;
      _instance.notifyListeners();
    }
  }

  // Index mapping for screens
  static const int HOME = 0;
  static const int PRODUCTS = 1;
  static const int WISHLIST = 2;
  static const int ORDERS = 3;
  static const int PROFILE = 4;
}
