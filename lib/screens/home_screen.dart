import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // Halaman awal
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Indeks awal

  // Fungsi untuk menangani navigasi saat item ditekan
  void _onItemTapped(int index) {
    if (index == 1) {
      // Pindah ke NFCScreen saat ikon 'Input' ditekan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NFCPage()),
      );
    } else {
      setState(() {
        _currentIndex = index; // Perbarui indeks untuk ikon lainnya
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'Selected Index: $_currentIndex',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Indeks saat ini
        onTap: _onItemTapped, // Fungsi navigasi
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
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.brown, // Warna ikon aktif
        unselectedItemColor: Colors.grey, // Warna ikon tidak aktif
        backgroundColor: Colors.white, // Warna latar belakang
        type: BottomNavigationBarType.fixed, // Menampilkan semua item
      ),
    );
  }
}
