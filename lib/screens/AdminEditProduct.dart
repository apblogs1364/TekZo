import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminEditProduct extends StatefulWidget {
  final String productName;
  final String sku;
  final String price;
  final String brand;
  final String category;
  final String description;
  final String stockQty;
  final String discountPrice;

  const AdminEditProduct({
    Key? key,
    required this.productName,
    required this.sku,
    this.price = '',
    this.brand = '',
    this.category = 'Audio',
    this.description = '',
    this.stockQty = '',
    this.discountPrice = '',
  }) : super(key: key);

  @override
  State<AdminEditProduct> createState() => _AdminEditProductState();
}

class _AdminEditProductState extends State<AdminEditProduct> {
  final Color accentBlue = const Color(0xFF4C6FFF);

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _descController;
  late String _selectedCategory;

  final List<String> _categories = [
    'Audio',
    'Smartphones',
    'Laptops',
    'Tablets',
    'Wearables',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _nameController     = TextEditingController(text: widget.productName);
    _skuController      = TextEditingController(text: widget.sku);
    _priceController    = TextEditingController(text: widget.price);
    _discountController = TextEditingController(text: widget.discountPrice);
    _stockController    = TextEditingController(text: widget.stockQty);
    _brandController    = TextEditingController(text: widget.brand);
    _descController     = TextEditingController(text: widget.description);
    _selectedCategory   =
        _categories.contains(widget.category) ? widget.category : _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _descController.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('PRODUCT IMAGES'),
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

  // ── App Bar ──────────────────────────────────────────────────────────────────

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
              'Edit Product',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    return Row(
      children: [
        // Add Image Button
        CustomPaint(
          painter: _DashedRectPainter(
            color: const Color(0xFF9CA3AF),
            strokeWidth: 1.5,
            dashSpace: 5,
            dashWidth: 5,
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xFF88A4E8),
                  size: 28,
                ),
                SizedBox(height: 6),
                Text(
                  'Add Image',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF88A4E8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildImageThumbnail(Icons.headphones, true),
        const SizedBox(width: 12),
        _buildImageThumbnail(Icons.watch, false),
      ],
    );
  }

  Widget _buildImageThumbnail(IconData icon, bool hasDelete) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey200.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: AppColors.white, size: 48)),
        ),
        if (hasDelete)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.white, size: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
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
          _buildLabel('Product Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g. Tekzo Pro Buds 2',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Category'),
                    _buildDropdownField(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Brand'),
                    _buildTextField(
                      controller: _brandController,
                      hint: 'Tekzo',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Description'),
          _buildTextField(
            controller: _descController,
            hint: 'Write a brief product description...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventorySection() {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Price'),
                    _buildTextField(
                      controller: _priceController,
                      hint: '₹ 0.00',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Discount Price'),
                    _buildTextField(
                      controller: _discountController,
                      hint: '₹ Optional',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SKU'),
                    _buildTextField(
                      controller: _skuController,
                      hint: 'TKZ-001',
                      suffixIcon: const Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF9CA3AF),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Stock Quantity'),
                    _buildTextField(
                      controller: _stockController,
                      hint: '0',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('SPECIFICATIONS'),
            GestureDetector(
              onTap: () {},
              child: Text(
                '+ Add Row',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(hint: 'Display'),
              const SizedBox(height: 12),
              _buildTextField(hint: 'Processor'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dashed rect painter ───────────────────────────────────────────────────────

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            pathMetric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
