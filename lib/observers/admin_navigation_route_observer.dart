import 'package:flutter/material.dart';
import 'package:tekzo/services/admin_navigation_index_service.dart';

class AdminNavigationRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateIndexFromRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateIndexFromRoute(previousRoute);
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
      case '/admin':
        AdminNavigationIndexService.setIndex(AdminNavigationIndexService.DASHBOARD);
        break;
      case '/admin/products':
        AdminNavigationIndexService.setIndex(AdminNavigationIndexService.ITEMS);
        break;
      case '/admin/orders':
      case '/orders':
        // Optional: Assuming orders is shared or will use this.
        // It's safe to update admin index, since it won't affect the user index.
        AdminNavigationIndexService.setIndex(AdminNavigationIndexService.ORDERS);
        break;
      case '/admin/users':
        AdminNavigationIndexService.setIndex(AdminNavigationIndexService.USERS);
        break;
      case '/admin/config':
        AdminNavigationIndexService.setIndex(AdminNavigationIndexService.CONFIG);
        break;
    }
  }
}
