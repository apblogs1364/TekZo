class Address {
  String id;
  String label;
  String name;
  String street;
  String city;
  String state;
  String zip;
  String phone;
  bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.phone,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? label,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zip,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => '$street\n$city, $state $zip';
}

class AddressBookService {
  AddressBookService._();

  static final List<Address> addresses = [
    Address(
      id: '1',
      label: 'Home',
      name: 'Johnathan Anderson',
      street: '123 Unicorn Valley Drive, Suite 400',
      city: 'Palo Alto',
      state: 'CA',
      zip: '94301',
      phone: '+1 (555) 0123 4567',
      isDefault: true,
    ),
    Address(
      id: '2',
      label: 'Office',
      name: 'Johnathan Anderson',
      street: '800 Infinite Loop, Building 4',
      city: 'Cupertino',
      state: 'CA',
      zip: '95014',
      phone: '+1 (555) 9876 5432',
      isDefault: false,
    ),
    Address(
      id: '3',
      label: 'Parents',
      name: 'Mary Anderson',
      street: '42nd Maple Avenue, Apartment 12B',
      city: 'New York',
      state: 'NY',
      zip: '10001',
      phone: '+1 (212) 555 0199',
      isDefault: false,
    ),
  ];

  static Address? get selectedAddress {
    if (addresses.isEmpty) {
      return null;
    }

    return addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.first,
    );
  }

  static void setDefault(String id) {
    for (final address in addresses) {
      address.isDefault = address.id == id;
    }
  }

  static void add(Address address) {
    addresses.add(address);
  }

  static void removeAt(int index) {
    addresses.removeAt(index);
    if (addresses.isNotEmpty &&
        !addresses.any((address) => address.isDefault)) {
      addresses.first.isDefault = true;
    }
  }
}
