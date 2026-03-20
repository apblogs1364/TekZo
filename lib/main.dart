import 'package:flutter/material.dart';
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
import 'package:tekzo/screens/UserManageScreen.dart';
import 'package:tekzo/observers/navigation_route_observer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tekzo',
      home: const HomeScreen(),
      navigatorObservers: [NavigationRouteObserver()],
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/products': (context) => const ProductScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/orders': (context) => const OrderScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/users': (context) => const UserManageScreen(),
      },
    );
  }
}
