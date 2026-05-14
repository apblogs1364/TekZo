import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminAddProduct extends StatefulWidget {
  const AdminAddProduct({Key? key}) : super(key: key);

  @override
  State<AdminAddProduct> createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Color accentBlue = const Color(0xFF4C6FFF);

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController descriptionController;
  late TextEditingController shortDescriptionController;
  late TextEditingController priceController;
  late TextEditingController discountPercentageController;
  late TextEditingController stockController;
  late TextEditingController colorController;
  late TextEditingController ratingController;
  late TextEditingController totalReviewsController;

  String? selectedCategoryId;
  List<Map<String, String>> categories = [];
  File? _productImage;
  bool isFeatured = false;
  bool isActive = true;
  List<Map<String, String>> specifications = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    brandController = TextEditingController();
    descriptionController = TextEditingController();
    shortDescriptionController = TextEditingController();
    priceController = TextEditingController();
    discountPercentageController = TextEditingController();
    stockController = TextEditingController();
    colorController = TextEditingController();
    ratingController = TextEditingController();
    totalReviewsController = TextEditingController();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      setState(() {
        categories = snapshot.docs.map((doc) {
          return {'id': doc.id, 'name': doc['name']?.toString() ?? 'Unknown'};
        }).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _pickProductImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _productImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _saveImageLocally(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(
        '${appDir.path}${Platform.pathSeparator}product_images',
      );
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_$timestamp.jpg';
      final savedPath = '${imagesDir.path}${Platform.pathSeparator}$fileName';

      final savedFile = await imageFile.copy(savedPath);
      print('Image saved locally: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      print('Local save error: $e');
      rethrow;
    }
  }

  void _addSpecificationRow() {
    showDialog(
      context: context,
      builder: (context) {
        final fieldController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Specification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fieldController,
                decoration: const InputDecoration(labelText: 'Field Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (fieldController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(() {
                    specifications.add({
                      'field': fieldController.text,
                      'value': valueController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String productImageUrl = '';
      if (_productImage != null) {
        productImageUrl = await _saveImageLocally(_productImage!);
      }

      final finalPrice =
          int.parse(priceController.text) -
          (int.parse(priceController.text) *
              (int.tryParse(discountPercentageController.text) ?? 0) ~/
              100);

      final specMap = <String, String>{};
      for (var spec in specifications) {
        specMap[spec['field']!] = spec['value']!;
      }

      await _db.collection('products').add({
        'name': nameController.text,
        'brand': brandController.text,
        'description': descriptionController.text,
        'shortDescription': shortDescriptionController.text,
        'price': int.parse(priceController.text),
        'finalPrice': finalPrice,
        'discountPercentage':
            int.tryParse(discountPercentageController.text) ?? 0,
        'stock': int.tryParse(stockController.text) ?? 0,
        'color': colorController.text,
        'categoryId': selectedCategoryId,
        'rating': double.tryParse(ratingController.text) ?? 0.0,
        'totalReviews': int.tryParse(totalReviewsController.text) ?? 0,
        'productImage': productImageUrl,
        'isFeatured': isFeatured,
        'isActive': isActive,
        'specifications': specMap,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    shortDescriptionController.dispose();
    priceController.dispose();
    discountPercentageController.dispose();
    stockController.dispose();
    colorController.dispose();
    ratingController.dispose();
    totalReviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
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
                    _buildSectionTitle('PRODUCT IMAGE'),
                    const SizedBox(height: 12),
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('BASIC INFORMATION'),
                    const SizedBox(height: 12),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('PRICING & INVENTORY'),
                    const SizedBox(height: 12),
                    _buildPricingInventorySection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('SPECIFICATIONS'),
                    const SizedBox(height: 12),
                    _buildSpecificationsSection(),
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
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.grey600),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Add Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
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
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickProductImage,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: _productImage == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: accentBlue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to add product image',
                      style: TextStyle(color: AppColors.grey600, fontSize: 12),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_productImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextField('Product Name*', nameController),
        const SizedBox(height: 12),
        _buildTextField('Brand', brandController),
        const SizedBox(height: 12),
        _buildCategoryDropdown(),
        const SizedBox(height: 12),
        _buildTextField('Color', colorController),
        const SizedBox(height: 12),
        _buildTextField('Short Description', shortDescriptionController),
        const SizedBox(height: 12),
        _buildTextField('Description', descriptionController, maxLines: 3),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: isFeatured,
              onChanged: (value) => setState(() => isFeatured = value ?? false),
            ),
            const Text('Featured Product'),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingInventorySection() {
    return Column(
      children: [
        _buildTextField(
          'Price*',
          priceController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Discount %',
          discountPercentageController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Stock Quantity',
          stockController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Rating',
          ratingController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Total Reviews',
          totalReviewsController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection() {
    return Column(
      children: [
        ...specifications.asMap().entries.map((entry) {
          final idx = entry.key;
          final spec = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec['field']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        spec['value']!,
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => specifications.removeAt(idx)),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                    size: 18,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _addSpecificationRow,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: accentBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Add Specification',
                  style: TextStyle(color: accentBlue, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      hint: const Text('Select Category*'),
      items: categories
          .map(
            (cat) => DropdownMenuItem(
              value: cat['id'],
              child: Text(cat['name'] ?? 'Unknown'),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => selectedCategoryId = value),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
