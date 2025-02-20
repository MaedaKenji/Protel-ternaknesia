import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TambahSapiPage extends StatefulWidget {
  const TambahSapiPage({super.key});

  @override
  State<TambahSapiPage> createState() => _TambahSapiPageState();
}

class _TambahSapiPageState extends State<TambahSapiPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  

  String? _gender;
  String? _statusKesehatan;

  @override
  void dispose() {
    _idController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }


  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "id": _idController.text,
        "gender": _gender,
        "age": int.parse(_ageController.text),
        "weight": double.parse(_weightController.text),
        "health": _statusKesehatan,
      };

      try {
        final response = await http
            .post(
              Uri.parse(
                  '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/tambahsapi'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            )
            .timeout(const Duration(seconds: 10),
                onTimeout: () =>
                    throw TimeoutException('Connection timed out'));

        if (response.statusCode == 201) {
          _showSuccessDialog();
        } else if (response.statusCode == 400) {
          final responseBody = jsonDecode(response.body);
          _showErrorDialog(responseBody['message'] ?? 'Error occurred');
        } else if (response.statusCode == 500) {
          _showErrorDialog('Server error: ${response.body}');
        } else if (response.statusCode == 404) {
          _showErrorDialog('Resource not found');
        } else {
          _showErrorDialog('An unexpected error occurred');
        }
      } catch (error) {
        _showErrorDialog('Failed to submit data. Please try again.');
      }
    } else {
      _showErrorDialog('Please check your inputs.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 50, color: Colors.orange),
              SizedBox(height: 10),
              Text(
                'DATA SAPI BERHASIL DITAMBAHKAN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    ).then((_) {
      Navigator.pop(context); // Go back after success
    });
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 10,
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    const Text(
                      'Tambah Data Sapi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _sectionTitle('ID Sapi'),
                    // _buildCustomTextInput('Masukkan ID Sapi', _idController),
                    // const SizedBox(height: 16),
                    _sectionTitle('Gender'),
                    _buildCustomDropdown(['Betina', 'Jantan'], (value) {
                      setState(() {
                        _gender = value;
                      });
                    }, _gender),
                    const SizedBox(height: 16),
                    _sectionTitle('Umur (Bulan)'),
                    _buildCustomTextInput('Masukkan umur sapi', _ageController,
                        isNumeric: true),
                    const SizedBox(height: 16),
                    _sectionTitle('Berat (Kg)'),
                    _buildCustomTextInput(
                        'Masukkan berat sapi', _weightController,
                        isNumeric: true),
                    const SizedBox(height: 16),
                    _sectionTitle('Status Kesehatan'),
                    _buildCustomDropdown(['Sehat', 'Sakit'], (value) {
                      setState(() {
                        _statusKesehatan = value;
                      });
                    }, _statusKesehatan),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFC35804),
        ),
      ),
    );
  }

  Widget _buildCustomTextInput(String hint, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap diisi';
        }
        if (isNumeric && double.tryParse(value) == null) {
          return 'Harus berupa angka';
        }
        return null;
      },
    );
  }

  Widget _buildCustomDropdown(
      List<String> items, ValueChanged<String?> onChanged, String? value) {
    return DropdownButtonFormField<String>(
      hint: const Text('Pilih salah satu'),
      value: value,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC35804)),
        ),
      ),
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap pilih salah satu';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitData,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFC35804),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'TAMBAHKAN DATA SAPI',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
