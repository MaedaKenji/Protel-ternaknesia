import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sappy/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  bool isLoading = false;

  void _submit() async {
    final email = _usernameController.text;
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;
    final namaLengkap = _namaLengkapController.text;
    final noTelp = _noTelpController.text;
    final alamat = _alamatController.text;
    // final email = 'rama@gmail.com';
    // final password = '123456';
    // final passwordConfirmation = '123456';
    // final namaLengkap = 'Rama';
    // final noTelp = '081234567890';
    // final alamat = 'Jl. Raya No. 1';

    if (email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty ||
        namaLengkap.isEmpty ||
        noTelp.isEmpty ||
        alamat.isEmpty) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Semua kolom harus diisi!',
      );
      return;
    }

    if (password != passwordConfirmation) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Password dan konfirmasi password tidak sama!',
      );
      return;
    }

    final isValidEmail =
        RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+(?:\.[a-zA-Z]+)?$')
            .hasMatch(email);
    if (!isValidEmail) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Email tidak valid!',
      );
      return;
    }

    final isValidPassword = RegExp(r'^.{6,}$').hasMatch(password);
    if (!isValidPassword) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Password minimal 6 karakter!',
      );
      return;
    }

    final isValidNoTelp = RegExp(r'^[0-9]{10,12}$').hasMatch(noTelp);
    if (!isValidNoTelp) {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Nomor telepon tidak valid!',
      );
      return;
    }

    final response = await http
        .post(
      Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/users/register'),
      headers: {
        'Content-Type': 'application/json', // Add this header
      },
      body: jsonEncode({
        // Encode the body as JSON
        'email': email,
        'password': password,
        'nama': namaLengkap,
        'no_hp': noTelp,
        'alamat': alamat,
        'role': 'user',
      }),
    )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      ShowResultDialog.show(
        context,
        false,
        customMessage: 'Request timeout! Silahkan coba lagi.',
      );
      return http.Response('Error', 408); // 408 Request Timeout
    });

    if (response.statusCode != 201) {
      // Parse the response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Extract the error message
      final String errorMessage = responseBody['error'] ??
          responseBody['message'] ??
          'Registrasi gagal! Silahkan coba lagi.';


      ShowResultDialog.show(
        context,
        false,
        customMessage: errorMessage,
      );
      return;
    }
    ShowResultDialog.show(
      context,
      true,
      customMessage: 'Registrasi berhasil!',
    );

    setState(() {
      isLoading = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });
  }

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
                        controller: _namaLengkapController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
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
                        controller: _noTelpController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
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
                        controller: _alamatController,
                        decoration: InputDecoration(
                          labelText: 'Alamat',
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
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordConfirmationController,
                        decoration: InputDecoration(
                          labelText: 'Password Confirmation',
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
                      const SizedBox(height: 20),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
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
                            'SUMBIT',
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
