import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminAddProduct.dart';
import 'AdminEditProduct.dart';

class AdminProductManageScreen extends StatefulWidget {
  const AdminProductManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductManageScreen> createState() =>
      _AdminProductManageScreenState();
}

class _AdminProductManageScreenState extends State<AdminProductManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      setState(() {
        _allProducts = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where(
              (product) =>
                  product['name']?.toString().toLowerCase().contains(query) ??
                  false,
            )
            .toList();
      }
    });
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).update({
        'isActive': false,
      });
      await _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _restoreProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).update({
        'isActive': true,
      });
      await _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentBlue = const Color(0xFF4C6FFF);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(accentBlue),
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  )
                : Expanded(child: _buildProductList(accentBlue)),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.black),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Manage Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color accentBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAddProduct(),
                ),
              );
              if (result == true) {
                _fetchProducts();
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: AppColors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(Color accentBlue) {
    return _filteredProducts.isEmpty
        ? const Center(
            child: Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return _ProductCard(
                product: _filteredProducts[index],
                accentBlue: accentBlue,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminEditProduct(
                        productId: _filteredProducts[index]['id'],
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchProducts();
                  }
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Product'),
                      content: const Text(
                        'Are you sure you want to delete this product?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteProduct(_filteredProducts[index]['id']);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onRestore: () {
                  _restoreProduct(_filteredProducts[index]['id']);
                },
              );
            },
          );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Color accentBlue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const _ProductCard({
    Key? key,
    required this.product,
    required this.accentBlue,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
  }) : super(key: key);

  Color _getStockBgColor() {
    final stock = product['stock'] as int? ?? 0;
    if (stock == 0) return AppColors.grey200;
    if (stock <= 2) return const Color(0xFFFDE8E8);
    if (stock <= 8) return const Color(0xFFFEF4E4);
    return const Color(0xFFDEF7EC);
  }

  Color _getStockTextColor() {
    final stock = product['stock'] as int? ?? 0;
    if (stock == 0) return AppColors.grey600;
    if (stock <= 2) return AppColors.danger;
    if (stock <= 8) return AppColors.warning;
    return const Color(0xFF03543F);
  }

  String _getStockText() {
    final stock = product['stock'] as int? ?? 0;
    if (stock == 0) return 'Out of stock';
    return '$stock in stock';
  }

  @override
  Widget build(BuildContext context) {
    final bool isInactive = (product['isActive'] as bool?) == false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isInactive ? const Color(0xFFFDE8E8) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInactive
              ? AppColors.danger
              : AppColors.grey200.withOpacity(0.5),
          width: isInactive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildProductImage(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product['name']?.toString() ?? 'Product',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['brand']?.toString() ?? 'Brand',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStockBgColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStockText(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStockTextColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product['price']?.toString() ?? '0'}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accentBlue,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: isInactive ? onRestore : onDelete,
                    child: Icon(
                      isInactive
                          ? Icons.restore_outlined
                          : Icons.delete_outline,
                      color: isInactive ? AppColors.danger : AppColors.grey500,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = product['productImage']?.toString();
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_outlined,
              color: AppColors.white,
              size: 32,
            );
          },
        );
      }
      // Treat any non-http non-empty path as a local file path
      try {
        return Image.file(
          File(imagePath),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_outlined,
              color: AppColors.white,
              size: 32,
            );
          },
        );
      } catch (_) {
        return const Icon(
          Icons.image_outlined,
          color: AppColors.white,
          size: 32,
        );
      }
    }
    return const Icon(Icons.image_outlined, color: AppColors.white, size: 32);
  }
}
