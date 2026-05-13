import 'package:flutter/material.dart';
import 'dart:io';

import '../theme/app_colors.dart';
import 'package:tekzo/services/auth_service.dart';
import 'EditProfileScreen.dart';
import 'OrderScreen.dart';
import 'ShippingAddressScreen.dart';
import 'PaymentMethodsScreen.dart';
import 'SettingsScreen.dart';
import 'package:tekzo/widgets/index.dart';
import 'package:tekzo/services/navigation_index_service.dart';

/// Profile screen showing user info and account management options.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<ProfileMenuItem> menuItems = [
    ProfileMenuItem(
      icon: Icons.shopping_bag_outlined,
      title: 'My Orders',
      subtitle: 'Check your orders here',
      trailing: '12',
    ),
    ProfileMenuItem(
      icon: Icons.location_on_outlined,
      title: 'Addresses',
      subtitle: 'Manage your addresses',
      trailing: '',
    ),
    ProfileMenuItem(
      icon: Icons.credit_card_outlined,
      title: 'Payment Methods',
      subtitle: 'Edit or add payment methods',
      trailing: '',
    ),
    ProfileMenuItem(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'Account and app settings',
      trailing: '',
    ),
    ProfileMenuItem(
      icon: Icons.logout_outlined,
      title: 'Sign Out',
      subtitle: 'Logout from your account',
      trailing: '',
      isSignOut: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.loggedInUserData;
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
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48), // For spacing balance
                ],
              ),
            ),
            // Profile Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // User Profile Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.grey300,
                                      border: Border.all(
                                        color: AppColors.grey400,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: _buildProfileImage(user),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // User Name
                                  Text(
                                    user == null
                                        ? 'Guest'
                                        : '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                                              .trim(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // User Info
                                  Text(
                                    user == null
                                        ? 'Not logged in'
                                        : (user['email'] ?? ''),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Edit Profile or Login Button
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (user == null) {
                                      Navigator.pushNamed(context, '/login');
                                      return;
                                    }
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfileScreen(),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      setState(() {});
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.grey700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    user == null ? 'Login' : 'Edit Profile',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Activity Section - Only show for logged-in users
                    if (user != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR ACTIVITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey500,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: List.generate(
                                menuItems.length,
                                (index) => _buildMenuItem(menuItems[index]),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                  ],
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
          final route = NavigationIndexService.routeForIndex(index);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        leading: Icon(
          item.icon,
          color: item.isSignOut ? AppColors.danger : AppColors.black,
          size: 24,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: item.isSignOut ? AppColors.danger : AppColors.black,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: TextStyle(fontSize: 11, color: AppColors.grey600),
        ),
        trailing: item.trailing.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.trailing,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey500,
              ),
        onTap: () async {
          if (item.isSignOut) {
            await AuthService.instance.signOut();
            setState(() {});
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Signed out')));
            return;
          }

          switch (item.title) {
            case 'My Orders':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderScreen()),
              );
              break;
            case 'Addresses':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShippingAddressScreen(),
                ),
              );
              break;
            case 'Payment Methods':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodsScreen(),
                ),
              );
              break;
            case 'Settings':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic>? user) {
    if (user == null) {
      return Icon(Icons.person, size: 40, color: AppColors.grey600);
    }

    final profileImageUrl = user['profileImageUrl']?.toString() ?? '';

    if (profileImageUrl.isEmpty) {
      return Icon(Icons.person, size: 40, color: AppColors.grey600);
    }

    // Check if it's a local file path
    if (profileImageUrl.startsWith('/')) {
      final file = File(profileImageUrl);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, fit: BoxFit.cover, width: 80, height: 80),
        );
      }
    }

    // Fallback to placeholder icon
    return Icon(Icons.person, size: 40, color: AppColors.grey600);
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final bool isSignOut;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.isSignOut = false,
  });
}
