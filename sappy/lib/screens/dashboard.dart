import 'package:flutter/material.dart';
import 'package:sappy/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

class DataWidget extends StatefulWidget {
  const DataWidget({super.key});

  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  Future<Map<String, dynamic>> fetchData() async {
    const String url = '${AppConfig.serverUrl}/api/cows/today';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      int totalMilk = data['totalMilk'] ?? 0;
      int sapiTelahDiperah = data['sapiTelahDiperah'] ?? 0;
      int sapiTelahDiberipakan = data['sapiTelahDiberipakan'] ?? 0;

      List<Map<String, dynamic>> allSusu =
          List<Map<String, dynamic>>.from(data['allSusu'] ?? []);

      return {
        'totalMilk': totalMilk,
        'sapiTelahDiperah': sapiTelahDiperah,
        'sapiTelahDiberipakan': sapiTelahDiberipakan,
        'allSusu': allSusu,
      };
    } else {
      throw Exception('Failed to load cow data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            children: [
              // Card for "Perolehan susu hari ini"
              _dataCard(
                title: 'Perolehan susu hari ini',
                value: '${data['totalMilk']} L',
              ),
              const SizedBox(height: 16),
              // Card for "Sapi yang telah diperah"
              _dataCard(
                title: 'Sapi yang telah diperah',
                value: '${data['sapiTelahDiperah']}',
              ),
              const SizedBox(height: 16),
              // Card for "Sapi yang telah diberi pakan"
              _dataCard(
                title: 'Sapi yang telah diberi pakan',
                value: '${data['sapiTelahDiberipakan']}',
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data'));
        }
      },
    );
  }

  Widget _dataCard({
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
