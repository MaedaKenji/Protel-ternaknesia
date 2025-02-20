import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:sappy/components/custom_pop_up_dialog.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class InputDataPage extends StatefulWidget {
  final String cowId;
  const InputDataPage({super.key, required this.cowId});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pakanHijauanController = TextEditingController();
  final TextEditingController _pakanSentratController = TextEditingController();
  final TextEditingController _beratBadanController = TextEditingController();
  final TextEditingController _produksiSusuController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String? _stressLevel;
  bool? _sakit = false;
  bool? _birahi = false;
  bool _showKeteranganSakit = false;
  final TextEditingController _keteranganSakitController =
      TextEditingController();

  @override
  void dispose() {
    _pakanHijauanController.dispose();
    _pakanSentratController.dispose();
    _beratBadanController.dispose();
    _produksiSusuController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );
    }
  }

  Future<void> _updateDataKondisi() async {
    final url = '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/kondisi/${widget.cowId}';

    // Membuat data yang akan dikirim
    final Map<String, dynamic> data = {
      'stress_level': _keteranganSakitController.text.toLowerCase(),
       'sakit': _sakit, // Mengubah boolean ke string
      'birahi': _birahi, // Mengubah boolean ke string
      'catatan': _catatanController.text,

    };

    try {
      // Mengirim permintaan POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Menangani respons dari server
      if (response.statusCode == 200) {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil disimpan!')),
          );
        }
      } else {
        // Jika gagal, tampilkan error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal mengirim data')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 195, bottom: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('INPUT'),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
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
                      _buildNumericInput(
                          'Berat Badan', 'Kg', _beratBadanController),
                      const SizedBox(height: 10),
                      _buildNumericInput(
                          'Produksi Susu', 'Kg', _produksiSusuController),
                      const SizedBox(height: 20),
                      _sectionTitle('Kondisi Hewan'),
                      _buildDropdown('Stress Level', ['Low', 'Medium', 'High']),
                      const SizedBox(height: 10),
                      _buildRadioInputWithTextField('Sakit', _sakit, (value) {
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
            ),
            _buildHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110,
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
          right: 16,
          top: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Input Data',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E2B5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFC35804),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/images/cow_alt.png'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CustomPopUpDialog(
                                          title: 'ID SAPI',
                                          content: widget.cowId,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    widget.cowId,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8F3505),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildCowIndicator(
                                isHealthy: false,
                                isMale: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCowInfo(
                                'Berat',
                                '350 Kg',
                                MaterialSymbols.weight,
                              ),
                              _buildCowInfo('Umur', '5 Tahun',
                                  MaterialSymbols.calendar_month),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCowInfo(String label, String value, String icon) {
    return Expanded(
      child: Row(children: [
        Iconify(
          icon,
          size: 32,
          color: const Color(0xFF8F3505),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8F3505),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildCowIndicator({required bool isHealthy, required bool isMale}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              isHealthy ? Colors.green.shade300 : Colors.red.shade300,
              isHealthy ? Colors.green.shade600 : Colors.red.shade600,
            ]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHealthy ? Icons.check : Icons.error,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                isHealthy ? 'SEHAT' : 'SAKIT',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              isMale ? Colors.blue.shade300 : Colors.pink.shade300,
              isMale ? Colors.blue.shade600 : Colors.pink.shade600,
            ]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMale ? Icons.male : Icons.female,
                color: Colors.white,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Column(children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFFC35804),
          color: Color(0xFFC35804),
        ),
      ),
      const SizedBox(height: 10),
    ]);
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 4,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804), width: 2),
              ),
            ),
            dropdownColor: const Color(0xFFFFF7E9),
            value: _stressLevel,
            onChanged: (String? newValue) {
              setState(() {
                _stressLevel = newValue;
              });
            },
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Color(0xFFC35804)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput(
      String label, String unit, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            cursorColor: const Color(0xFFC35804),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap diisi';
              }
              final number = double.tryParse(value);
              if (number == null) {
                return 'Harus berupa angka';
              }
              return null;
            },
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

  Widget _buildRadioInputWithTextField(
      String label, bool? groupValue, ValueChanged<bool?> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 4,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: groupValue,
                      onChanged: (value) {
                        onChanged(value);
                        if (value == true) {
                          setState(() {
                            _showKeteranganSakit = true;
                          });
                        }
                      },
                      activeColor: const Color(0xFFC35804),
                    ),
                    const Text(
                      'Ya',
                      style: TextStyle(color: Color(0xFFC35804)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                if (_showKeteranganSakit)
                  SizedBox(
                    width: 170,
                    height: 40,
                    child: TextFormField(
                      controller: _keteranganSakitController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color(0xFFC35804),
                      decoration: const InputDecoration(
                        isDense: true,
                        labelStyle: TextStyle(color: Color(0xFFC35804)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC35804)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC35804)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFC35804), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi keterangan sakit';
                        }
                        return null;
                      },
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: groupValue,
                  onChanged: (value) {
                    onChanged(value);
                    if (value == false) {
                      setState(() {
                        _showKeteranganSakit = false;
                      });
                    }
                  },
                  activeColor: const Color(0xFFC35804),
                ),
                const Text(
                  'Tidak',
                  style: TextStyle(color: Color(0xFFC35804)),
                ),
              ],
            ),
          ]),
        )
      ],
    );
  }

  Widget _buildRadioInput(
      String label, bool? groupValue, ValueChanged<bool?> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Row(
                children: [
                  const Text(
                    'Ya',
                    style: TextStyle(color: Color(0xFFC35804)),
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: const Color(0xFFC35804),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Tidak',
                    style: TextStyle(color: Color(0xFFC35804)),
                  ),
                  Radio<bool>(
                    value: false,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: const Color(0xFFC35804),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      cursorColor: const Color(0xFFC35804),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC35804)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC35804)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC35804), width: 2),
        ),
        hintText: 'Masukkan catatan',
        hintStyle: TextStyle(color: Color(0xFFC35804)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
        onPressed: _updateDataKondisi,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFF9E2B5),
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: Color(0xFFC35804)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'MASUKKAN DATA',
          style: TextStyle(
            color: Color(0xFFC35804),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ));
  }
}
