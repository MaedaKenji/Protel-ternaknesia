import 'package:flutter/material.dart';

class UserRole with ChangeNotifier {
  String _role = '';
  String _email = '';
  String _name = '';
  String _phoneNumber = '';
  String _cageLocation = '';
  bool _isLoggedIn = false;

  String get role => _role;
  String get email => _email;
  String get name => _name;
  bool get isLoggedIn => _isLoggedIn;
  String get phoneNumber => _phoneNumber;
  String get cageLocation => _cageLocation;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }

  void setEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setPhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    notifyListeners();
  }

  void setCageLocation(String newCageLocation) {
    _cageLocation = newCageLocation;
    notifyListeners();
  }

  void login(String newEmail, String newRole, String newName, String newPhoneNumber, String newCageLocation) {
    _email = newEmail;
    _role = newRole;
    _name = newName;
    _phoneNumber = newPhoneNumber;
    _cageLocation = newCageLocation;
    assignIsLoggedIn();
    notifyListeners();
  }

  void assignIsLoggedIn() {
    if (_email.isNotEmpty && _role.isNotEmpty && _name.isNotEmpty && _phoneNumber.isNotEmpty && _cageLocation.isNotEmpty) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }


  void logout() {
    _role = '';
    _email = '';
    _name = '';
    _phoneNumber = '';
    _cageLocation = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
