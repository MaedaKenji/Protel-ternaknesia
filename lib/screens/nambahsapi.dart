import 'package:flutter/material.dart';

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
      final newCattleData = {
        'id': _idController.text,
        'gender': _gender,
        'age': _ageController.text,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'status': _status?.toUpperCase(),
      };
      Navigator.pop(context, newCattleData);
    } else {
      _showErrorDialog('Please check your inputs.');
    }
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
          // Custom AppBar with Stack
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
                    _sectionTitle('ID Sapi'),
                    _buildCustomTextInput('Masukkan ID Sapi', _idController),
                    const SizedBox(height: 16),
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
                    _sectionTitle('Status'),
                    _buildCustomDropdown(['Sehat', 'Sakit'], (value) {
                      setState(() {
                        _status = value;
                      });
                    }, _status),
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
          color: Colors.brown,
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
        filled: true,
        fillColor: Colors.orange.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.brown),
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
        filled: true,
        fillColor: Colors.orange.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.brown),
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
