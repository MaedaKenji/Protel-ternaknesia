import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/home_screen.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'package:ternaknesia/screens/inputdata.dart';
import 'package:ternaknesia/screens/profil.dart';
import 'package:ternaknesia/screens/datapage.dart';
import 'package:ternaknesia/screens/datasapipage.dart';// Import the DataPage

void main() {
  runApp(const Navbar());
}

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationBarPage(), // Main navigation page
    );
  }
}

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _currentIndex = 0; // Current page index

  // List of pages accessible through navigation
  final List<Widget> _pages = [
    const HomeScreen(),
    const NFCPage(),
    const DataPage(), // Added DataPage
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Display page based on index
        children: _pages, // List of pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Current selected index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update page index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'Input',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orange, // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        backgroundColor: Colors.orange, // Background color
        type: BottomNavigationBarType.fixed, // Show all items
      ),
    );
  }
}
