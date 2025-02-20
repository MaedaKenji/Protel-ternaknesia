import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:sappy/screens/home_screen.dart';
import 'package:sappy/screens/nfc_screen.dart';
import 'package:sappy/screens/profile.dart';
import 'package:sappy/screens/datapage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);

    // Tentukan jumlah item berdasarkan role
    final maxIndex = (userRole.role == 'user' ? 3 : 2);
    if (_currentIndex > maxIndex) {
      _currentIndex = maxIndex;
    }

    final List<Widget> pages = [
      const HomeScreen(),
      if (userRole.role == 'user') const NFCPage(),
      const DataPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (userRole.role == 'user')
            const BottomNavigationBarItem(
              icon: Icon(Icons.nfc),
              label: 'Input',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Data',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white30,
        backgroundColor: const Color(0xFFC35804),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
