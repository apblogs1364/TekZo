import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';
import 'package:tekzo/widgets/app_name_text.dart';
import 'SettingsScreen.dart';

/// Main home screen with search, categories, featured banner, and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoggedIn = false;
  String _searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.white),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const AppNameText(
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: AppColors.white,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search gadgets, accessories...',
                    hintStyle: TextStyle(
                      color: AppColors.grey400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    filled: true,
                    fillColor: AppColors.grey100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Upgrade Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Upgrade Your Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get 50% off on premium peripherals',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _db.collection('categories').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return SizedBox(
                            height: 92,
                            child: Center(
                              child:
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final categories =
                            snapshot.data?.docs
                                .map(
                                  (doc) => _CategoryRecord.fromDoc(
                                    doc.id,
                                    doc.data(),
                                  ),
                                )
                                .where((category) => category.isActive)
                                .toList() ??
                            [];

                        categories.sort(
                          (a, b) => a.displayOrder.compareTo(b.displayOrder),
                        );

                        final filteredCategories = _searchQuery.isEmpty
                            ? categories
                            : categories
                                  .where(
                                    (category) =>
                                        category.matches(_searchQuery),
                                  )
                                  .toList();

                        if (filteredCategories.isEmpty) {
                          return const SizedBox(height: 104);
                        }

                        return SizedBox(
                          height: 104,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredCategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final category = filteredCategories[index];
                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/products',
                                  arguments: category.id,
                                ),
                                child: _HomeCategoryCard(category: category),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Trending Tech
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending Tech',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/products'),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Product Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.collection('products').snapshots(),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }

                    final categoriesSnapshot = _db.collection('categories');
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: categoriesSnapshot.snapshots(),
                      builder: (context, categorySnapshot) {
                        final categories =
                            categorySnapshot.data?.docs
                                .map(
                                  (doc) => _CategoryRecord.fromDoc(
                                    doc.id,
                                    doc.data(),
                                  ),
                                )
                                .toList() ??
                            [];
                        final categoryById = {
                          for (final category in categories)
                            category.id: category,
                        };

                        final featuredProducts =
                            productSnapshot.data?.docs
                                .map(
                                  (doc) => _ProductRecord.fromDoc(
                                    doc.id,
                                    doc.data(),
                                  ),
                                )
                                .where(
                                  (product) =>
                                      product.isActive && product.isFeatured,
                                )
                                .where(
                                  (product) =>
                                      _searchQuery.isEmpty ||
                                      product.matches(
                                        _searchQuery,
                                        categoryById[product.categoryId]?.name,
                                      ),
                                )
                                .toList() ??
                            [];

                        if (featuredProducts.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: featuredProducts.map((product) {
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/product-detail',
                                arguments: product.toJson(),
                              ),
                              child: _ProductCard(
                                imagePath: product.productImage,
                                productName: product.name,
                                price: _formatPrice(product.finalPrice),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          final route = NavigationIndexService.routeForIndex(index);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Status bar spacing
          const SizedBox(height: 35),
          // Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(color: AppColors.primaryDark),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryExtraLight,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoggedIn ? 'Welcome User' : 'Guest',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn ? 'user@tekzo.com' : 'Not logged in',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Products',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/products');
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Wishlist',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/wishlist');
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Cart',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const Divider(),
                _buildDrawerMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Login/Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_isLoggedIn) {
                    // Show logout confirmation
                    _showLogoutDialog();
                  } else {
                    // Navigate to login screen
                    Navigator.pushNamed(context, '/login').then((value) {
                      // Check if user successfully logged in
                      if (value == true) {
                        setState(() {
                          _isLoggedIn = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged in successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoggedIn
                      ? AppColors.danger
                      : AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoggedIn ? 'Logout' : 'Login',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Admin Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoggedIn = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeCategoryCard extends StatelessWidget {
  final _CategoryRecord category;

  const _HomeCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildCategoryImage(),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage() {
    final imagePath = category.image.trim();
    if (imagePath.isEmpty) {
      return const Icon(
        Icons.category_outlined,
        size: 32,
        color: AppColors.primaryDark,
      );
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(file, fit: BoxFit.cover, width: 60, height: 60),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.category_outlined,
            size: 32,
            color: AppColors.primaryDark,
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String price;

  const _ProductCard({
    required this.imagePath,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(child: _buildProductImage()),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final path = imagePath.trim();
    if (path.isEmpty) {
      return Icon(Icons.image, size: 40, color: AppColors.grey400);
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image, size: 40, color: AppColors.grey400);
      },
    );
  }
}

class _CategoryRecord {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool isActive;
  final bool showOnHome;
  final int displayOrder;

  const _CategoryRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isActive,
    required this.showOnHome,
    required this.displayOrder,
  });

  factory _CategoryRecord.fromDoc(String id, Map<String, dynamic> data) {
    return _CategoryRecord(
      id: id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      isActive: data['isActive'] as bool? ?? true,
      showOnHome: data['showOnHome'] as bool? ?? false,
      displayOrder: int.tryParse(data['displayOrder']?.toString() ?? '') ?? 0,
    );
  }

  bool matches(String query) {
    final text = [name, description, image, displayOrder.toString()].join(' ');
    return text.toLowerCase().contains(query);
  }
}

class _ProductRecord {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String productImage;
  final int price;
  final int finalPrice;
  final bool isFeatured;
  final bool isActive;
  final String categoryId;

  const _ProductRecord({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.productImage,
    required this.price,
    required this.finalPrice,
    required this.isFeatured,
    required this.isActive,
    required this.categoryId,
  });

  factory _ProductRecord.fromDoc(String id, Map<String, dynamic> data) {
    return _ProductRecord(
      id: id,
      name: data['name']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      productImage: data['productImage']?.toString() ?? '',
      price: int.tryParse(data['price']?.toString() ?? '') ?? 0,
      finalPrice:
          int.tryParse(data['finalPrice']?.toString() ?? '') ??
          (int.tryParse(data['price']?.toString() ?? '') ?? 0),
      isFeatured: data['isFeatured'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      categoryId: data['categoryId']?.toString() ?? '',
    );
  }

  bool matches(String query, String? categoryName) {
    final text = [name, brand, description, categoryName ?? ''].join(' ');
    return text.toLowerCase().contains(query);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'productImage': productImage,
      'price': price,
      'finalPrice': finalPrice,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'categoryId': categoryId,
    };
  }
}

String _formatPrice(int value) => '₹$value';
