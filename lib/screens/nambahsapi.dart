import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TambahSapiPage extends StatefulWidget {
  const TambahSapiPage({Key? key}) : super(key: key);

  @override
  State<TambahSapiPage> createState() => _TambahSapiPageState();
}

class _TambahSapiPageState extends State<TambahSapiPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _gender;
  String? _status;

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
        "healthRecord": true // Convert to boolean if needed
      };

      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/tambahsapi'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('Connection timed out'));
        
        if (response.statusCode == 201) {
          _showSuccessDialog();
        } else if (response.statusCode == 400) {
          final responseBody = jsonDecode(response.body);
          _showErrorDialog(responseBody['message'] ?? 'Error occurred');
        } else if (response.statusCode == 500) {
          _showErrorDialog('Internal server error');
        } 
        else if (response.statusCode == 404) {
          _showErrorDialog('Resource not found');
        }
        else {
          _showErrorDialog('An unexpected error occurred');
        }
      } catch (error) {
         print("Error: ${error.toString()}");
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                'Gagal Menambah Data',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String? _numericValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harap diisi';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Harus berupa angka';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Data Sapi',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Data Sapi'),
              _buildTextInput('ID Sapi', _idController),
              const SizedBox(height: 10),
              _buildDropdownInput('Gender', ['Betina', 'Jantan'], (value) {
                setState(() {
                  _gender = value;
                });
              }),
              const SizedBox(height: 10),
              _buildTextInput('Umur (Bulan)', _ageController, isNumeric: true),
              const SizedBox(height: 10),
              _buildTextInput('Berat (Kg)', _weightController, isNumeric: true),
              const SizedBox(height: 10),
              _buildDropdownInput('Status', ['Sehat', 'Sakit'], (value) {
                setState(() {
                  _status = value;
                });
              }),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: isNumeric
          ? _numericValidator
          : (value) {
              if (value == null || value.isEmpty) {
                return 'Harap diisi';
              }
              return null;
            },
    );
  }

  Widget _buildDropdownInput(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: label == 'Gender' ? _gender : _status,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih $label';
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
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
        child: const Text(
          'TAMBAHKAN DATA SAPI',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
