import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class UserManageScreen extends StatefulWidget {
  const UserManageScreen({Key? key}) : super(key: key);

  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  int _selectedIndex = 3; // Users tab selected

  void _onNavChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<_User> _users = [
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

  // Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.arrow_back, color: AppColors.black),
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
          Icon(Icons.person_add_alt_1, color: AppColors.primary),
        ],
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: AppColors.grey400),
            hintText: 'Find users by name or email',
            hintStyle: TextStyle(color: AppColors.grey400),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // User list
  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        return _UserCard(user: _users[index]);
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

// User Card UI
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
                  user.name.substring(0, 2),
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              const SizedBox(width: 12),

              // Name + Email
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

              // Actions
              Row(
                children: const [
                  Icon(Icons.edit, size: 20, color: AppColors.grey500),
                  SizedBox(width: 10),
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
