import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sappy/config/config.dart';
import 'dart:convert';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.orange,
    Colors.green,
  ];
  List<FlSpot> healthCowwww = [];
  bool isLoading = true;
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    fetchDataAndProcess();
  }

  // Fungsi untuk mengambil data dari API dan memprosesnya menjadi data grafik
  Future<void> fetchDataAndProcess() async {
    const String url = '${AppConfig.serverUrl}/cows';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Kelompokkan data menjadi 6 data terakhir
      final Map<int, int> healthyPerWeek = groupLast6Data(data);

      // Convert the grouped data into FlSpot for plotting on the chart
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
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('1', style: style);
        break;
      case 2:
        text = const Text('2', style: style);
        break;
      case 3:
        text = const Text('3', style: style);
        break;
      case 4:
        text = const Text('4', style: style);
        break;
      case 5:
        text = const Text('5', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  // Mengambil nilai maksimum dari y
// Mengambil nilai maksimum dari FlSpot
double findMaxYValue(List<FlSpot> spots) {
  double maxY = double.negativeInfinity; // Inisialisasi dengan nilai terkecil

  for (var spot in spots) {
    if (spot.y > maxY) {
      maxY = spot.y; // Update nilai maksimum jika ditemukan yang lebih besar
    }
  }
  
  return maxY; // Kembalikan nilai maksimum
}

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );
      String text;
       // Mendapatkan nilai maksimum dari y
  double maxY = findMaxYValue(healthCowwww);
   // Menyesuaikan tampilan berdasarkan nilai maksimum
  if (value == maxY) {
    text = maxY.toString(); // Tampilkan nilai maksimum
  } else {
    text = ''; // Kosongkan untuk nilai lainnya
  }
      // switch (value.toInt()) {
      //   case 10:
      //     text = '10';
      //     break;
      //   case 50:
      //     text = '50';
      //     break;
      //   case 80:
      //     text = '80';
      //     break;
      //   default:
      //     // text = '80';
      //     // break;
      //   return Container();
      // }

      return Text(text, style: style, textAlign: TextAlign.left);
    }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      minX: 1,
      maxX: 6,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: healthCowwww,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
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
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
