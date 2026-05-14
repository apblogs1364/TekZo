import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailsScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Color accentBlue = const Color(0xFF4C6FFF);

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController genderController;
  late final TextEditingController dobController;
  late final TextEditingController locationController;
  late final TextEditingController passwordController;
  late final TextEditingController roleController;
  late final TextEditingController profileImageUrlController;
  late final TextEditingController createdAtController;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isActive = true;
  String _profileImageUrl = '';
  String _userInitials = 'U';

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    genderController = TextEditingController();
    dobController = TextEditingController();
    locationController = TextEditingController();
    passwordController = TextEditingController();
    roleController = TextEditingController();
    profileImageUrlController = TextEditingController();
    createdAtController = TextEditingController();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final doc = await _db.collection('users').doc(widget.userId).get();
      final data = doc.data();
      if (data != null) {
        firstNameController.text = data['firstName']?.toString() ?? '';
        lastNameController.text = data['lastName']?.toString() ?? '';
        emailController.text = data['email']?.toString() ?? '';
        phoneController.text = data['phone']?.toString() ?? '';
        genderController.text = data['gender']?.toString() ?? '';
        dobController.text = data['dob']?.toString() ?? '';
        locationController.text = data['location']?.toString() ?? '';
        passwordController.text = data['password']?.toString() ?? '';
        roleController.text = data['role']?.toString() ?? 'customer';
        profileImageUrlController.text =
            data['profileImageUrl']?.toString() ?? '';
        createdAtController.text = _formatCreatedAt(data['createdAt']);
        _profileImageUrl = profileImageUrlController.text;
        _isActive = data['isActive'] as bool? ?? true;
        _userInitials = _buildInitials(
          firstNameController.text,
          lastNameController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    dobController.dispose();
    locationController.dispose();
    passwordController.dispose();
    roleController.dispose();
    profileImageUrlController.dispose();
    createdAtController.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    setState(() => _isSaving = true);
    try {
      await _db.collection('users').doc(widget.userId).update({
        'isActive': _isActive,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User status updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating user: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this user account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (_profileImageUrl.isNotEmpty && !_profileImageUrl.startsWith('http')) {
        final file = File(_profileImageUrl);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _db.collection('users').doc(widget.userId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User account deleted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildForm(),
                    ),
                  ),
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
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'User Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildProfileImage(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentBlue,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _fullName.isNotEmpty ? _fullName : 'User Name',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'User ID: ${widget.userId}',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          title: 'GENERAL INFORMATION',
          children: [
            _buildTextField(
              label: 'First Name',
              controller: firstNameController,
            ),
            const SizedBox(height: 16),
            _buildTextField(label: 'Last Name', controller: lastNameController),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email Address',
              controller: emailController,
            ),
            const SizedBox(height: 16),
            _buildTextField(label: 'Phone Number', controller: phoneController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Gender', controller: genderController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Date of Birth', controller: dobController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Location', controller: locationController),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'ACCOUNT DETAILS',
          children: [
            _buildTextField(label: 'Role', controller: roleController),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Password',
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Profile Image URL',
              controller: profileImageUrlController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Created At',
              controller: createdAtController,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Allow user to login to the portal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: accentBlue,
                inactiveThumbColor: AppColors.grey300,
                inactiveTrackColor: AppColors.grey200,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _deleteAccount,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone. All data will be wiped.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImageUrl.isNotEmpty) {
      if (_profileImageUrl.startsWith('http')) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4A574),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey300.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              _profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildInitialsAvatar(),
            ),
          ),
        );
      }

      final file = File(_profileImageUrl);
      if (file.existsSync()) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4A574),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey300.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildInitialsAvatar(),
            ),
          ),
        );
      }
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD4A574),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _userInitials,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  String get _fullName =>
      '${firstNameController.text} ${lastNameController.text}'.trim();

  String _buildInitials(String firstName, String lastName) {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty && last.isEmpty) return 'U';
    final firstInitial = first.isNotEmpty ? first.substring(0, 1) : '';
    final lastInitial = last.isNotEmpty ? last.substring(0, 1) : '';
    final initials = '$firstInitial$lastInitial'.trim();
    return initials.isEmpty ? 'U' : initials.toUpperCase();
  }

  String _formatCreatedAt(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final day = date.day.toString().padLeft(2, '0');
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
      return '$day ${months[date.month - 1]} ${date.year}';
    }
    if (value is DateTime) {
      final day = value.day.toString().padLeft(2, '0');
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
      return '$day ${months[value.month - 1]} ${value.year}';
    }
    if (value is String && value.isNotEmpty) return value;
    return 'N/A';
  }
}
