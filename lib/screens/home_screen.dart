import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/nfc_screen.dart'; // Import NFCPage

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // Halaman awal tanpa navigasi bar
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigasi ke NFCPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NFCPage()),
            );
          },
          child: const Text('Tets Aja'),
        ),
      ),
    );
  }
}
