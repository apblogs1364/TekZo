import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'package:tekzo/services/auth_service.dart';
import 'package:tekzo/services/admin_navigation_index_service.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController dobController;
  late final TextEditingController locationController;

  DateTime? _selectedDob;
  File? _profileImageFile;
  String _profileImageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final admin = AuthService.instance.loggedInUserData;

    firstNameController = TextEditingController(
      text: admin?['firstName']?.toString() ?? '',
    );
    lastNameController = TextEditingController(
      text: admin?['lastName']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: admin?['email']?.toString() ?? '',
    );
    phoneController = TextEditingController(
      text: admin?['phone']?.toString() ?? '',
    );
    _selectedDob = _parseDob(admin?['dob']?.toString());
    dobController = TextEditingController(
      text: _formatDobForDisplay(_selectedDob),
    );
    _profileImageUrl = admin?['profileImageUrl']?.toString() ?? '';
    locationController = TextEditingController(
      text: admin?['location']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    locationController.dispose();
    super.dispose();
  }

  DateTime? _parseDob(String? dobString) {
    if (dobString == null || dobString.isEmpty) return null;
    try {
      return DateTime.parse(dobString);
    } catch (e) {
      return null;
    }
  }

  String _formatDobForDisplay(DateTime? dob) {
    if (dob == null) return '';
    return '${dob.day}/${dob.month}/${dob.year}';
  }

  String _formatDobForStorage(DateTime? dob) {
    if (dob == null) return '';
    return '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDob() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
        dobController.text = _formatDobForDisplay(pickedDate);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.updateLoggedInUserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        dob: _formatDobForStorage(_selectedDob),
        location: locationController.text.trim(),
        profileImageFile: _profileImageFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Admin Profile',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildProfileImageSection(),
            const SizedBox(height: 28),
            _buildFormFields(),
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigationBar(
        key: ValueKey(AdminNavigationIndexService.currentIndex),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final ImageProvider avatarImage = _profileImageFile != null
        ? FileImage(_profileImageFile!)
        : (_profileImageUrl.isNotEmpty && _profileImageUrl.startsWith('/')
              ? FileImage(File(_profileImageUrl))
              : const AssetImage('assets/images/user_avatar.png'));

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey200,
                    image: DecorationImage(
                      image: avatarImage,
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -8,
                bottom: -8,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: AppColors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to change profile photo',
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              'First Name',
              firstNameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Last Name',
              lastNameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Email',
              emailController,
              Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildFormField('Phone', phoneController, Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildFormField(
              'Location',
              locationController,
              Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            filled: true,
            fillColor: enabled ? AppColors.grey50 : AppColors.grey100,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDob,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(10),
              color: AppColors.grey50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dobController.text.isEmpty
                      ? 'Select Date'
                      : dobController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: dobController.text.isEmpty
                        ? AppColors.grey400
                        : AppColors.black,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.grey400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
