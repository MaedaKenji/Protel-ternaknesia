// ignore_for_file: deprecated_member_use, empty_catches

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ternaknesia/main.dart';
import 'package:ternaknesia/screens/datasapipage.dart';
import 'package:ternaknesia/screens/inputdata.dart';

class NFCPage extends StatefulWidget {
  const NFCPage({super.key});

  @override
  State<NFCPage> createState() => _NFCPageState();
}

class CircleWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final radius = size.width / 2 * progress;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _NFCPageState extends State<NFCPage> with SingleTickerProviderStateMixin {
  bool _isNfcEnabled = true;
  late AnimationController _animationController;
  final TextEditingController _cowIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cowIdController.dispose();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    setState(() {});
  }

  static const List<Map<String, dynamic>> dataCowNFC = [
    {
      'cow_id': 1,
      'umur': 83,
      'nfc_id': '3a:ad:ef:b0',
      'is_kandang': true,
      'gender': 'jantan',
    },
    {
      'cow_id': 2,
      'umur': 70,
      'nfc_id': '',
      'is_kandang': true,
      'gender': 'betina',
    },
  ];

  static const List<Map<String, dynamic>> dataSapi = [
    {
      'id': 1,
      'weight': 660.88,
      'age': 83,
      'gender': 'jantan',
      'healthStatus': 'sehat',
      'isProductive': true,
      'isConnectedToNFCTag': false,
    },
    {
      'id': 2,
      'weight': 419.51,
      'age': 70,
      'gender': 'betina',
      'healthStatus': 'sakit',
      'isProductive': true,
      'isConnectedToNFCTag': false,
    },
  ];

  void _startNfcScan() async {
    setState(() {});

    _showNfcDialog();

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Validate and process NFC data
          final dynamic nfcData = tag.data;

          if (nfcData is Map<String, dynamic>) {
            _onNfcRead(nfcData); // Call the function without awaiting
          } else {
            // Handle unexpected data format
            throw Exception('Unexpected NFC data format.');
          }

          setState(() {
            _isNfcEnabled = true;
          });

          if (navigatorKey.currentState?.canPop() ?? false) {
            navigatorKey.currentState?.pop();
          }

          await NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      setState(() {});

      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }

      _showMessage('Terjadi kesalahan: $e');
    }
  }

  void _onNfcRead(Map<String, dynamic> nfcData) async {
    try {
      if (nfcData.containsKey('nfca')) {
        List<int> identifier = nfcData['nfca']['identifier'];
        String nfcId = identifier
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join(':');

        // Cari di dataCowNFC
        final Map<String, dynamic> matchedCowNFC = dataCowNFC.firstWhere(
          (cow) => cow['nfc_id'] == nfcId,
          orElse: () => {}, // Kembalikan map kosong jika tidak ditemukan
        );

        if (matchedCowNFC.isNotEmpty) {
          // Cari di dataSapi
          final Map<String, dynamic> matchedCowSapi = dataSapi.firstWhere(
            (sapi) => sapi['id'] == matchedCowNFC['cow_id'],
            orElse: () => {}, // Kembalikan map kosong jika tidak ditemukan
          );

          if (matchedCowSapi.isNotEmpty) {
            // Tutup pop-up dialog dan hentikan sesi NFC sebelum navigasi
            if (navigatorKey.currentState?.canPop() ?? false) {
              navigatorKey.currentState?.pop(); // Close pop-up dialog
            }
            await NfcManager.instance.stopSession(); // Cancel NFC scan

            // Konversi data ke String
            final String id = matchedCowSapi['id'].toString();
            final String gender = matchedCowSapi['gender'].toString();
            final String age = matchedCowSapi['age'].toString();
            final String healthStatus =
                matchedCowSapi['healthStatus'].toString();

            // Navigasi ke DataSapiPage dengan data String
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DataSapiPage(
                  id: id,
                  gender: gender,
                  age: age,
                  healthStatus: healthStatus,
                  isProductive: matchedCowSapi['isProductive'],
                  isConnectedToNFCTag: matchedCowSapi['isConnectedToNFCTag'],
                ),
              ),
            );
          } else {
            // Jika cow_id tidak ditemukan di dataSapi
            if (navigatorKey.currentState?.canPop() ?? false) {
              navigatorKey.currentState?.pop(); // Close pop-up dialog
            }
            await NfcManager.instance.stopSession(); // Cancel NFC scan

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data Sapi tidak ditemukan untuk cow_id ini.'),
              ),
            );
          }
        } else {
          // Jika NFC ID tidak ditemukan di dataCowNFC
          if (navigatorKey.currentState?.canPop() ?? false) {
            navigatorKey.currentState?.pop(); // Close pop-up dialog
          }
          await NfcManager.instance.stopSession(); // Cancel NFC scan

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak ada Data Sapi dengan NFC ID ini: $nfcId'),
            ),
          );
        }
      } else {
        throw Exception('Data NFC tidak valid, identifier tidak ditemukan.');
      }
    } catch (e) {
      // Hilangkan pop-up dialog dan cancel sesi NFC jika terjadi kesalahan
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }
      await NfcManager.instance.stopSession(); // Cancel NFC scan

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showNfcDialog() {
    _animationController.repeat();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            _cancelNfcScan();
            return true;
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: CircleWavePainter(
                            progress: _animationController.value,
                            color: Colors.orange
                                .withOpacity(1 - _animationController.value),
                          ),
                          size: const Size(100, 100),
                        );
                      },
                    ),
                    const Icon(
                      Icons.nfc,
                      size: 60,
                      color: Colors.brown,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tempelkan kartu NFC di dekat perangkat ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _cancelNfcScan();
    });
  }

  void _cancelNfcScan() async {
    _animationController.stop();
    _animationController.reset();
    setState(() {
      _isNfcEnabled = true;
    });
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {}
  }

  void _showNfcResultDialog(String nfcData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Data NFC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              nfcData,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFC35804),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToInputDataPage() {
    if (_cowIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Sapi tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return InputDataPage(cowId: _cowIdController.text);
          },
        ),
      );
    }
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
              const Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Input Data Sapi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _cowIdController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        labelText: 'ID Sapi',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToInputDataPage,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFC35804),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isNfcEnabled
                          ? () {
                              setState(() {
                                _isNfcEnabled = false;
                              });
                              _startNfcScan();
                            }
                          : null,
                      icon: const Icon(Icons.nfc),
                      label: const Text(
                        'SCAN WITH NFC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
