import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/home_screen.dart';
import 'package:ternaknesia/screens/navbar.dart';
import 'package:ternaknesia/screens/nfc_screen.dart';
import 'package:ternaknesia/screens/datasapipage.dart';
import 'screens/login_screen.dart';
import 'screens/profil.dart';
import 'screens/inputdata.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Navbar(), // Set LoginScreen sebagai halaman utama
    );
  }
}
