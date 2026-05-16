import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tekzo/services/auth_service.dart';

import '../theme/app_colors.dart';

/// Product detail screen: streams a product by id when provided,
/// otherwise uses the passed product map. Renders full details,
/// specifications and two related products from same category.
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const ProductDetailScreen({Key? key, this.productData}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _quantity;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _wishlistProductId;
  String? _wishlistSyncKey;
  bool _isWishlisted = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _wishlistSub;

  bool get _isLoggedIn => AuthService.instance.isLoggedIn;
  String? get _currentUserId =>
      AuthService.instance.loggedInUserData?['id']?.toString();

  @override
  void initState() {
    super.initState();
    _quantity = 1;
  }

  @override
  void dispose() {
    _wishlistSub?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get _passedProduct => widget.productData ?? {};

  @override
  Widget build(BuildContext context) {
    final passedId = _passedProduct['id']?.toString();

    if (passedId != null && passedId.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _db.collection('products').doc(passedId).snapshots(),
        builder: (context, snap) {
          if (snap.hasError)
            return _scaffoldWithCenteredText('Error loading product');
          if (!snap.hasData) return _scaffoldWithCenteredProgress();
          final doc = snap.data!;
          if (!doc.exists)
            return _scaffoldWithCenteredText('Product not found');
          final product = Map<String, dynamic>.from(doc.data()!);
          product['id'] = doc.id;
          return _buildContent(product);
        },
      );
    }

    // Fallback: use passed map directly
    return _buildContent(_passedProduct);
  }

  Widget _scaffoldWithCenteredProgress() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
  Widget _scaffoldWithCenteredText(String t) =>
      Scaffold(body: Center(child: Text(t)));

  Widget _buildContent(Map<String, dynamic> product) {
    final displayImage = product['productImage']?.toString() ?? '';
    final productId = product['id']?.toString() ?? '';

    if (productId.isNotEmpty) {
      _scheduleWishlistSync(productId);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Large image
              Container(
                width: double.infinity,
                height: 360,
                color: AppColors.grey200,
                child: Center(
                  child: displayImage.isEmpty
                      ? Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.grey600,
                          size: 80,
                        )
                      : _buildProductImageFromPath(displayImage),
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'] ?? 'Product',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isWishlisted
                                ? AppColors.danger
                                : AppColors.black,
                          ),
                          onPressed: () => _toggleWishlist(product),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if ((product['brand'] ?? '').toString().isNotEmpty)
                      Text(
                        'Brand: ${product['brand']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    if ((product['color'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Color: ${product['color']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if ((product['price'] ?? 0) >
                                    (product['finalPrice'] ?? 0))
                                  Text(
                                    '₹${product['price'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${product['finalPrice'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if ((product['discountPercentage'] ?? 0) > 0)
                              Text(
                                '${product['discountPercentage']}% OFF',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              (product['stock'] ?? 0) > 0
                                  ? 'In Stock'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: (product['stock'] ?? 0) > 0
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product['rating'] ?? 0.0}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product['totalReviews'] ?? 0} Reviews',
                              style: TextStyle(color: AppColors.grey600),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'About this item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ??
                          product['shortDescription'] ??
                          'No description available',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (product['specifications'] != null &&
                        product['specifications'] is Map &&
                        (product['specifications'] as Map).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Specifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...((product['specifications'] ?? {}) as Map).entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}: ',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${entry.value}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],

                    const SizedBox(height: 20),
                    const Text(
                      'Related Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRelatedProductsFromProduct(product),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.grey200)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      if (_quantity < (product['stock'] ?? 999))
                        setState(() => _quantity++);
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (product['stock'] ?? 0) > 0
                    ? () async {
                        if (!_isLoggedIn) {
                          _showLoginDialog();
                          return;
                        }

                        await _addToCart(product);

                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product['name'] ?? 'Product'} added to cart',
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (product['stock'] ?? 0) > 0
                      ? AppColors.primaryDark
                      : AppColors.grey400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (product['stock'] ?? 0) > 0 ? 'Add to Cart' : 'Out of Stock',
                  style: const TextStyle(
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
    );
  }

  void _scheduleWishlistSync(String productId) {
    final userId = _currentUserId;
    final syncKey = '${userId ?? 'guest'}::$productId';

    if (_wishlistSyncKey == syncKey) {
      return;
    }

    _wishlistSyncKey = syncKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _wishlistSyncKey != syncKey) {
        return;
      }

      if (!_isLoggedIn || userId == null) {
        // cancel any existing listener and reset state
        _wishlistSub?.cancel();
        _wishlistSub = null;
        if (_isWishlisted) {
          setState(() {
            _isWishlisted = false;
          });
        }
      } else {
        _wishlistProductId = productId;
        // cancel previous subscription
        _wishlistSub?.cancel();
        _wishlistSub = _db
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc(productId)
            .snapshots()
            .listen(
              (snap) {
                if (!mounted || _wishlistSyncKey != syncKey) return;
                setState(() {
                  _isWishlisted = snap.exists;
                });
              },
              onError: (_) {
                if (mounted) {
                  setState(() {
                    _isWishlisted = false;
                  });
                }
              },
            );
      }
    });
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product) async {
    final productId = product['id']?.toString() ?? '';
    if (productId.isEmpty) {
      return;
    }

    final userId = _currentUserId;
    if (!_isLoggedIn || userId == null) {
      _showLoginDialog(message: 'Please login to manage your wishlist.');
      return;
    }

    final wishlistRef = _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId);

    final shouldAdd = !_isWishlisted;
    if (shouldAdd) {
      await wishlistRef.set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await wishlistRef.delete();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isWishlisted = shouldAdd;
      _wishlistProductId = productId;
    });
  }

  Future<void> _loadWishlistState(String productId, String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .get();

    if (!mounted || _wishlistProductId != productId) {
      return;
    }

    setState(() {
      _isWishlisted = snapshot.exists;
    });
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = product['id']?.toString() ?? '';
    if (productId.isEmpty) {
      return;
    }

    final userId = _currentUserId;
    if (!_isLoggedIn || userId == null) {
      _showLoginDialog(message: 'Please login to add items to your cart.');
      return;
    }

    final cartRef = _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final snapshot = await cartRef.get();
    final currentQuantity =
        (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
    final originalPrice =
        (product['price'] ?? product['finalPrice'] ?? 0) as num;
    final discountedPrice =
        (product['finalPrice'] ?? product['price'] ?? 0) as num;
    final discountPercentage = (product['discountPercentage'] ?? 0) as num;

    await cartRef.set({
      'productId': productId,
      'productName': product['name']?.toString() ?? 'Product',
      'productImage': product['productImage']?.toString() ?? '',
      'price': discountedPrice.toInt(),
      'originalPrice': originalPrice.toInt(),
      'discountedPrice': discountedPrice.toInt(),
      'discountPercentage': discountPercentage.toDouble(),
      'quantity': currentQuantity + 1,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Widget _buildProductImageFromPath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty)
      return Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 80,
      );

    // Network image support
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey600,
          size: 80,
        ),
      );
    }

    final file = File(trimmed);
    if (file.existsSync())
      return Image.file(file, width: double.infinity, fit: BoxFit.cover);

    return Image.asset(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 80,
      ),
    );
  }

  Widget _buildRelatedProductsFromProduct(Map<String, dynamic> product) {
    final categoryId = product['categoryId']?.toString() ?? '';
    final productId = product['id']?.toString() ?? '';
    if (categoryId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData)
          return const SizedBox.shrink();
        final all = snapshot.data!.docs
            .map((d) {
              final m = Map<String, dynamic>.from(d.data());
              m['id'] = d.id;
              return m;
            })
            .where((m) => m['id'] != productId)
            .toList();
        if (all.isEmpty) return const SizedBox.shrink();
        all.shuffle();
        final related = all.take(2).toList();
        return Row(
          children: related.map((p) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productData: p),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: _buildRelatedProductImage(p['productImage']),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? 'Product',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${p['finalPrice'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRelatedProductImage(dynamic imagePath) {
    final path = imagePath?.toString().trim() ?? '';
    if (path.isEmpty)
      return Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 32,
      );
    if (path.startsWith('http://') || path.startsWith('https://'))
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey600,
          size: 32,
        ),
      );
    final file = File(path);
    if (file.existsSync())
      return Image.file(file, width: double.infinity, fit: BoxFit.cover);
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey600,
        size: 32,
      ),
    );
  }

  void _showLoginDialog({
    String message = 'Please login to add items to your cart.',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Login Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey500),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
