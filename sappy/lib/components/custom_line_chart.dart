// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomLineChart extends StatefulWidget {
  final String title;
  String? otherInfo;
  double? valueInfo;
  final Map<String, List<FlSpot>> datas;
  double? predictionPointWidget; //Ini gak kepake sebetulnya, tapi ya biar aja belum refactor
  final Function(FlSpot?)? onLastPointUpdated;

  CustomLineChart(
      {super.key,
      required this.title,
      this.otherInfo,
      this.valueInfo,
      required this.datas,
      required this.predictionPointWidget,
      this.onLastPointUpdated});

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late String selectedMonth;
  double predictionPointValue = 0.0;

  @override
  void initState() {
    super.initState();
    selectedMonth =
        widget.datas.keys.isNotEmpty ? widget.datas.keys.first : 'Default';
    if (widget.datas[selectedMonth]?.isNotEmpty ?? false) {
      _updateLastPoint(); // Panggil hanya jika data ada
    }
  }

  void _updateLastPoint() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<FlSpot>? lastDataPoints = widget.datas[selectedMonth];
      FlSpot? lastPoint = (lastDataPoints != null && lastDataPoints.isNotEmpty)
          ? lastDataPoints.last
          : null;

      // Panggil callback jika tersedia
      if (widget.onLastPointUpdated != null) {
        widget.onLastPointUpdated!(lastPoint);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxYValueAsli = widget.datas.values
        .expand((spots) => spots.map((spot) => spot.y))
        .fold<double>(
            0,
            (previousValue, element) =>
                element > previousValue ? element : previousValue);

    double maxYValuePrediksi = 0.0;
    if (widget.predictionPointWidget != null &&
        widget.predictionPointWidget! > 0) {
      maxYValuePrediksi = widget.predictionPointWidget!;
    }

    double maxYValue =
        maxYValueAsli > maxYValuePrediksi ? maxYValueAsli : maxYValuePrediksi;
    double maxY = maxYValue + (maxYValue * 0.2);
    double interval = (maxY > 0) ? (maxY / 5) : 1.0;


    List<FlSpot> lastDataPoints = widget.datas[selectedMonth] ?? [];
    FlSpot? lastPoint = lastDataPoints.isNotEmpty ? lastDataPoints.first : null;

    FlSpot? predictionPoint;
    predictionPointValue = widget.predictionPointWidget ?? 0.0;
    if (lastPoint != null && widget.title == 'Produksi Susu') {
      predictionPoint = FlSpot(lastPoint.x + 1, predictionPointValue);
    }

    double chartWidth = lastDataPoints.length * 50.0;
    chartWidth = chartWidth < 330 ? 330 : chartWidth;

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
            widget.title,
            style: const TextStyle(
              color: Color(0xFFC35804),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Bulan : ',
                style: TextStyle(
                  color: Color(0xFF8F3505),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: widget.datas.isNotEmpty &&
                        widget.datas.containsKey(selectedMonth)
                    ? selectedMonth
                    : null,
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFFC35804)),
                items: widget.datas.keys.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(
                      month,
                      style: const TextStyle(color: Color(0xFFC35804)),
                    ),
                  );
                }).toList(),
                onChanged: widget.datas.isNotEmpty
                    ? (String? newValue) {
                        if (newValue != null &&
                            widget.datas.containsKey(newValue)) {
                          setState(() {
                            selectedMonth = newValue;
                            _updateLastPoint();
                          });
                        }
                      }
                    : null, // Nonaktifkan dropdown jika tidak ada data
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: widget.datas.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth * 0.85,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: interval,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final day = (value.toInt() ).toString();
                                  return Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
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
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: lastDataPoints ?? [],
                              isCurved: true,
                              color: const Color(0xFFE6B87D),
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                            if (predictionPoint != null &&
                                widget.title == 'Produksi Susu')
                              LineChartBarData(
                                spots: [lastPoint!, predictionPoint],
                                isCurved: true,
                                color: const Color(0xFFC35804),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                                dashArray: [5, 8],
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFE6B87D)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Data Asli'),
                ],
              ),
              const SizedBox(width: 16),
              if (predictionPoint != null && widget.title == 'Produksi Susu')
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFC35804)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Data Prediksi'),
                  ],
                ),
            ],
          ),
          if (widget.otherInfo?.isNotEmpty ?? false || widget.valueInfo != null)
            const SizedBox(height: 16),
          if (widget.otherInfo?.isNotEmpty ?? false || widget.valueInfo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.otherInfo?.isNotEmpty ?? false)
                    Text(
                      widget.otherInfo ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8F3505),
                      ),
                    ),
                  if (widget.valueInfo != null)
                    Text(
                      '${widget.valueInfo} Kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8F3505),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
