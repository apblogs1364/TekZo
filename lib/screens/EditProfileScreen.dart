import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/services/navigation_index_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController dobController;
  late final TextEditingController locationController;

  DateTime? _selectedDob;
  File? _profileImageFile;
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.loggedInUserData;

    nameController = TextEditingController(text: _buildFullName(user));
    emailController = TextEditingController(
      text: user?['email']?.toString() ?? '',
    );
    phoneController = TextEditingController(
      text: user?['phone']?.toString() ?? '',
    );
    _selectedDob = _parseDob(user?['dob']?.toString());
    dobController = TextEditingController(
      text: _formatDobForDisplay(_selectedDob),
    );
    _profileImageUrl = user?['profileImageUrl']?.toString() ?? '';
    locationController = TextEditingController(
      text: user?['location']?.toString() ?? 'Bengaluru, KA',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
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
            onPressed: _saveProfile,
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
    final ImageProvider avatarImage = _profileImageFile != null
        ? FileImage(_profileImageFile!)
        : (_profileImageUrl.isNotEmpty
              ? NetworkImage(_profileImageUrl)
              : const AssetImage('assets/images/user_avatar.png'));

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey200,
                  image: DecorationImage(image: avatarImage, fit: BoxFit.cover),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: linkColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          nameController.text.isEmpty ? 'Guest' : nameController.text,
          style: const TextStyle(
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
          _buildFieldGroup(
            'EMAIL ADDRESS',
            Icons.email_outlined,
            emailController,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildFieldGroup(
            'DATE OF BIRTH',
            Icons.calendar_today_outlined,
            dobController,
            readOnly: true,
            onTap: _pickDob,
          ),
          const SizedBox(height: 24),
          _buildFieldGroup(
            'PHONE NUMBER',
            Icons.phone_outlined,
            phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          _buildFieldGroup(
            'LOCATION',
            Icons.location_on_outlined,
            locationController,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGroup(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
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
            onTap: onTap,
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

  Future<void> _pickDob() async {
    final initialDate =
        _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 18));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDob = picked;
      dobController.text = _formatDobForDisplay(picked);
    });
  }

  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _profileImageFile = File(picked.path);
    });
  }

  Future<void> _saveProfile() async {
    final fullName = nameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    try {
      final nameParts = fullName.split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      await AuthService.instance.updateLoggedInUserProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phoneController.text.trim(),
        dob: _formatDobForDatabase(_selectedDob),
        location: locationController.text.trim(),
        profileImageFile: _profileImageFile,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _buildFullName(Map<String, dynamic>? user) {
    final firstName = user?['firstName']?.toString().trim() ?? '';
    final lastName = user?['lastName']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Anjali Parmar' : fullName;
  }

  DateTime? _parseDob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value.trim());
    } catch (_) {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  String _formatDobForDisplay(DateTime? date) {
    if (date == null) {
      return '';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatDobForDatabase(DateTime? date) {
    if (date == null) {
      return '';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
