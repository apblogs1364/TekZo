import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // User Name
                                  const Text(
                                    'Julian Vance',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // User Info
                                  Text(
                                    'julian.vance@email.com',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Edit Profile Button
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.grey700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
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
                    // Activity Section
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
          setState(() {});

          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/products');
              break;
            case 2:
              Navigator.pushNamed(context, '/wishlist');
              break;
            case 3:
              Navigator.pushNamed(context, '/orders');
              break;
            case 4:
              // Already on Profile
              break;
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
        onTap: () {},
      ),
    );
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
