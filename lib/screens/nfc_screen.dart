import 'package:flutter/material.dart';
import 'dart:math';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  _NfcScreenState createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String _nfcData = "No NFC tag read yet.";

  // Function to generate dummy NFC data
  String _generateDummyNfcData() {
    final random = Random();
    final tagId = List.generate(8, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join(':');
    return 'NFC Tag found: $tagId';
  }

  // Function to simulate NFC reading
  Future<void> _simulateNfcReading() async {
    setState(() {
      _nfcData = 'Reading NFC tag...';
    });

    // Simulate a delay to mimic NFC reading process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _nfcData = _generateDummyNfcData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader (Simulation)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tap the button to simulate NFC tag reading:',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simulateNfcReading,
              child: const Text('Simulate NFC Tag Reading'),
            ),
            const SizedBox(height: 20),
            Text(
              _nfcData,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}