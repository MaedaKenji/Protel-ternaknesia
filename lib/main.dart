import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
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
