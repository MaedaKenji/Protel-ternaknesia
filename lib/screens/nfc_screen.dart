import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  _NfcScreenState createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String _nfcData = "No NFC tag read yet.";

   // Function to read real NFC tag data
  Future<void> _readNfcTag() async {
    setState(() {
      _nfcData = 'Reading NFC tag...';
    });

      try {
      // Wait for the NFC tag to be detected
      final tag = await FlutterNfcKit.poll();

      // Build a tag information string
      String tagInfo = 'NFC Tag found:\n';
      tagInfo += 'ID: ${tag.id}\n';
      tagInfo += 'Type: ${tag.type}\n';

      // Check if NDEF is available and not null
      if (tag.ndefAvailable == true) {
        final ndef = await FlutterNfcKit.readNDEFRecords();
        tagInfo += 'NDEF Data: ${ndef.map((e) => e.payload).join(', ')}';
      } else {
        tagInfo += 'No NDEF data available';
      }

      setState(() {
        _nfcData = tagInfo;
      });

      // Finish NFC session
      await FlutterNfcKit.finish();
    } catch (e) {
      setState(() {
        _nfcData = 'Error reading NFC tag: $e';
      });
    }
  }

  // Function to simulate NFC reading

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
              onPressed: _readNfcTag,
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