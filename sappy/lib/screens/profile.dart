// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:sappy/components/logout_dialog.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:sappy/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil userRole di dalam build() karena context sudah tersedia
    final userRole = Provider.of<UserRole>(context);

    // Set nilai default controller hanya jika belum ada nilai sebelumnya
    if (_nameController.text.isEmpty && userRole.name.isNotEmpty) {
      _nameController.text = userRole.name;
    }
    if (_emailController.text.isEmpty && userRole.email.isNotEmpty) {
      _emailController.text = userRole.email;
    }
    if (_phoneController.text.isEmpty && userRole.phoneNumber.isNotEmpty) {
      _phoneController.text = userRole.phoneNumber;
    }
    if (_roleController.text.isEmpty && userRole.role.isNotEmpty) {
      _roleController.text = userRole.role;
    }
    if (_locationController.text.isEmpty && userRole.cageLocation.isNotEmpty) {
      _locationController.text = userRole.cageLocation;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 24),
            onPressed: _saveProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                children: [
                  CircleAvatar(
                      radius: 60,
                      backgroundImage: (userRole.role == 'user'
                          ? const AssetImage('assets/images/farmer.png')
                          : userRole.role == 'admin'
                              ? const AssetImage('assets/images/admin.png')
                              : const AssetImage('assets/images/doctor.png'))),
                  const SizedBox(height: 10),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.work,
                    label: 'Role',
                    controller: _roleController,
                    readOnly: true,
                  ),
                  if (userRole.role == 'user') ...[
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Lokasi Kandang',
                      controller: _locationController,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutDialog(
          title: 'Logout',
          content: 'Are you sure you want to logout?',
          onConfirm: () {
            final userRole = Provider.of<UserRole>(context, listen: false);
            userRole.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: const LoginScreen(),
                  );
                },
              ),
              (Route<dynamic> route) => false, // Remove all routes
            );
          },
        );
      },
    );
  }

  bool? readOnly;
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool readOnly = false, // Default value is false
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFFC35804), size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: controller,
                readOnly: readOnly, // Set readOnly property
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 1),
                  border: InputBorder.none,
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^(?:\+62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _saveProfile() async {
    String _email = _emailController.text;
    String _phone = _phoneController.text;
    String _location = _locationController.text;
    final userRole = Provider.of<UserRole>(context, listen: false);
    

    if (!_isValidEmail(_email)) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Email tidak valid',
      );
      return;
    }

    if (!_isValidPhone(_phone)) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Nomor telepon tidak valid',
      );
      return;
    }

    if (userRole.role == 'user') {
      if (_location.isEmpty) {
        ShowResultDialog.show(
          context,
          false,
          customMessage: 'Lokasi kandang tidak boleh kosong',
        );
        return;
      }
    }

    try {
      final url =
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/users/updateprofile';

      Map data = {
        'email': _email,
        'phone': _phone,
      };
      if (userRole.role == 'user') {
        data['cageLocation'] = _location;
      }
      final response = await http
          .put(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        ShowResultDialog.show(
          context,
          false,
          customMessage: 'Terjadi kesalahan: ${response.body}',
        );
        return;
      } else {
        ShowResultDialog.show(
          context,
          true,
          customMessage: 'Profil berhasil disimpan!',
        );
      }
    } catch (e) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Terjadi kesalahan: $e',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan!'),
        backgroundColor: Color.fromARGB(255, 56, 24, 0),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
