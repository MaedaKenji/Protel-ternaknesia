import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:sappy/screens/mainpage.dart';
import 'package:http/http.dart' as http;
import 'package:sappy/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController(text: 'rama@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '12345678');
  bool isLoading = false;

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed to avoid memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Trim input values to avoid whitespace issues
    final String email = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final userRole = Provider.of<UserRole>(context, listen: false);

    setState(() {
      isLoading = true; // Start loading
    });

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      ShowResultDialog.show(context, false,
          customMessage: 'Email and password are required');
      setState(() {
        isLoading = false; // Stop loading
      });
      return;
    }

    // Hardcoded roles for testing (remove in production)
    // if (email == 'user@gmail.com') {
    //   userRole.login(email, 'user', 'Atha Rafifi Azmi', '081234567890',
    //       'Jl. Raya Kediri - Nganjuk KM 10');
    // } else if (email == 'doctor@gmail.com') {
    //   userRole.login(
    //       email, 'doctor', 'Dr. Agus Fuad Hasan', '081234567890', '');
    // } else if (email == 'admin@gmail.com') {
    //   userRole.login(email, 'admin', 'Admin Ternaknesia', '081234567890', '');
    // } else if (email == 'u') {
    //   userRole.login(email, 'user', 'Atha Rafifi Azmi', '081234567890', '');
    // } else if (email == 'd') {
    //   userRole.login(
    //       email, 'doctor', 'Dr. Agus Fuad Hasan', '081234567890', '');
    // } else if (email == 'a') {
    //   userRole.login(email, 'admin', 'Admin Ternaknesia', '081234567890', '');
    // } else {
    try {
      // Make API call to login
      final response = await http
          .post(
        Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': email, 'password': password}),
      )
          .timeout(
        const Duration(seconds: 6), // Timeout after 6 seconds
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      // Handle API response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Validate the response data
        if (responseBody['role'] == null) {
          throw Exception('Invalid response from server');
        }

        // Assign user role and data
        userRole.login(
          responseBody['email'],
          responseBody['role'],
          responseBody['nama'],
          responseBody['no_hp'] ?? '', // Use empty string if phone is null
          responseBody['alamat'] ??
              '', // Use empty string if cage_location is null
        );
        userRole.assignIsLoggedIn();
      } else {
        // Handle API errors
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Login failed';
        ShowResultDialog.show(context, false, customMessage: errorMessage);
        userRole.logout();
        return;
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request timed out. Connection to server can't be reached.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. $e')),
      );
      debugPrint(e.toString()); // Print error to console
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }

    // Navigate to the main page if login is successful
    if (userRole.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  String svgGoogleIcon =
      '<svg xmlns="http://www.w3.org/2000/svg" width="0.98em" height="1em" viewBox="0 0 256 262"><path fill="#4285f4" d="M255.878 133.451c0-10.734-.871-18.567-2.756-26.69H130.55v48.448h71.947c-1.45 12.04-9.283 30.172-26.69 42.356l-.244 1.622l38.755 30.023l2.685.268c24.659-22.774 38.875-56.282 38.875-96.027"/><path fill="#34a853" d="M130.55 261.1c35.248 0 64.839-11.605 86.453-31.622l-41.196-31.913c-11.024 7.688-25.82 13.055-45.257 13.055c-34.523 0-63.824-22.773-74.269-54.25l-1.531.13l-40.298 31.187l-.527 1.465C35.393 231.798 79.49 261.1 130.55 261.1"/><path fill="#fbbc05" d="M56.281 156.37c-2.756-8.123-4.351-16.827-4.351-25.82c0-8.994 1.595-17.697 4.206-25.82l-.073-1.73L15.26 71.312l-1.335.635C5.077 89.644 0 109.517 0 130.55s5.077 40.905 13.925 58.602z"/><path fill="#eb4335" d="M130.55 50.479c24.514 0 41.05 10.589 50.479 19.438l36.844-35.974C195.245 12.91 165.798 0 130.55 0C79.49 0 35.393 29.301 13.925 71.947l42.211 32.783c10.59-31.477 39.891-54.251 74.414-54.251"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.asset(
                          'assets/images/LogoTernaknesia.png',
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SAPPY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusColor: const Color(0xFFC35804),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC35804)),
                          ),
                        ),
                        cursorColor: const Color(0xFFC35804),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusColor: const Color(0xFFC35804),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC35804)),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      // Form atau elemen lainnya
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC35804),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC35804),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Iconify(
                            svgGoogleIcon,
                            size: 24,
                          ),
                          label: const Text(
                            'LOGIN WITH GOOGLE',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black
                    .withOpacity(0.5), // Latar belakang semi-transparan
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
