import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  final String title;
  final List<double> values;

  const Chart({super.key, required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text('Data tidak tersedia'),
      );
    }

    List<FlSpot> spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble() + 1, entry.value);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFFC35804),
                  dotData: const FlDotData(show: true),
                ),
              ],
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
