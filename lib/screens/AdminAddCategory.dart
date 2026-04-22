import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminAddCategory extends StatefulWidget {
  const AdminAddCategory({Key? key}) : super(key: key);

  @override
  State<AdminAddCategory> createState() => _AdminAddCategoryState();
}

class _AdminAddCategoryState extends State<AdminAddCategory> {
  static const Color _accentBlue = Color(0xFF4C6FFF);

  // Controllers
  final TextEditingController _nameController =
      TextEditingController(text: 'Smartphones');
  final TextEditingController _descController =
      TextEditingController(text: 'Latest generation mobile devices and accessories.');

  bool _showOnHome = false;
  bool _activeStatus = false;

  @override
  void dispose() {
    _nameController.dispose();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Icon section ────────────────────────────────────────
                    _buildIconSection(),
                    const SizedBox(height: 28),

                    // ── Basic Information ───────────────────────────────────
                    _buildSectionTitle('BASIC INFORMATION'),
                    const SizedBox(height: 12),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 24),

                    // ── Display Settings ────────────────────────────────────
                    _buildSectionTitle('DISPLAY SETTINGS'),
                    const SizedBox(height: 12),
                    _buildDisplaySettingsCard(),
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
            child:
                const Icon(Icons.arrow_back, color: AppColors.grey600),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Add Category',
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
                const SnackBar(content: Text('Category saved!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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

  // ── Section title ────────────────────────────────────────────────────────────

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

  // ── Icon section ─────────────────────────────────────────────────────────────

  Widget _buildIconSection() {
    return Center(
      child: Column(
        children: [
          // Dashed circle with image placeholder
          CustomPaint(
            painter: _DashedCirclePainter(
              color: const Color(0xFFB0B8C8),
              strokeWidth: 1.5,
              dashWidth: 6,
              dashSpace: 5,
            ),
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 38,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Category Icon',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Recommended size 512×512 PNG',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Icon picker coming soon')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.black,
              side:
                  const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Change Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Basic Information card ───────────────────────────────────────────────────

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
          // Category Name
          _buildLabel('Category Name'),
          _buildTextField(controller: _nameController, hint: 'e.g. Smartphones'),
          const SizedBox(height: 16),

          // Description
          _buildLabel('Description'),
          _buildTextField(
            controller: _descController,
            hint: 'Write a brief description...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ── Display Settings card ────────────────────────────────────────────────────

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
          // Show on Home Page
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
          // Active Status
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

  // ── Helpers ──────────────────────────────────────────────────────────────────

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
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffixIcon,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
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

// ── Dashed circle painter ─────────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const _DashedCirclePainter({
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

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final circumference = 2 * 3.14159265 * radius;
    final dashCount =
        (circumference / (dashWidth + dashSpace)).floor();
    final actualDash = circumference / dashCount;
    final dashAngle = (actualDash * dashWidth / (dashWidth + dashSpace)) /
        radius;
    final gapAngle = (actualDash * dashSpace / (dashWidth + dashSpace)) /
        radius;

    double startAngle = -3.14159265 / 2;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
