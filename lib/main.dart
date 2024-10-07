import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const NfcScreen(), // Set LoginScreen sebagai halaman utama
    );
  }
}
