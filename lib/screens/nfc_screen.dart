import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  _NfcScreenState createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String _nfcData = "No NFC tag read yet.";

  // Function to start NFC reading
  Future<void> _readNfcTag() async {
    try {
      // Start NFC session
      NFCTag tag = await FlutterNfcKit.poll();
      
      // Process NFC data (Example: reading UID)
      setState(() {
        _nfcData = 'NFC Tag found: ${tag.id}';
      });

      // End NFC session
      await FlutterNfcKit.finish();
    } catch (e) {
      setState(() {
        _nfcData = 'Error reading NFC: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tap your NFC tag below:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _readNfcTag,
              child: const Text('Read NFC Tag'),
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
