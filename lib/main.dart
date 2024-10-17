import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/home_screen.dart';
import 'package:ternaknesia/screens/navbar.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profil.dart';
import 'screens/inputdata.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Navbar(), // Set LoginScreen sebagai halaman utama
    );
  }
}
