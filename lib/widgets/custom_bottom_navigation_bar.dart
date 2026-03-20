import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _localCurrentIndex;

  final List<BottomNavItem> navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.grid_3x3_outlined,
      selectedIcon: Icons.grid_3x3,
      label: 'Products',
    ),
    BottomNavItem(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Wishlist',
    ),
    BottomNavItem(
      icon: Icons.card_giftcard_outlined,
      selectedIcon: Icons.card_giftcard,
      label: 'Orders',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _localCurrentIndex = widget.currentIndex;
    // Listen to changes from NavigationIndexService
    NavigationIndexService.instance.addListener(_onNavigationIndexChanged);
  }

  @override
  void dispose() {
    NavigationIndexService.instance.removeListener(_onNavigationIndexChanged);
    super.dispose();
  }

  void _onNavigationIndexChanged() {
    setState(() {
      _localCurrentIndex = NavigationIndexService.currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey300, width: 1)),
        color: AppColors.white,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _localCurrentIndex,
        onTap: widget.onTap,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grey400,
        ),
        items: navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon, size: 24),
                activeIcon: Icon(item.selectedIcon, size: 24),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
