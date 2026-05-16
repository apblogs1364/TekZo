import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/screens/ProductDetailScreen.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';

/// Wishlist screen displaying saved products and quick actions.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _currentUserId =>
      AuthService.instance.loggedInUserData?['id']?.toString();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    final userId = _currentUserId;

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
                    child: userId == null
                        ? const SizedBox.shrink()
                        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _db
                                .collection('users')
                                .doc(userId)
                                .collection('wishlist')
                                .orderBy('addedAt', descending: true)
                                .snapshots(),
                            builder: (context, wishlistSnapshot) {
                              if (wishlistSnapshot.hasError) {
                                return const SizedBox.shrink();
                              }

                              if (wishlistSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final wishlistDocs =
                                  wishlistSnapshot.data?.docs ?? [];

                              if (wishlistDocs.isEmpty) {
                                return Center(
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
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: wishlistDocs.length,
                                itemBuilder: (context, index) {
                                  final wishlistDoc = wishlistDocs[index];
                                  final productId =
                                      wishlistDoc
                                          .data()['productId']
                                          ?.toString() ??
                                      wishlistDoc.id;

                                  return StreamBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>
                                  >(
                                    stream: _db
                                        .collection('products')
                                        .doc(productId)
                                        .snapshots(),
                                    builder: (context, productSnapshot) {
                                      if (productSnapshot.hasError ||
                                          !productSnapshot.hasData ||
                                          !productSnapshot.data!.exists) {
                                        return const SizedBox.shrink();
                                      }

                                      final product = Map<String, dynamic>.from(
                                        productSnapshot.data!.data()!,
                                      );
                                      product['id'] = productSnapshot.data!.id;

                                      return _WishlistItemCard(
                                        key: ValueKey(
                                          product['id']?.toString() ??
                                              productId,
                                        ),
                                        item: WishlistItem.fromProduct(product),
                                        onRemove: () async {
                                          await _db
                                              .collection('users')
                                              .doc(userId)
                                              .collection('wishlist')
                                              .doc(productId)
                                              .delete();
                                        },
                                        onAddToCart: () async {
                                          final cartRef = _db
                                              .collection('users')
                                              .doc(userId)
                                              .collection('cart')
                                              .doc(productId);
                                          final snapshot = await cartRef.get();
                                          final currentQuantity =
                                              (snapshot.data()?['quantity']
                                                      as num?)
                                                  ?.toInt() ??
                                              0;
                                          final originalPrice =
                                              (product['price'] ??
                                                      product['finalPrice'] ??
                                                      0)
                                                  as num;
                                          final discountedPrice =
                                              (product['finalPrice'] ??
                                                      product['price'] ??
                                                      0)
                                                  as num;
                                          final discountPercentage =
                                              (product['discountPercentage'] ??
                                                      0)
                                                  as num;

                                          await cartRef.set({
                                            'productId': productId,
                                            'productName':
                                                product['name']?.toString() ??
                                                'Product',
                                            'productImage':
                                                product['productImage']
                                                    ?.toString() ??
                                                '',
                                            'price': discountedPrice.toInt(),
                                            'originalPrice': originalPrice
                                                .toInt(),
                                            'discountedPrice': discountedPrice
                                                .toInt(),
                                            'discountPercentage':
                                                discountPercentage.toDouble(),
                                            'quantity': currentQuantity + 1,
                                            'addedAt':
                                                FieldValue.serverTimestamp(),
                                          }, SetOptions(merge: true));

                                          await _db
                                              .collection('users')
                                              .doc(userId)
                                              .collection('wishlist')
                                              .doc(productId)
                                              .delete();

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product['name'] ?? 'Product'} added to cart',
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        onImageTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                    productData: product,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
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
  final Future<void> Function() onRemove;
  final Future<void> Function() onAddToCart;
  final VoidCallback onImageTap;

  const _WishlistItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
    required this.onImageTap,
  }) : super(key: key);

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
  void didUpdateWidget(covariant _WishlistItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      isFavorite = widget.item.isFavorite;
    }
  }

  Widget _buildImage(String path) {
    final p = path.trim();
    if (p.isEmpty)
      return Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 40,
      );
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return Image.network(
        p,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (c, e, s) => Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey600,
          size: 40,
        ),
      );
    }
    final file = File(p);
    if (file.existsSync())
      return Image.file(file, fit: BoxFit.cover, width: 80, height: 80);
    return Image.asset(
      p,
      fit: BoxFit.cover,
      width: 80,
      height: 80,
      errorBuilder: (c, e, s) => Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 40,
      ),
    );
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
            child: GestureDetector(
              onTap: widget.onImageTap,
              child: Center(child: _buildImage(widget.item.imagePath)),
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
                      onPressed: () async {
                        await widget.onAddToCart();
                      },
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
              onTap: () async {
                final prev = isFavorite;
                setState(() {
                  isFavorite = !isFavorite;
                });
                if (!isFavorite) {
                  try {
                    await widget.onRemove();
                  } catch (e) {
                    // rollback UI on error
                    if (mounted) {
                      setState(() {
                        isFavorite = prev;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to remove from wishlist'),
                        ),
                      );
                    }
                  }
                }
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
  final String id;
  final String name;
  final String price;
  final String imagePath;
  bool isFavorite;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isFavorite = false,
  });
  factory WishlistItem.fromProduct(Map<String, dynamic> product) {
    final finalPrice = product['finalPrice'] ?? product['price'] ?? 0;
    return WishlistItem(
      id: product['id']?.toString() ?? '',
      name: product['name']?.toString() ?? 'Product',
      price: '₹$finalPrice',
      imagePath: product['productImage']?.toString() ?? '',
      isFavorite: true,
    );
  }
}
