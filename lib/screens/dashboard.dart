import 'package:flutter/material.dart';
import 'package:ternaknesia/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';

class DataWidget extends StatefulWidget {
  const DataWidget({Key? key}) : super(key: key);
  
  @override
  State<DataWidget> createState() => _DataWidgetState();  
}



class _DataWidgetState extends State<DataWidget> {
  // Replace these with your actual data fetching logic
  // Example: Fetching data from a database
  // Future<Map<String, dynamic>> fetchData() async {
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate delay
  //   return {
  //     'susu': ,
  //     'sapi_diperah': 18,
  //     'sapi_pakan': 20,
  //   };
  // }
  Future<Map<String, dynamic>> fetchData() async {
    const String url = '${AppConfig.serverUrl}/api/cows/all-susu';
    final response = await http.get(Uri.parse(url));
    int totalMilk = 0;
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      totalMilk = data['totalMilk'];
    } else {
      throw Exception('Failed to load cow data');
    }
    return {'susu': totalMilk};
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
                value: '${data['susu']} L',
              ),
              const SizedBox(height: 16),
              // Card for "Sapi yang telah diperah"
              _dataCard(
                title: 'Sapi yang telah diperah',
                value: '${data['sapi_diperah']}',
              ),
              const SizedBox(height: 16),
              // Card for "Sapi yang telah diberi pakan"
              _dataCard(
                title: 'Sapi yang telah diberi pakan',
                value: '${data['sapi_pakan']}',
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
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
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