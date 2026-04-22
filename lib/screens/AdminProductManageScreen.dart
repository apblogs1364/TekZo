import 'package:flutter/material.dart';
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
  final List<_Product> _allProducts = [
    _Product(
      name: 'Wireless Headphon...',
      sku: 'SKU: TKZ-001',
      price: '₹149.99',
      stock: 12,
      placeholderIcon: Icons.headphones,
    ),
    _Product(
      name: 'Smart Watch Serie...',
      sku: 'SKU: TKZ-005',
      price: '₹299.00',
      stock: 8,
      placeholderIcon: Icons.watch,
    ),
    _Product(
      name: 'Pro Running Shoes',
      sku: 'SKU: TKZ-012',
      price: '₹85.50',
      stock: 2,
      placeholderIcon: Icons.directions_run,
    ),
    _Product(
      name: 'Vintage Film Camera',
      sku: 'SKU: TKZ-009',
      price: '₹120.00',
      stock: 0,
      placeholderIcon: Icons.camera_alt,
    ),
  ];

  late List<_Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_filterProducts);
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
                  product.name.toLowerCase().contains(query) ||
                  product.sku.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The design uses blue for active elements (FAB, prices, active nav tab).
    // AppColors.primary is grey in the codebase, so we use a literal blue
    // color consistent with the provided design screenshot for these specific accents.
    final Color accentBlue = const Color(0xFF4C6FFF);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(accentBlue),
            Expanded(child: _buildProductList(accentBlue)),
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
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAddProduct(),
                ),
              );
            },
            child: Container(
              height: 48, // matching text field default height
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
              );
            },
          );
  }
}

class _Product {
  final String name;
  final String sku;
  final String price;
  final int stock;
  final IconData placeholderIcon;

  _Product({
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.placeholderIcon,
  });
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final Color accentBlue;

  const _ProductCard({
    Key? key,
    required this.product,
    required this.accentBlue,
  }) : super(key: key);

  Color _getStockBgColor() {
    if (product.stock == 0) return AppColors.grey200;
    if (product.stock <= 2) return const Color(0xFFFDE8E8); // Light red
    if (product.stock <= 8) return const Color(0xFFFEF4E4); // Light orange
    return const Color(0xFFDEF7EC); // Light green
  }

  Color _getStockTextColor() {
    if (product.stock == 0) return AppColors.grey600;
    if (product.stock <= 2) return AppColors.danger;
    if (product.stock <= 8) return AppColors.warning;
    return const Color(0xFF03543F); // Dark green
  }

  String _getStockText() {
    if (product.stock == 0) return 'Out of stock';
    return '${product.stock} in stock';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
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
          // Image placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(
                0xFF1E1E1E,
              ), // Dark background matching the design's products
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.placeholderIcon,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
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
                  product.sku,
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

          // Price and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.price,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEditProduct(
                            productName: product.name,
                            sku: product.sku,
                            price: product.price,
                            stockQty: '${product.stock}',
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.grey500,
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
}
