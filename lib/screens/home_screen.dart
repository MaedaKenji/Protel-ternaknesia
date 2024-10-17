import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/login_screen.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Bottom Navigation',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    //HomePage(),
    LoginScreen(),
    NFCPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orange, // Warna latar belakang bar
        items: const <BottomNavigationBarItem>[
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // Warna ikon saat dipilih
        unselectedItemColor: Colors.white60, // Warna ikon saat tidak dipilih
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Memastikan semua item tampil
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'This is the Home Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class InputScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'This is the Input Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'This is the Data Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'This is the Profile Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
