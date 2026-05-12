import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    const Color sectionTitleColor = Color(0xFFA1B0CE);
    const Color linkColor = Color(0xFF6B7B8F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('ACCOUNT', sectionTitleColor),
            const SizedBox(height: 12),
            _buildSectionCard([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                linkColor: linkColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping Addresses',
                linkColor: linkColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                linkColor: linkColor,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('NOTIFICATIONS', sectionTitleColor),
            const SizedBox(height: 12),
            _buildSectionCard([
              _buildSettingsTile(
                icon: Icons.notifications_none,
                title: 'Push Notifications',
                linkColor: linkColor,
                trailing: Switch(
                  value: pushNotifications,
                  onChanged: (val) {
                    setState(() {
                      pushNotifications = val;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF8CA5C1),
                ),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: 'Email Preferences',
                linkColor: linkColor,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('SECURITY & PRIVACY', sectionTitleColor),
            const SizedBox(height: 12),
            _buildSectionCard([
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                linkColor: linkColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                linkColor: linkColor,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('SUPPORT', sectionTitleColor),
            const SizedBox(height: 12),
            _buildSectionCard([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                linkColor: linkColor,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.support_agent_outlined,
                title: 'Contact Us',
                linkColor: linkColor,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('APP INFO', sectionTitleColor),
            const SizedBox(height: 12),
            _buildSectionCard([
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                linkColor: linkColor,
                trailing: const Text(
                  '1.0.4',
                  style: TextStyle(
                    color: Color(0xFFA1B0CE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                linkColor: linkColor,
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(sectionTitleColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: NavigationIndexService.currentIndex,
        onTap: (index) {
          NavigationIndexService.setIndex(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey200,
            image: const DecorationImage(
              image: AssetImage('assets/images/user_avatar.png'), // Placeholder
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Anjali Parmar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.black87,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'View Profile',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFA1B0CE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color linkColor,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: linkColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.black87,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: linkColor.withOpacity(0.4),
          ),
      onTap: trailing is Switch ? null : () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton(Color textColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Add explicit logout logic if needed
        },
        icon: Icon(Icons.logout, color: textColor, size: 20),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
