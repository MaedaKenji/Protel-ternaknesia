import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/cow_analysis_page.dart';
import 'package:ternaknesia/screens/login_screen.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'package:ternaknesia/screens/dashboard.dart';

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
      home:  NfcScreen(), // Set LoginScreen sebagai halaman utama
    );
  }
}
