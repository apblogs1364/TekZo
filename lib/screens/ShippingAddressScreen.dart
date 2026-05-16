import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:tekzo/services/navigation_index_service.dart';
import 'package:tekzo/services/address_book_service.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({Key? key}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  List<Address> get addresses => AddressBookService.addresses;

  void _showAddAddressDialog() {
    final labelController = TextEditingController();
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: labelController,
                label: 'Address Label',
                hint: 'e.g., Home, Office',
              ),
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
              ),
              _buildTextField(
                controller: streetController,
                label: 'Street Address',
                hint: 'Enter street address',
              ),
              _buildTextField(
                controller: cityController,
                label: 'City',
                hint: 'Enter city',
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: stateController,
                      label: 'State',
                      hint: 'State',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: zipController,
                      label: 'Zip Code',
                      hint: 'Zip',
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (labelController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  streetController.text.isNotEmpty &&
                  cityController.text.isNotEmpty &&
                  stateController.text.isNotEmpty &&
                  zipController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                setState(() {
                  AddressBookService.add(
                    Address(
                      id: DateTime.now().toString(),
                      label: labelController.text,
                      name: nameController.text,
                      street: streetController.text,
                      city: cityController.text,
                      state: stateController.text,
                      zip: zipController.text,
                      phone: phoneController.text,
                      isDefault: false,
                    ),
                  );
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text(
              'Add Address',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint),
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
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(Address address, int index) {
    final labelController = TextEditingController(text: address.label);
    final nameController = TextEditingController(text: address.name);
    final streetController = TextEditingController(text: address.street);
    final cityController = TextEditingController(text: address.city);
    final stateController = TextEditingController(text: address.state);
    final zipController = TextEditingController(text: address.zip);
    final phoneController = TextEditingController(text: address.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: labelController,
                label: 'Address Label',
                hint: 'e.g., Home, Office',
              ),
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
              ),
              _buildTextField(
                controller: streetController,
                label: 'Street Address',
                hint: 'Enter street address',
              ),
              _buildTextField(
                controller: cityController,
                label: 'City',
                hint: 'Enter city',
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: stateController,
                      label: 'State',
                      hint: 'State',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: zipController,
                      label: 'Zip Code',
                      hint: 'Zip',
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (labelController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  streetController.text.isNotEmpty &&
                  cityController.text.isNotEmpty &&
                  stateController.text.isNotEmpty &&
                  zipController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                setState(() {
                  addresses[index] = Address(
                    id: address.id,
                    label: labelController.text,
                    name: nameController.text,
                    street: streetController.text,
                    city: cityController.text,
                    state: stateController.text,
                    zip: zipController.text,
                    phone: phoneController.text,
                    isDefault: address.isDefault,
                  );
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text(
              'Save Changes',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                AddressBookService.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(int index) {
    setState(() {
      AddressBookService.setDefault(addresses[index].id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Address Card
            GestureDetector(
              onTap: _showAddAddressDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.grey300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.background,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryExtraLight,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Add New Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Save a new delivery location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Saved Addresses Title
            const Text(
              'SAVED ADDRESSES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Addresses List
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with label and default badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                address.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Name
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Street
                          Text(
                            address.street,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // City, State, Zip
                          Text(
                            '${address.city}, ${address.state} ${address.zip}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Phone
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                address.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    if (!address.isDefault) {
                                      _setAsDefault(index);
                                    }
                                  },
                                  icon: Icon(
                                    address.isDefault
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                  ),
                                  label: Text(
                                    address.isDefault
                                        ? 'Default'
                                        : 'Set Default',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.grey300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Delete Button
                              IconButton(
                                onPressed: () => _deleteAddress(index),
                                icon: const Icon(Icons.delete_outline),
                                iconSize: 20,
                                color: AppColors.danger,
                                constraints: const BoxConstraints(
                                  minHeight: 40,
                                  minWidth: 40,
                                ),
                                style: IconButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.grey300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
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
}
