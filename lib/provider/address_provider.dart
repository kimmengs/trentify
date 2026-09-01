import 'package:flutter/foundation.dart';
import 'package:trentify/model/address.dart';

class AddressProvider extends ChangeNotifier {
  static final AddressProvider instance = AddressProvider._();
  AddressProvider._();

  factory AddressProvider() => instance;

  final List<Address> _addresses = [
    const Address(
      id: 'addr_1',
      label: 'Home',
      fullName: 'Alex Rivera',
      phone: '+1 (555) 234-5678',
      line1: '742 Evergreen Terrace, Beverly Hills, CA 90210',
      isMain: true,
    ),
    const Address(
      id: 'addr_2',
      label: 'Design Studio',
      fullName: 'Alex Rivera',
      phone: '+1 (555) 876-5432',
      line1: '450 Haute Couture Ave, Suite 800, New York, NY 10018',
      isMain: false,
    ),
  ];

  String? _selectedAddressId;

  List<Address> get addresses => List.unmodifiable(_addresses);

  Address? get primaryAddress {
    try {
      return _addresses.firstWhere((a) => a.isMain);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Address? get selectedAddress {
    if (_selectedAddressId != null) {
      try {
        return _addresses.firstWhere((a) => a.id == _selectedAddressId);
      } catch (_) {}
    }
    return primaryAddress;
  }

  String get selectedAddressId => selectedAddress?.id ?? (_addresses.isNotEmpty ? _addresses.first.id : '');

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void addAddress(Address address) {
    if (address.isMain) {
      _demoteAllMain();
    } else if (_addresses.isEmpty) {
      address = Address(
        id: address.id,
        label: address.label,
        fullName: address.fullName,
        phone: address.phone,
        line1: address.line1,
        isMain: true,
      );
    }
    _addresses.add(address);
    _selectedAddressId = address.id;
    notifyListeners();
  }

  void updateAddress(Address updated) {
    final idx = _addresses.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      if (updated.isMain) {
        _demoteAllMain();
      }
      _addresses[idx] = updated;
      notifyListeners();
    }
  }

  void setPrimary(String id) {
    _demoteAllMain();
    final idx = _addresses.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final old = _addresses[idx];
      _addresses[idx] = Address(
        id: old.id,
        label: old.label,
        fullName: old.fullName,
        phone: old.phone,
        line1: old.line1,
        isMain: true,
      );
      _selectedAddressId = id;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    final toDelete = _addresses.firstWhere((a) => a.id == id, orElse: () => _addresses.first);
    final wasMain = toDelete.isMain;
    _addresses.removeWhere((a) => a.id == id);

    if (wasMain && _addresses.isNotEmpty) {
      final first = _addresses.first;
      _addresses[0] = Address(
        id: first.id,
        label: first.label,
        fullName: first.fullName,
        phone: first.phone,
        line1: first.line1,
        isMain: true,
      );
    }

    if (_selectedAddressId == id) {
      _selectedAddressId = primaryAddress?.id;
    }
    notifyListeners();
  }

  void _demoteAllMain() {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isMain) {
        final a = _addresses[i];
        _addresses[i] = Address(
          id: a.id,
          label: a.label,
          fullName: a.fullName,
          phone: a.phone,
          line1: a.line1,
          isMain: false,
        );
      }
    }
  }
}
