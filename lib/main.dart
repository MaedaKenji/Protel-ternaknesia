import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'screens/login_screen.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';

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
      home: LoginScreen(), // Set LoginScreen sebagai halaman utama
    );
  }
}
