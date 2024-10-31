import 'package:flutter/material.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({Key? key}) : super(key: key);

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _pakanHijauanController = TextEditingController();
  final TextEditingController _pakanSentratController = TextEditingController();
  final TextEditingController _beratBadanController = TextEditingController();
  final TextEditingController _produksiSusuController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // State variables
  String? _stressLevel;
  bool? _sakit = false;
  bool? _birahi = false;

  @override
  void dispose() {
    _pakanHijauanController.dispose();
    _pakanSentratController.dispose();
    _beratBadanController.dispose();
    _produksiSusuController.dispose();
    _catatanController.dispose();
    super.dispose();
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
                'INPUT DATA SAPI BERHASIL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    ).then((_) {
      Navigator.pop(context); // Navigate back to NFC Page
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
                'Gagal Input Data',
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

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving data (replace with actual logic)
      print('Data saved successfully');
      _showSuccessDialog();
    } else {
      _showErrorDialog('Harap periksa kembali input Anda.');
    }
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
          'Sapi 001',
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
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/cow.png'),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Pakan yang diberikan'),
              _buildNumericInput(
                  'Pakan Hijauan', 'Kg', _pakanHijauanController),
              const SizedBox(height: 10),
              _buildNumericInput(
                  'Pakan Sentrat', 'Kg', _pakanSentratController),
              const SizedBox(height: 20),
              _sectionTitle('Berat Badan & Produksi Susu'),
              _buildNumericInput('Berat Badan', 'Kg', _beratBadanController),
              const SizedBox(height: 10),
              _buildNumericInput(
                  'Produksi Susu', 'Kg', _produksiSusuController),
              const SizedBox(height: 20),
              _sectionTitle('Kondisi Hewan'),
              _buildDropdown('Stress Level', ['Low', 'Medium', 'High']),
              const SizedBox(height: 10),
              _buildRadioInput('Sakit', _sakit, (value) {
                setState(() {
                  _sakit = value;
                });
              }),
              _buildRadioInput('Birahi', _birahi, (value) {
                setState(() {
                  _birahi = value;
                });
              }),
              const SizedBox(height: 20),
              _sectionTitle('Catatan :'),
              _buildNotesInput(_catatanController),
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

  Widget _buildNumericInput(
      String label, String unit, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            validator: _numericValidator,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          unit,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: _stressLevel,
      onChanged: (String? newValue) {
        setState(() {
          _stressLevel = newValue;
        });
      },
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildRadioInput(
      String label, bool? groupValue, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            const Text('Ya'),
            Radio<bool>(
              value: true,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const Text('Tidak'),
            Radio<bool>(
              value: false,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesInput(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Masukkan catatan',
      ),
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
          'MASUKKAN DATA',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
