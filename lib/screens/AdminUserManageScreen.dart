import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminEditUser.dart';

class AdminUserManageScreen extends StatefulWidget {
  const AdminUserManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManageScreen> createState() => _AdminUserManageScreenState();
}

class _AdminUserManageScreenState extends State<AdminUserManageScreen> {
  int _selectedIndex = 3; // Users tab selected
  final TextEditingController _searchController = TextEditingController();

  void _onNavChanged(int index) {
    if (index == _selectedIndex) return; // No navigation if same tab

    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on bottom navigation selection
    switch (index) {
      case 0: // Dash
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 1: // Items
        Navigator.pushReplacementNamed(context, '/products');
        break;
      case 2: // Orders
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3: // Users
        // Already on users page
        break;
      case 4: // Config
        // Navigate to config page (when created)
        break;
    }
  }

  final List<_User> _allUsers = [
    _User(
      name: 'Alex Rivera',
      email: 'alex.rivera@tekzo.com',
      role: 'ADMIN',
      isActive: true,
    ),
    _User(
      name: 'Jordan Smith',
      email: 'jordan.s@tekzo.com',
      role: 'EDITOR',
      isActive: true,
    ),
    _User(
      name: 'Sarah Chen',
      email: 'sarah.c@tekzo.com',
      role: 'CUSTOMER',
      isActive: false,
    ),
    _User(
      name: 'Marcus Lee',
      email: 'marcus.lee@tekzo.com',
      role: 'ADMIN',
      isActive: true,
    ),
  ];

  late List<_User> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers
            .where(
              (user) =>
                  user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query),
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
            Expanded(child: _buildUserList()),
            AdminBottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Header with back button and add user button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.black),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Manage Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Add user feature coming soon')),
          //     );
          //   },
          //   child: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
          // ),
        ],
      ),
    );
  }

  // Search bar with filtering
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: AppColors.grey400),
            hintText: 'Find users by name or email',
            hintStyle: TextStyle(color: AppColors.grey400),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // User list with filtered results
  Widget _buildUserList() {
    return _filteredUsers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              return _UserCard(user: _filteredUsers[index]);
            },
          );
  }
}

// User Model
class _User {
  final String name;
  final String email;
  final String role;
  final bool isActive;

  _User({
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

// User Card UI with edit and delete actions
class _UserCard extends StatelessWidget {
  final _User user;

  const _UserCard({Key? key, required this.user}) : super(key: key);

  Color _getRoleColor() {
    switch (user.role) {
      case 'ADMIN':
        return AppColors.primary;
      case 'EDITOR':
        return AppColors.secondary;
      default:
        return AppColors.grey400;
    }
  }

  void _showUserOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit User'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminEditUser(
                      userName: user.name,
                      userEmail: user.email,
                      userRole: user.role,
                      isActive: user.isActive,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.danger),
              title: const Text(
                'Delete User',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${user.name} deleted')));
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
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.grey200,
                child: Text(
                  user.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + Email + Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEditUser(
                            userName: user.name,
                            userEmail: user.email,
                            userRole: user.role,
                            isActive: user.isActive,
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Indicator
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: user.isActive ? AppColors.success : AppColors.grey400,
              ),
              const SizedBox(width: 6),
              Text(
                user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: user.isActive ? AppColors.success : AppColors.grey400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
