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

  // Return the route name corresponding to a navigation index
  static String routeForIndex(int index) {
    switch (index) {
      case HOME:
        return '/home';
      case PRODUCTS:
        return '/products';
      case WISHLIST:
        return '/wishlist';
      case ORDERS:
        return '/orders';
      case PROFILE:
        return '/profile';
      default:
        return '/home';
    }
  }

  // Return the navigation index corresponding to a route name.
  // Returns HOME when the route is unknown/null.
  static int indexForRoute(String? route) {
    switch (route) {
      case '/home':
        return HOME;
      case '/products':
        return PRODUCTS;
      case '/wishlist':
        return WISHLIST;
      case '/orders':
        return ORDERS;
      case '/profile':
        return PROFILE;
      default:
        return HOME;
    }
  }
}
