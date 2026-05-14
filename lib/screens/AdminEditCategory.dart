import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminEditCategory extends StatefulWidget {
  final String categoryId;

  const AdminEditCategory({Key? key, required this.categoryId})
    : super(key: key);

  @override
  State<AdminEditCategory> createState() => _AdminEditCategoryState();
}

class _AdminEditCategoryState extends State<AdminEditCategory> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _displayOrderController = TextEditingController();

  File? _categoryImage;
  String _existingImagePath = '';
  bool _showOnHome = false;
  bool _activeStatus = true;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _categoryData;

  @override
  void initState() {
    super.initState();
    _fetchCategoryData();
  }

  Future<void> _fetchCategoryData() async {
    try {
      final doc = await _db
          .collection('categories')
          .doc(widget.categoryId)
          .get();
      if (doc.exists) {
        _categoryData = doc.data();
        _nameController.text = _categoryData?['name']?.toString() ?? '';
        _descController.text = _categoryData?['description']?.toString() ?? '';
        _displayOrderController.text =
            _categoryData?['displayOrder']?.toString() ?? '0';
        _existingImagePath = _categoryData?['image']?.toString() ?? '';
        _showOnHome = _categoryData?['showOnHome'] as bool? ?? false;
        _activeStatus = _categoryData?['isActive'] as bool? ?? true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading category: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickCategoryImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _categoryImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _saveImageLocally(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(
      '${appDir.path}${Platform.pathSeparator}category_images',
    );
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = 'category_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${imagesDir.path}${Platform.pathSeparator}$fileName';
    final savedFile = await imageFile.copy(savedPath);
    return savedFile.path;
  }

  Future<void> _updateCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imagePath = _existingImagePath;
      if (_categoryImage != null) {
        imagePath = await _saveImageLocally(_categoryImage!);
      }

      final displayOrder =
          int.tryParse(_displayOrderController.text.trim()) ?? 0;

      await _db.collection('categories').doc(widget.categoryId).update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'displayOrder': displayOrder,
        'image': imagePath,
        'isActive': _activeStatus,
        'showOnHome': _showOnHome,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating category: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete ${_nameController.text.trim()}?',
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
      if (_existingImagePath.isNotEmpty &&
          !_existingImagePath.startsWith('http')) {
        final file = File(_existingImagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (_categoryImage != null) {
        final file = _categoryImage!;
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _db.collection('categories').doc(widget.categoryId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting category: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(),
                          const SizedBox(height: 28),
                          _buildSectionTitle('BASIC INFORMATION'),
                          const SizedBox(height: 12),
                          _buildBasicInfoCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('DISPLAY SETTINGS'),
                          const SizedBox(height: 12),
                          _buildDisplaySettingsCard(),
                          const SizedBox(height: 24),
                          _buildDeleteSection(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  const AdminBottomNavigationBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.grey600),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Edit Category',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _updateCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickCategoryImage,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB0B8C8), width: 1.5),
              ),
              child: ClipOval(
                child: _categoryImage != null
                    ? Image.file(_categoryImage!, fit: BoxFit.cover)
                    : _existingImagePath.isNotEmpty
                    ? (_existingImagePath.startsWith('http')
                          ? Image.network(
                              _existingImagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_outlined,
                                  size: 38,
                                  color: Color(0xFF9CA3AF),
                                );
                              },
                            )
                          : Image.file(
                              File(_existingImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_outlined,
                                  size: 38,
                                  color: Color(0xFF9CA3AF),
                                );
                              },
                            ))
                    : const Icon(
                        Icons.image_outlined,
                        size: 38,
                        color: Color(0xFF9CA3AF),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Category Image',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Recommended size 512×512 PNG',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _pickCategoryImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.black,
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Change Image',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Category Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g. Smartphones',
          ),
          const SizedBox(height: 16),
          _buildLabel('Description'),
          _buildTextField(
            controller: _descController,
            hint: 'Write a brief description...',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildLabel('Display Order'),
          _buildTextField(
            controller: _displayOrderController,
            hint: '0',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            title: 'Show on Home Page',
            subtitle: 'Feature this category in the main discovery grid',
            value: _showOnHome,
            onChanged: (v) => setState(() => _showOnHome = v),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          _buildToggleRow(
            title: 'Active Status',
            subtitle: 'Enable or disable category visibility',
            value: _activeStatus,
            onChanged: (v) => setState(() => _activeStatus = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteSection() {
    return GestureDetector(
      onTap: _deleteCategory,
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
                  'Delete Category',
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
              'This action cannot be undone.',
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _accentBlue,
          inactiveThumbColor: AppColors.white,
          inactiveTrackColor: const Color(0xFFD1D5DB),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
