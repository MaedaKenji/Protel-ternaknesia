import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ignore: must_be_immutable
class CustomLineChart extends StatefulWidget {
  final String title;
  String? otherInfo;
  int? valueInfo;
  final Map<String, List<FlSpot>> datas;

  CustomLineChart({
    super.key,
    required this.title,
    this.otherInfo,
    this.valueInfo,
    required this.datas,
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late String selectedMonth;

  @override
  void initState() {
    super.initState();

    selectedMonth =
        widget.datas.isNotEmpty ? widget.datas.keys.first : 'Default';
  }

  @override
  Widget build(BuildContext context) {
    double maxYValue = widget.datas.values
        .expand((spots) => spots.map((spot) => spot.y))
        .fold<double>(
            0,
            (previousValue, element) =>
                element > previousValue ? element : previousValue);

    double maxY = maxYValue + (maxYValue * 0.2);
    double interval = maxY / 5;

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
                value: widget.datas.containsKey(selectedMonth)
                    ? selectedMonth
                    : widget.datas.keys.firstOrNull ?? 'Default',
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
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue ??
                        (widget.datas.keys.isNotEmpty
                            ? widget.datas.keys.first
                            : 'Default');
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: widget.datas.isNotEmpty
                ? LineChart(
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
                              final day = (value.toInt() + 1).toString();
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
                          spots: widget.datas[selectedMonth] ?? [],
                          isCurved: true,
                          color: const Color(0xFFC35804),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
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
          if (widget.otherInfo?.isNotEmpty ?? false || widget.valueInfo != null)
            const SizedBox(height: 16),
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
