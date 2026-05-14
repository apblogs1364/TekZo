import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tekzo/screens/SplashScreen.dart';
import 'package:tekzo/screens/HomeScreen.dart';
import 'package:tekzo/screens/LoginScreen.dart';
import 'package:tekzo/screens/RegisterScreen.dart';
import 'package:tekzo/screens/ProductScreen.dart';
import 'package:tekzo/screens/ProductDetailScreen.dart';
import 'package:tekzo/screens/CartScreen.dart';
import 'package:tekzo/screens/ProfileScreen.dart';
import 'package:tekzo/screens/WishlistScreen.dart';
import 'package:tekzo/screens/OrderScreen.dart';
import 'package:tekzo/screens/AdminDashboardScreen.dart';
import 'package:tekzo/screens/AdminUserManageScreen.dart';
import 'package:tekzo/observers/navigation_route_observer.dart';
import 'package:tekzo/observers/admin_navigation_route_observer.dart';

import 'package:tekzo/screens/AdminProductManageScreen.dart';
import 'package:tekzo/screens/AdminCategoryManageScreen.dart';
import 'package:tekzo/screens/AdminAddCategory.dart';
import 'package:tekzo/screens/AdminOrderManageScreen.dart';
import 'package:tekzo/screens/AdminOrderDetailScreen.dart';
import 'package:tekzo/screens/AdminReviewManageScreen.dart';
import 'package:tekzo/screens/AdminReviewDetailsScreen.dart';
import 'package:tekzo/screens/AdminConfigScreen.dart';
import 'package:tekzo/screens/AdminCustomerCareScreen.dart';
import 'package:tekzo/screens/AdminProfileScreen.dart';
import 'package:tekzo/screens/AdminEditProfileScreen.dart';
import 'package:tekzo/screens/MaintenanceScreen.dart';
import 'package:tekzo/services/app_config_service.dart';
import 'package:tekzo/services/admin_navigation_index_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyAppWrapper());
}

class MyApp extends StatelessWidget {
  final AppConfigData config;

  const MyApp({super.key, required this.config});

  Route<dynamic>? _buildRoute(RouteSettings settings) {
    final isAdminRoute = settings.name?.startsWith('/admin') ?? false;

    if (config.maintenanceMode && !isAdminRoute) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MaintenanceScreen(),
      );
    }

    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case '/login':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case '/register':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case '/products':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProductScreen(),
        );
      case '/product-detail':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProductDetailScreen(),
        );
      case '/cart':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartScreen(),
        );
      case '/profile':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case '/wishlist':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WishlistScreen(),
        );
      case '/orders':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderScreen(),
        );
      case '/admin':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminDashboardScreen(),
        );
      case '/admin/profile':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminProfileScreen(),
        );
      case '/admin/profile/edit':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminEditProfileScreen(),
        );
      case '/admin/users':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminUserManageScreen(),
        );
      case '/admin/products':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminProductManageScreen(),
        );
      case '/admin/categories':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminCategoryManageScreen(),
        );
      case '/admin/categories/add':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminAddCategory(),
        );
      case '/admin/orders':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminOrderManageScreen(),
        );
      case '/admin/reviews':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminReviewManageScreen(),
        );
      case '/admin/config':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminConfigScreen(),
        );
      case '/admin/customer-care':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminCustomerCareScreen(),
        );
      case '/admin/reviews/edit':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminReviewDetailsScreen(reviewId: ''),
        );
      case '/admin/orders/detail':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminOrderDetailScreen(orderDocId: ''),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: config.appName,
      home: const SplashScreen(),
      navigatorObservers: [
        NavigationRouteObserver(),
        AdminNavigationRouteObserver(),
      ],
      onGenerateRoute: _buildRoute,
    );
  }
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<AppConfigData>(
            stream: AppConfigService.configStream(),
            builder: (context, configSnapshot) {
              return MyApp(
                config:
                    configSnapshot.data ??
                    const AppConfigData(
                      appName: AppConfigService.defaultAppName,
                      maintenanceMode: false,
                      logoPath: '',
                    ),
              );
            },
          );
        }
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
