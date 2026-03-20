import 'package:flutter/material.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class NavigationRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateIndexFromRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // When a route is popped, update index based on the route that's now on top
    if (previousRoute != null) {
      _updateIndexFromRoute(previousRoute);
    } else {
      // If no previous route, we're back at the home screen
      NavigationIndexService.setIndex(NavigationIndexService.HOME);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateIndexFromRoute(newRoute);
  }

  void _updateIndexFromRoute(Route<dynamic>? route) {
    if (route == null) return;

    final name = route.settings.name;

    switch (name) {
      case '/home':
        NavigationIndexService.setIndex(NavigationIndexService.HOME);
        break;
      case '/products':
        NavigationIndexService.setIndex(NavigationIndexService.PRODUCTS);
        break;
      case '/wishlist':
        NavigationIndexService.setIndex(NavigationIndexService.WISHLIST);
        break;
      case '/orders':
        NavigationIndexService.setIndex(NavigationIndexService.ORDERS);
        break;
      case '/profile':
        NavigationIndexService.setIndex(NavigationIndexService.PROFILE);
        break;
      default:
        // For routes without a name, default to HOME
        NavigationIndexService.setIndex(NavigationIndexService.HOME);
    }
  }
}
