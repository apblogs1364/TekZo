import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';

/// Product listing screen with category tabs and product grid.
class ProductScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ProductScreen({Key? key, this.initialCategoryId}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search laptops, phones, gear...',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
            ),
            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _db.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 28,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    );
                  }

                  final categories = [
                    _CategoryFilter.all(),
                    ...snapshot.data?.docs
                            .map(
                              (doc) =>
                                  _CategoryFilter.fromDoc(doc.id, doc.data()),
                            )
                            .where((category) => category.isActive)
                            .toList() ??
                        [],
                  ];

                  final effectiveSelectedCategoryId =
                      categories.any(
                        (category) => category.id == _selectedCategoryId,
                      )
                      ? _selectedCategoryId
                      : null;

                  return SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category.id.isEmpty
                            ? effectiveSelectedCategoryId == null
                            : effectiveSelectedCategoryId == category.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id.isEmpty
                                  ? null
                                  : category.id;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.black
                                      : AppColors.grey600,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 2,
                                  width: 40,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Products Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.collection('categories').snapshots(),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    final categories = [
                      _CategoryFilter.all(),
                      ...categorySnapshot.data?.docs
                              .map(
                                (doc) =>
                                    _CategoryFilter.fromDoc(doc.id, doc.data()),
                              )
                              .where((category) => category.isActive)
                              .toList() ??
                          [],
                    ];

                    final effectiveSelectedCategoryId =
                        categories.any(
                          (category) => category.id == _selectedCategoryId,
                        )
                        ? _selectedCategoryId
                        : null;

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _db.collection('products').snapshots(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.hasError) {
                          return const SizedBox.shrink();
                        }

                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          );
                        }

                        final filteredProducts =
                            productSnapshot.data?.docs
                                .map(
                                  (doc) => _ProductRecord.fromDoc(
                                    doc.id,
                                    doc.data(),
                                  ),
                                )
                                .where((product) => product.isActive)
                                .where((product) {
                                  final categoryName = categories
                                      .firstWhere(
                                        (category) =>
                                            category.id == product.categoryId,
                                        orElse: () => const _CategoryFilter(
                                          id: '',
                                          name: '',
                                          isActive: true,
                                        ),
                                      )
                                      .name;
                                  final matchesSearch =
                                      _searchQuery.isEmpty ||
                                      product.matches(
                                        _searchQuery,
                                        categoryName: categoryName,
                                      );
                                  final matchesCategory =
                                      effectiveSelectedCategoryId == null
                                      ? true
                                      : product.categoryId ==
                                            effectiveSelectedCategoryId;
                                  return matchesSearch && matchesCategory;
                                })
                                .toList() ??
                            [];

                        if (filteredProducts.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: filteredProducts[index],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final _ProductRecord product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-detail',
                  arguments: product.toJson(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(child: _buildProductImage()),
              ),
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.finalPrice}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: AppColors.primaryDark,
                          size: 18,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product.toJson(),
                          );
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
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
    final path = product.productImage.trim();
    if (path.isEmpty) {
      return Icon(Icons.image_not_supported_outlined, color: AppColors.grey600);
    }

    final file = File(path);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.file(file, width: double.infinity, fit: BoxFit.cover),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.grey600,
        );
      },
    );
  }
}

class _CategoryFilter {
  final String id;
  final String name;
  final bool isActive;

  const _CategoryFilter({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory _CategoryFilter.all() {
    return const _CategoryFilter(id: '', name: 'All Products', isActive: true);
  }

  factory _CategoryFilter.fromDoc(String id, Map<String, dynamic> data) {
    return _CategoryFilter(
      id: id,
      name: data['name']?.toString() ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

class _ProductRecord {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String shortDescription;
  final String color;
  final String productImage;
  final int finalPrice;
  final bool isActive;
  final String categoryId;

  const _ProductRecord({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.shortDescription,
    required this.color,
    required this.productImage,
    required this.finalPrice,
    required this.isActive,
    required this.categoryId,
  });

  factory _ProductRecord.fromDoc(String id, Map<String, dynamic> data) {
    return _ProductRecord(
      id: id,
      name: data['name']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      shortDescription: data['shortDescription']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      productImage: data['productImage']?.toString() ?? '',
      finalPrice: int.tryParse(data['finalPrice']?.toString() ?? '') ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      categoryId: data['categoryId']?.toString() ?? '',
    );
  }

  bool matches(String query, {String categoryName = ''}) {
    final text = [
      name,
      brand,
      color,
      description,
      shortDescription,
      categoryName,
      finalPrice.toString(),
    ].join(' ');
    return text.toLowerCase().contains(query);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'shortDescription': shortDescription,
      'color': color,
      'productImage': productImage,
      'finalPrice': finalPrice,
      'isActive': isActive,
      'categoryId': categoryId,
    };
  }
}
