import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';

/// Wishlist screen displaying saved products and quick actions.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<WishlistItem> wishlistItems = [
    WishlistItem(
      name: 'Sony WH-850000',
      price: '₹349.00',
      imagePath: 'assets/images/sony_headphones.jpg',
      isFavorite: true,
    ),
    WishlistItem(
      name: 'iPhone 15 Pro',
      price: '₹999.00',
      imagePath: 'assets/images/iphone_15_pro.jpg',
      isFavorite: true,
    ),
    WishlistItem(
      name: 'Samsung S SmartWatch',
      price: '₹199.00',
      imagePath: 'assets/images/samsung_watch.jpg',
      isFavorite: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: isLoggedIn
            ? Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'My Wishlist',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Wishlist Items
                  Expanded(
                    child: wishlistItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: AppColors.grey400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your wishlist is empty',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: wishlistItems.length,
                            itemBuilder: (context, index) {
                              return _WishlistItemCard(
                                item: wishlistItems[index],
                                onRemove: () {
                                  setState(() {
                                    wishlistItems.removeAt(index);
                                  });
                                },
                                onAddToCart: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${wishlistItems[index].name} added to cart',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please login to view your wishlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
}

class _WishlistItemCard extends StatefulWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistItemCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  State<_WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<_WishlistItemCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.item.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.grey600,
                size: 40,
              ),
            ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    widget.item.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Favorite Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFavorite = !isFavorite;
                  if (!isFavorite) {
                    widget.onRemove();
                  }
                });
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
                color: isFavorite ? AppColors.danger : AppColors.grey400,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistItem {
  final String name;
  final String price;
  final String imagePath;
  bool isFavorite;

  WishlistItem({
    required this.name,
    required this.price,
    required this.imagePath,
    this.isFavorite = false,
  });
}
