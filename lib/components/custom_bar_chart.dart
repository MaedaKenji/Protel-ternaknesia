import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomBarChart extends StatelessWidget {
  final String title;
  final List<BarChartGroupData> data;
  final double predictedNextMonth; // Tambahkan variabel baru

  const CustomBarChart({
    super.key,
    required this.title,
    required this.data,
    required this.predictedNextMonth, // Tambahkan ke konstruktor
  });

  @override
  Widget build(BuildContext context) {
    final predictionBar = BarChartGroupData(
      x: data.length,
      barRods: [
        if (title == 'Produksi Susu per Bulan')
          BarChartRodData(
            toY: predictedNextMonth,
            color: Color(0xFFC35804),
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC35804),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 250,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final months = ['Sep', 'Okt', 'Nov', 'Des', 'Jan'];
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                maxY: 1000,
                barGroups: [
                  ...data.map((barGroup) {
                    return BarChartGroupData(
                      x: barGroup.x,
                      barRods: barGroup.barRods.map((rod) {
                        return BarChartRodData(
                          toY: rod.toY,
                          color: Color(0xFFE6B87D),
                          width: rod.width,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                  if (title == 'Produksi Susu per Bulan') predictionBar,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE6B87D),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Data Asli',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(width: 16),
              if (title == 'Produksi Susu per Bulan') ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC35804),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Data Prediksi',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
