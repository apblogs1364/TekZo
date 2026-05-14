import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminUserDetailsScreen.dart';

class AdminUserManageScreen extends StatefulWidget {
  const AdminUserManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManageScreen> createState() => _AdminUserManageScreenState();
}

class _AdminUserManageScreenState extends State<AdminUserManageScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        ],
      ),
    );
  }

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
            hintText: 'Search by name, email, phone, role, or location',
            hintStyle: TextStyle(color: AppColors.grey400),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load users',
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

        final users =
            snapshot.data?.docs
                .map((doc) => _UserRecord.fromDoc(doc.id, doc.data()))
                .toList() ??
            [];

        users.sort(
          (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );

        final filteredUsers = _searchQuery.isEmpty
            ? users
            : users.where((user) => user.matches(_searchQuery)).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text(
              users.isEmpty ? 'No users found' : 'No matching users found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _UserCard(
              user: user,
              onView: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminUserDetailsScreen(userId: user.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _UserRecord {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String location;
  final String password;
  final String profileImageUrl;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const _UserRecord({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.location,
    required this.password,
    required this.profileImageUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory _UserRecord.fromDoc(String id, Map<String, dynamic> data) {
    return _UserRecord(
      id: id,
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      dob: data['dob']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      profileImageUrl: data['profileImageUrl']?.toString() ?? '',
      role: data['role']?.toString().isNotEmpty == true
          ? data['role'].toString()
          : 'customer',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get searchText => [
    firstName,
    lastName,
    fullName,
    email,
    phone,
    gender,
    dob,
    location,
    role,
    isActive ? 'active' : 'inactive',
  ].join(' ').toLowerCase();

  bool matches(String query) => searchText.contains(query);

  String get initials {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class _UserCard extends StatelessWidget {
  final _UserRecord user;
  final VoidCallback onView;

  const _UserCard({required this.user, required this.onView});

  Color _getRoleColor() {
    switch (user.role.toUpperCase()) {
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
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : 'Unnamed User',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            user.role.toUpperCase(),
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
                      user.email.isNotEmpty ? user.email : 'No email',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              const Spacer(),
              Text(
                user.phone.isNotEmpty ? user.phone : 'No phone',
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  user.location.isNotEmpty ? user.location : 'No location',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.createdAt == null ? 'N/A' : _formatDate(user.createdAt!),
                style: const TextStyle(fontSize: 12, color: AppColors.grey400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imagePath = user.profileImageUrl.trim();
    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            imagePath,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackAvatar(),
          ),
        );
      }

      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackAvatar(),
          ),
        );
      }
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.grey200,
      child: Text(
        user.initials,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month ${date.year}';
  }
}
