import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/admin_navigation_index_service.dart';

class AdminBottomNavigationBar extends StatefulWidget {
  const AdminBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<AdminBottomNavigationBar> createState() => _AdminBottomNavigationBarState();
}

class _AdminBottomNavigationBarState extends State<AdminBottomNavigationBar> {
  static const _items = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dash'),
    _NavItem(icon: Icons.inventory_2_outlined, label: 'Items'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
    _NavItem(icon: Icons.people_outline, label: 'Users'),
    _NavItem(icon: Icons.settings_outlined, label: 'Config'),
  ];

  void _onTap(int index) {
    if (index == AdminNavigationIndexService.currentIndex) return;

    // Determine the target route for the tapped tab
    String targetRoute;
    switch (index) {
      case 0:
        targetRoute = '/admin';
        break;
      case 1:
        targetRoute = '/admin/products';
        break;
      case 2:
        targetRoute = '/admin/orders';
        break;
      case 3:
        targetRoute = '/admin/users';
        break;
      case 4:
        targetRoute = '/admin/config';
        break;
      default:
        targetRoute = '/admin';
    }

    // Avoid pushing the same route we're already on
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == targetRoute) return;

    AdminNavigationIndexService.setIndex(index);
    setState(() {});

    // Use pushNamed (not pushReplacementNamed) so the back stack is preserved.
    // The user can now press Back to return to the previously opened admin screen.
    Navigator.pushNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AdminNavigationIndexService.currentIndex;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey300, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => _onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.grey400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
