import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() async {
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
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
          child: LoginScreen(),
        ));
  }
}
