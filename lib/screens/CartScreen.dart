import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tekzo/screens/ProductDetailScreen.dart';
import 'package:tekzo/services/auth_service.dart';
import '../theme/app_colors.dart';
import 'CheckoutScreen.dart';

/// Shopping cart screen showing selected items and order summary.
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _currentUserId =>
      AuthService.instance.loggedInUserData?['id']?.toString();

  Future<void> _updateQuantity(String productId, int quantity) async {
    final userId = _currentUserId;
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .set({'quantity': quantity}, SetOptions(merge: true));
  }

  Future<void> _removeItem(String productId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (_) {
      // Ignore stale delete attempts from already-removed cart items.
    }
  }

  DateTime _parseAddedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.instance.isLoggedIn;
    final userId = _currentUserId;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: isLoggedIn
            ? (userId == null
                  ? const SizedBox.shrink()
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _db
                          .collection('users')
                          .doc(userId)
                          .collection('cart')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final cartDocs =
                            List<
                              QueryDocumentSnapshot<Map<String, dynamic>>
                            >.from(snapshot.data?.docs ?? const []);
                        cartDocs.sort(
                          (a, b) => _parseAddedAt(
                            b.data()['addedAt'],
                          ).compareTo(_parseAddedAt(a.data()['addedAt'])),
                        );

                        final cartItems = cartDocs
                            .map(
                              (doc) =>
                                  CartItem.fromFirestore(doc.id, doc.data()),
                            )
                            .toList();
                        final subtotal = cartItems.fold<double>(
                          0,
                          (sum, item) =>
                              sum + (item.originalPrice * item.quantity),
                        );
                        final totalDiscount = cartItems.fold<double>(
                          0,
                          (sum, item) =>
                              sum +
                              ((item.originalPrice - item.discountedPrice) *
                                  item.quantity),
                        );
                        final totalAmount = subtotal - totalDiscount;

                        return Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Text(
                                    'Your Cart',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            Divider(color: AppColors.grey300, height: 1),
                            Expanded(
                              child: cartItems.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 64,
                                            color: AppColors.grey400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Your cart is empty',
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
                                      itemCount: cartItems.length,
                                      itemBuilder: (context, index) {
                                        final item = cartItems[index];
                                        return _CartItemCard(
                                          key: ValueKey(item.productId),
                                          item: item,
                                          onImageTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProductDetailScreen(
                                                      productData: {
                                                        'id': item.productId,
                                                      },
                                                    ),
                                              ),
                                            );
                                          },
                                          onQuantityChanged:
                                              (newQuantity) async {
                                                if (newQuantity > 0) {
                                                  await _updateQuantity(
                                                    item.productId,
                                                    newQuantity,
                                                  );
                                                }
                                              },
                                          onRemove: () async {
                                            await _removeItem(item.productId);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            Divider(color: AppColors.grey300, height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      Text(
                                        '₹${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Discount',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      Text(
                                        '-₹${totalDiscount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: AppColors.grey300, height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₹${totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: cartItems.isEmpty
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CheckoutScreen(),
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryDark,
                                        disabledBackgroundColor:
                                            AppColors.grey300,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Proceed to Checkout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: cartItems.isEmpty
                                              ? AppColors.grey600
                                              : AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ))
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please login to view your cart',
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
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Future<void> Function(int) onQuantityChanged;
  final Future<void> Function() onRemove;
  final VoidCallback onImageTap;

  const _CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onImageTap,
  });

  Widget _buildImage(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 32,
      );
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey600,
          size: 32,
        ),
      );
    }

    final file = File(trimmed);
    if (file.existsSync()) {
      return Image.file(file, width: double.infinity, fit: BoxFit.cover);
    }

    return Image.asset(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: onImageTap,
              child: Center(child: _buildImage(item.imagePath)),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Variant
                Text(
                  item.variant,
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '₹${item.discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Actions (Quantity and Remove)
          Column(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (item.quantity > 1) {
                          await onQuantityChanged(item.quantity - 1);
                        } else {
                          await onRemove();
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.remove,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await onQuantityChanged(item.quantity + 1);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Remove Button
              GestureDetector(
                onTap: () async {
                  await onRemove();
                },
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String productId;
  final String name;
  final String variant;
  final double originalPrice;
  final double discountedPrice;
  final double discountPercentage;
  int quantity;
  final String imagePath;

  CartItem({
    required this.productId,
    required this.name,
    required this.variant,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.quantity,
    required this.imagePath,
  });

  factory CartItem.fromFirestore(String id, Map<String, dynamic> data) {
    final discountedPrice =
        (data['discountedPrice'] ?? data['price'] ?? 0) as num;
    final originalPrice =
        (data['originalPrice'] ?? data['price'] ?? discountedPrice) as num;
    return CartItem(
      productId: data['productId']?.toString() ?? id,
      name: data['productName']?.toString() ?? 'Product',
      variant: data['variant']?.toString() ?? '',
      originalPrice: originalPrice.toDouble(),
      discountedPrice: discountedPrice.toDouble(),
      discountPercentage: (data['discountPercentage'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      imagePath: data['productImage']?.toString() ?? '',
    );
  }
}
