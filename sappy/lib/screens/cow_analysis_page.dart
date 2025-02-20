import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sappy/config/config.dart';
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

  Future<void> fetchDataAndProcess() async {
    const String url = '${AppConfig.serverUrl}/cows';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final Map<int, int> healthyPerWeek = groupLast6Data(data);

      setState(() {
        healthCowwww = healthyPerWeek.entries
            .map(
                (entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
            .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load cow data');
    }
  }

  Map<int, int> groupLast6Data(List<dynamic> data) {
    Map<int, int> healthyPerWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var cow in data) {
      if (cow['health'] != null && cow['health'] is List) {
        List<dynamic> healthRecords = cow['health'];

        if (healthRecords.length > 6) {
          healthRecords = healthRecords.sublist(healthRecords.length - 6);
        }

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
        title: const Text('Jumlah sapi yang sehat'),
        leading: null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            ' ${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
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
                  maxX: 6,
                  minY: 0,
                  maxY: 80,
                  lineBarsData: [
                    LineChartBarData(
                      spots: healthCowwww,
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.orange,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.orange,
                          strokeWidth: 2,
                          strokeColor: Colors.orangeAccent,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: false,
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
  runApp(const MaterialApp(
    home: CowAnalysisPage(),
  ));
}
