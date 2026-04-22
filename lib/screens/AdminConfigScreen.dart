import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import 'AdminCustomerCareScreen.dart';

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({Key? key}) : super(key: key);

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);

  // General Settings
  bool _maintenanceMode = false;
  String _selectedCurrency = 'INR (₹)';
  final TextEditingController _appNameController =
      TextEditingController(text: 'Tekzo Admin');

  // App Branding — primary color (starts from theme)
  Color _primaryColor = AppColors.primary;

  // System Preferences
  String _selectedLanguage = 'English (India)';
  String _selectedTimezone = 'IST (UTC+05:30)';

  final List<String> _currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'];
  final List<String> _languages = [
    'English (India)',
    'English (US)',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
  ];
  final List<String> _timezones = [
    'IST (UTC+05:30)',
    'UTC+00:00',
    'UTC-05:00',
    'UTC+08:00',
  ];

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  String _toHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  void _showColorPicker() {
    const presets = [
      Color(0xFF6B7280), // AppColors.primary (grey)
      Color(0xFF4C6FFF), // accent blue
      Color(0xFF7C3AED), // violet
      Color(0xFF0EA5E9), // sky blue
      Color(0xFF10B981), // emerald
      Color(0xFFF59E0B), // amber
      Color(0xFFEF4444), // red
      Color(0xFFEC4899), // pink
      Color(0xFF14B8A6), // teal
      Color(0xFFF97316), // orange
      Color(0xFF6366F1), // indigo
      Color(0xFF22C55E), // green
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Primary Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: presets.map((color) {
                  final isSelected = _primaryColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _primaryColor = color);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: AppColors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('GENERAL SETTINGS'),
                    const SizedBox(height: 8),
                    _buildGeneralSettingsCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('SYSTEM PREFERENCES'),
                    const SizedBox(height: 8),
                    _buildSystemPreferencesCard(),
                    const SizedBox(height: 20),
                    _buildCustomerCareButton(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('APP BRANDING'),
                    const SizedBox(height: 8),
                    _buildAppBrandingCard(),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                    const SizedBox(height: 16),
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

  // ── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                color: AppColors.black, size: 22),
          ),
          const SizedBox(width: 16),
          const Text(
            'Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _accentBlue,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── General Settings Card ───────────────────────────────────────────────────

  Widget _buildGeneralSettingsCard() {
    return _whiteCard(
      child: Column(
        children: [
          // App Name
          _settingsRow(
            icon: Icons.article_outlined,
            label: 'App Name',
            trailing: SizedBox(
              width: 130,
              child: TextField(
                controller: _appNameController,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          _divider(),

          // Maintenance Mode
          _settingsRow(
            icon: Icons.people_outline,
            label: 'Maintenance Mode',
            trailing: Switch(
              value: _maintenanceMode,
              onChanged: (val) => setState(() => _maintenanceMode = val),
              activeColor: _accentBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          _divider(),

          // Currency
          _settingsRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Currency',
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrency,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: _accentBlue, size: 18),
                style: const TextStyle(
                  fontSize: 13,
                  color: _accentBlue,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
                items: _currencies
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _accentBlue,
                                fontWeight: FontWeight.w600,
                              )),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── System Preferences Card ─────────────────────────────────────────────────

  Widget _buildSystemPreferencesCard() {
    return _whiteCard(
      child: Column(
        children: [
          // Default Language
          _settingsRow(
            icon: Icons.language_outlined,
            label: 'Default Language',
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.grey400, size: 18),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey600,
                              )),
                        ))
                    .toList(),
              ),
            ),
          ),
          _divider(),

          // Timezone
          _settingsRow(
            icon: Icons.access_time_outlined,
            label: 'Timezone',
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTimezone,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.grey400, size: 18),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTimezone = val);
                },
                items: _timezones
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey600,
                              )),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Customer Care Button ────────────────────────────────────────────────────

  Widget _buildCustomerCareButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminCustomerCareScreen(),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF4C6FFF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headset_mic_outlined,
                color: Color(0xFF4C6FFF), size: 20),
            SizedBox(width: 10),
            Text(
              'Customer Care',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C6FFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Branding Card ───────────────────────────────────────────────────────

  Widget _buildAppBrandingCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Color
          GestureDetector(
            onTap: _showColorPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.palette_outlined,
                      color: AppColors.grey500, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Primary Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    _toHex(_primaryColor),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.grey400, size: 18),
                ],
              ),
            ),
          ),
          _divider(),

          // App Logo
          const Text(
            'App Logo Preview',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logo upload coming soon')),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.grey200, width: 1),
                  ),
                  child: const Icon(Icons.upload_file_outlined,
                      color: AppColors.grey400, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload New Logo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'PNG, SVG or JPG (Max 2MB)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Save Button ─────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Configuration saved!'),
            backgroundColor: Color(0xFF4C6FFF)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _accentBlue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Text(
          'Save All Changes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────────

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
}
