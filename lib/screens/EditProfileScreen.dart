import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController(text: 'Anjali Parmar');
  final TextEditingController emailController = TextEditingController(text: 'anjali.p@example.com');
  final TextEditingController phoneController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController locationController = TextEditingController(text: 'Bengaluru, KA');

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color linkColor = Color(0xFFA1B0CE);
    const Color primaryText = AppColors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Save logic
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildProfilePicHeader(linkColor),
            const SizedBox(height: 32),
            _buildFormCard(),
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

  Widget _buildProfilePicHeader(Color linkColor) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey200,
                image: const DecorationImage(
                  image: AssetImage('assets/images/user_avatar.png'), // Placeholder
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 50),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: linkColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Anjali Parmar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Change Profile Photo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: linkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldGroup('FULL NAME', Icons.person_outline, nameController),
          const SizedBox(height: 24),
          _buildFieldGroup('EMAIL ADDRESS', Icons.email_outlined, emailController, keyboardType: TextInputType.emailAddress, readOnly: true),
          const SizedBox(height: 24),
          _buildFieldGroup('PHONE NUMBER', Icons.phone_outlined, phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          _buildFieldGroup('LOCATION', Icons.location_on_outlined, locationController),
        ],
      ),
    );
  }

  Widget _buildFieldGroup(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8CA5C1),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: readOnly ? AppColors.grey500 : AppColors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFA1B0CE), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
