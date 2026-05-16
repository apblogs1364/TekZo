import 'package:flutter/material.dart';
import 'dart:io';

import '../theme/app_colors.dart';
import 'package:tekzo/services/auth_service.dart';
import 'AdminEditProfileScreen.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

/// Admin profile screen showing admin details and account management.
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final admin = AuthService.instance.loggedInUserData;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      _buildAdminCard(admin, context),
                      const SizedBox(height: 20),
                      _buildAdminInfo(admin),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Admin Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic>? admin, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileAvatar(admin),
            const SizedBox(height: 16),
            Text(
              admin == null
                  ? 'Admin'
                  : '${admin['firstName'] ?? ''} ${admin['lastName'] ?? ''}'
                        .trim(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              admin?['email'] ?? 'admin@tekzo.com',
              style: const TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEditProfileScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Map<String, dynamic>? admin) {
    final profileImageUrl = admin?['profileImageUrl']?.toString() ?? '';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey200,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: Center(child: _buildProfileImage(profileImageUrl)),
    );
  }

  Widget _buildProfileImage(String profileImageUrl) {
    if (profileImageUrl.isEmpty) {
      return Icon(
        Icons.admin_panel_settings,
        size: 50,
        color: AppColors.primaryDark,
      );
    }

    if (profileImageUrl.startsWith('/')) {
      final file = File(profileImageUrl);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, fit: BoxFit.cover, width: 100, height: 100),
        );
      }
    }

    return Icon(
      Icons.admin_panel_settings,
      size: 50,
      color: AppColors.primaryDark,
    );
  }

  Widget _buildAdminInfo(Map<String, dynamic>? admin) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: admin?['email'] ?? 'N/A',
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: admin?['phone'] ?? 'N/A',
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Date of Birth',
            value: admin?['dob'] ?? 'N/A',
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: admin?['location'] ?? 'N/A',
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: admin?['role'] ?? 'admin',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primaryDark),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.grey200, indent: 52);
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout from admin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    await AuthService.instance.signOut();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
