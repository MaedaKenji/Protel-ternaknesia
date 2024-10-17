import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/home_screen.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'package:ternaknesia/screens/inputdata.dart';
import 'package:ternaknesia/screens/profil.dart';

void main() {
  runApp(const Navbar());
}

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationBarPage(), // Halaman utama dengan navigasi
    );
  }
}

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _currentIndex = 0; // Indeks halaman aktif

  // Daftar halaman yang bisa diakses melalui navigasi
  final List<Widget> _pages = [
    const HomeScreen(),
    const NFCPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Menampilkan halaman berdasarkan indeks
        children: _pages, // Daftar halaman
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Indeks item saat ini
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Perbarui indeks halaman
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: 'Input',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orange, // Warna ikon aktif
        unselectedItemColor: Colors.grey, // Warna ikon tidak aktif
        backgroundColor: Colors.white, // Latar belakang navigasi
        type: BottomNavigationBarType.fixed, // Menampilkan semua item
      ),
    );
  }
}
