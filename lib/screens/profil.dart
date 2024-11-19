import 'package:flutter/material.dart';

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
  void initState() {
    super.initState();
    // Set default values
    _nameController.text = 'ATHA RAFIFI';
    _emailController.text = 'athahahaha@gmail.com';
    _phoneController.text = '081 2123 5567';
    _roleController.text = 'Peternak';
    _locationController.text = 'Jl. Sawah Mangga 5 / Y-2';
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
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
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: const Center(
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
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                children: [
                  // Gambar Profil
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/1998/1998627.png'),
                  ),
                  const SizedBox(height: 10),
                  // Nama Pengguna
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Kolom Input Email
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  // Kolom Input Telepon
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),
                  // Kolom Input Role
                  _buildInfoRow(
                    icon: Icons.work,
                    label: 'Role',
                    controller: _roleController,
                  ),
                  const SizedBox(height: 20),
                  // Kolom Input Lokasi
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'Lokasi Kandang',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 20),
                  // Kolom Input Email (Tambahan)
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _saveProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFF9E2B5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFFC35804)),
                    ),
                    child: const Text(
                      'EDIT PROFIL',
                      style: TextStyle(
                        color: Color(0xFFC35804),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuat baris informasi
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ikon di sisi kiri
        Icon(icon, color: Color(0xFFC35804), size: 28),
        const SizedBox(width: 10),
        // Kolom untuk Label dan Input
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              // Input Field
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
