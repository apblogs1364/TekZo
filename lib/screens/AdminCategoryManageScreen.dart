import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminEditCategory.dart';

class AdminCategoryManageScreen extends StatefulWidget {
  const AdminCategoryManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoryManageScreen> createState() =>
      _AdminCategoryManageScreenState();
}

class _AdminCategoryManageScreenState extends State<AdminCategoryManageScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _accentBlue = Color(0xFF4C6FFF);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteCategory(String categoryId, String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _db.collection('categories').doc(categoryId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting category: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildCategoryList()),
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
              'Manage Categories',
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

  Widget _buildSearchBar() {
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
                  hintText: 'Search categories by name or description',
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
              final result = await Navigator.pushNamed(
                context,
                '/admin/categories/add',
              );
              if (result == true) {
                setState(() {});
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _accentBlue,
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

  Widget _buildCategoryList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        }

        final categories =
            snapshot.data?.docs
                .map((doc) => _CategoryRecord.fromDoc(doc.id, doc.data()))
                .toList() ??
            [];

        categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        final filteredCategories = _searchQuery.isEmpty
            ? categories
            : categories
                  .where((category) => category.matches(_searchQuery))
                  .toList();

        if (filteredCategories.isEmpty) {
          return Center(
            child: Text(
              categories.isEmpty
                  ? 'No categories found'
                  : 'No matching categories found',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: filteredCategories.length,
          itemBuilder: (context, index) {
            return _CategoryCard(
              category: filteredCategories[index],
              onEdit: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminEditCategory(
                      categoryId: filteredCategories[index].id,
                    ),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              onDelete: () => _deleteCategory(
                filteredCategories[index].id,
                filteredCategories[index].name,
              ),
            );
          },
        );
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
    final text = [
      name,
      description,
      image,
      displayOrder.toString(),
      isActive ? 'active' : 'inactive',
      showOnHome ? 'show on home page' : 'hidden from home page',
    ].join(' ').toLowerCase();
    return text.contains(query);
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryRecord category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200.withOpacity(0.6)),
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
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: category.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: category.image.startsWith('http')
                        ? Image.network(
                            category.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_outlined,
                                color: AppColors.grey500,
                                size: 34,
                              );
                            },
                          )
                        : Image.file(
                            File(category.image),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_outlined,
                                color: AppColors.grey500,
                                size: 34,
                              );
                            },
                          ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.grey500,
                    size: 34,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.isNotEmpty ? category.name : 'Unnamed Category',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category.description.isNotEmpty
                      ? category.description
                      : 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.format_list_numbered,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Order: ${category.displayOrder}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: category.isActive
                          ? AppColors.success
                          : AppColors.grey400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: category.isActive
                            ? AppColors.success
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onDelete,
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
    );
  }
}
