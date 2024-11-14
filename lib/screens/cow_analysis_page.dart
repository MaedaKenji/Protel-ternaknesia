// import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'package:ternaknesia/config/config.dart';
import 'dart:convert';

class CowAnalysisPage extends StatefulWidget {
  const CowAnalysisPage({super.key});

  @override
  _CowAnalysisPageState createState() => _CowAnalysisPageState();
}

class _CowAnalysisPageState extends State<CowAnalysisPage> {
  List<FlSpot> healthCowwww = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataAndProcess();
  }

  // Fungsi untuk mengambil data dari API dan memprosesnya menjadi data grafik
  Future<void> fetchDataAndProcess() async {
    final String url = '${AppConfig.serverUrl}/cows';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Kelompokkan data menjadi 6 data terakhir
      final Map<int, int> healthyPerWeek = groupLast6Data(data);

      // Convert the grouped data into FlSpot for plotting on the chart
      setState(() {
        healthCowwww = healthyPerWeek.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
            .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load cow data');
    }
  }

  // Fungsi untuk mengambil 6 data terakhir dari setiap sapi
  Map<int, int> groupLast6Data(List<dynamic> data) {
    Map<int, int> healthyPerWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var cow in data) {
      if (cow['health'] != null && cow['health'] is List) {
        List<dynamic> healthRecords = cow['health'];

        // Ambil 6 data terakhir, jika ada lebih dari 6
        if (healthRecords.length > 6) {
          healthRecords = healthRecords.sublist(healthRecords.length - 6);
        }

        // Proses data, dan tambahkan ke kelompok berdasarkan urutan 1 sampai 6
        for (int i = 0; i < healthRecords.length; i++) {
          var healthRecord = healthRecords[i];
          if (healthRecord['sehat'] == true) {
            healthyPerWeek[i + 1] = healthyPerWeek[i + 1]! + 1;
          }
        }
      }
    }

    return healthyPerWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jumlah sapi yang sehat'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Menampilkan angka 1 sampai 6 di sumbu X
                          return Text(
                            ' ${value.toInt()}',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  minX: 1,
                  maxX: 6, // Menampilkan data 6 terakhir
                  minY: 0,
                  maxY: 80, // Sesuaikan jumlah maksimal sapi sehat
                  lineBarsData: [
                    LineChartBarData(
                      spots: healthCowwww,
                      isCurved: true, // Membuat garis lebih halus
                      barWidth: 4,
                      color: Colors.orange, // Sesuaikan warna garis
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4, // Ukuran titik
                              color: Colors.orange,
                              strokeWidth: 2,
                              strokeColor: Colors.orangeAccent,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: false, // Tidak menampilkan area di bawah grafik
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CowAnalysisPage(),
  ));
}
