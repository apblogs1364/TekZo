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

class _AdminCategoryManageScreenState
    extends State<AdminCategoryManageScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Accent blue consistent with the rest of the admin screens
  static const Color _accentBlue = Color(0xFF4C6FFF);

  final List<_Category> _allCategories = [
    _Category(
      name: 'Smartphones',
      parent: 'ELECTRONICS',
      itemCount: 45,
      bgColor: Color(0xFFFDE8D8),
      icon: Icons.smartphone,
      iconColor: Color(0xFFE8845A),
    ),
    _Category(
      name: 'Laptops',
      parent: 'COMPUTING',
      itemCount: 28,
      bgColor: Color(0xFFEAEAF4),
      icon: Icons.laptop_mac,
      iconColor: Color(0xFF6B7280),
    ),
    _Category(
      name: 'Tablets',
      parent: 'ELECTRONICS',
      itemCount: 12,
      bgColor: Color(0xFFD8EDE8),
      icon: Icons.tablet_mac,
      iconColor: Color(0xFF4B8B7A),
    ),
    _Category(
      name: 'Wearables',
      parent: 'ACCESSORIES',
      itemCount: 67,
      bgColor: Color(0xFFF0F0F0),
      icon: Icons.watch,
      iconColor: Color(0xFF374151),
    ),
    _Category(
      name: 'Audio',
      parent: 'ELECTRONICS',
      itemCount: 34,
      bgColor: Color(0xFF1E1E1E),
      icon: Icons.headphones,
      iconColor: AppColors.white,
    ),
  ];

  late List<_Category> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
    _searchController.addListener(_filterCategories);
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query) ||
                  c.parent.toLowerCase().contains(query),
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
          // Search field
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
                  hintText: 'Search categories, items...',
                  hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Add button
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/admin/categories/add');
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
    if (_filteredCategories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(category: _filteredCategories[index]);
      },
    );
  }
}

// ─── Data model ────────────────────────────────────────────────────────────────

class _Category {
  final String name;
  final String parent;
  final int itemCount;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;

  const _Category({
    required this.name,
    required this.parent,
    required this.itemCount,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
  });
}

// ─── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final _Category category;

  const _CategoryCard({Key? key, required this.category}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content:
            Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${category.name}" deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

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
          // Category image / icon placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: category.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: category.iconColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),

          // Name, parent, item count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PARENT: ${category.parent}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${category.itemCount} items',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit & delete icons — horizontal
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminEditCategory(
                        categoryName: category.name,
                        description:
                            '${category.name} category description.',
                        showOnHome: false,
                        activeStatus: true,
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
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
