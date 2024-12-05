import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ternaknesia/main.dart';
import 'package:ternaknesia/screens/inputdata.dart';

class AddEditNFCTag extends StatefulWidget {
  final String id;
  final bool isConnectedToNFCTag;

  const AddEditNFCTag(
      {super.key, required this.id, required this.isConnectedToNFCTag});

  @override
  State<AddEditNFCTag> createState() => _AddEditNFCTagState();
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

class _AddEditNFCTagState extends State<AddEditNFCTag>
    with SingleTickerProviderStateMixin {
  bool _isNfcEnabled = true;
  bool _isNfcTagConnected = false;
  bool _isChanged = false;
  late AnimationController _animationController;
  final TextEditingController _nfcCodeController = TextEditingController();

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
    _nfcCodeController.dispose();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    setState(() {});
  }

  void _startNfcScan() async {
    setState(() {});

    _showNfcDialog();

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final nfcData = tag.data.toString();

          setState(() {
            _isNfcEnabled = true;
            _isNfcTagConnected = true;
            _isChanged = true;
          });

          if (navigatorKey.currentState?.canPop() ?? false) {
            navigatorKey.currentState?.pop();
          }

          await NfcManager.instance.stopSession();

          _showNfcResultDialog(nfcData);
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
    if (_nfcCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode NFC tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return InputDataPage(
              cowId: 'ss',
            );
          },
        ),
      );
    }
  }

  void _saveChanges() {
    if (_isNfcTagConnected) {
      // Simulate saving changes with a short delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isNfcTagConnected = false;
        });
        _showMessage('Perubahan berhasil disimpan');

        // Kembali ke halaman sebelumnya
        Navigator.pop(context);
      });
    } else {
      _showMessage('Tidak ada NFC Tag yang terhubung!');
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
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.isConnectedToNFCTag
                                ? 'Edit NFC Tag'
                                : 'Sambung NFC Tag',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Container untuk ID yang ada di sisi kanan
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.perm_identity,
                                color: Color(0xFF8A5E3B), // Brown color
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ID: ${widget.id}',
                                style: TextStyle(
                                  color: Color(0xFF8A5E3B), // Brown color
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    ],
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
                      controller: _nfcCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        labelText: 'Kode NFC',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isChanged = value.isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (widget.isConnectedToNFCTag)
                      ElevatedButton(
                        onPressed: _isNfcTagConnected
                            ? () {
                                _startNfcScan();
                              }
                            : () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFC35804),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Ganti NFC Tag',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (!widget.isConnectedToNFCTag) ...[
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
                        icon: const Icon(Icons.nfc, color: Colors.white),
                        label: const Text(
                          'Sambungkan ke NFC Tag',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isChanged ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFC35804),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
