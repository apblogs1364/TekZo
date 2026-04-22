import 'package:flutter/material.dart';
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
import 'package:tekzo/screens/AdminEditProduct.dart';
import 'package:tekzo/screens/AdminOrderManageScreen.dart';
import 'package:tekzo/screens/AdminOrderDetailScreen.dart';
import 'package:tekzo/screens/AdminReviewManageScreen.dart';
import 'package:tekzo/screens/AdminEditReviewScreen.dart';
import 'package:tekzo/screens/AdminConfigScreen.dart';
import 'package:tekzo/screens/AdminCustomerCareScreen.dart';

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
      home: const SplashScreen(),
      navigatorObservers: [
        NavigationRouteObserver(),
        AdminNavigationRouteObserver(),
      ],
      routes: {
        '/splash': (context) => const SplashScreen(),
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
        '/admin/users': (context) => const AdminUserManageScreen(),
        '/admin/products': (context) => const AdminProductManageScreen(),
        '/admin/categories': (context) => const AdminCategoryManageScreen(),
        '/admin/categories/add': (context) => const AdminAddCategory(),
        '/admin/products/edit': (context) => const AdminEditProduct(
          productName: '',
          sku: '',
        ),
        '/admin/orders': (context) => const AdminOrderManageScreen(),
        '/admin/reviews': (context) => const AdminReviewManageScreen(),
        '/admin/config': (context) => const AdminConfigScreen(),
        '/admin/customer-care': (context) => const AdminCustomerCareScreen(),
        '/admin/reviews/edit': (context) => const AdminEditReviewScreen(
          customerName: '',
          customerEmail: '',
          productName: '',
          sku: '',
          rating: 5,
          reviewText: '',
          status: 'Published',
          avatarColor: Color(0xFF5B8EA6),
          avatarInitials: '',
        ),
        '/admin/orders/detail': (context) => const AdminOrderDetailScreen(
          orderId: '',
          orderDate: '',
          customerName: '',
          status: 'Pending',
          totalAmount: '',
          avatarColor: Color(0xFF5B8EA6),
          avatarInitials: '',
        ),
      },
    );
  }
}
