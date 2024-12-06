import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/logout_dialog.dart';
import 'package:ternaknesia/provider/user_role.dart';
import 'package:ternaknesia/screens/login_screen.dart';

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
      _roleController.text = userRole.role == 'user'
          ? 'Peternak'
          : userRole.role == 'admin'
              ? 'Admin'
              : 'Dokter Hewan';
    }
    if (_locationController.text.isEmpty && userRole.cageLocation.isNotEmpty) {
      _locationController.text = userRole.cageLocation;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 70,
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
              const Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'User Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    _saveProfile();
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
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
                  ),
                  if (userRole.role != 'doctor') ...[
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
            Navigator.pushReplacement(
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
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
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

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan!'),
        backgroundColor: Color.fromARGB(255, 56, 24, 0),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
