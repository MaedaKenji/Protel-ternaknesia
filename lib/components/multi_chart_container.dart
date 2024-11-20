import 'package:flutter/material.dart';
import 'package:ternaknesia/components/custom_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ternaknesia/components/dialogs.dart';

class MultiChartContainer extends StatefulWidget {
  final Map<String, Map<String, List<FlSpot>>> chartsData;

  const MultiChartContainer({super.key, required this.chartsData});

  @override
  State<MultiChartContainer> createState() => _MultiChartContainerState();
}

class _MultiChartContainerState extends State<MultiChartContainer> {
  late List<String> chartTitles;
  int currentIndex = 0;
  late Map<String, TextEditingController> inputControllers;

  @override
  void initState() {
    super.initState();
    chartTitles = widget.chartsData.keys.toList();

    inputControllers = {
      for (var title in chartTitles) title: TextEditingController(text: '0')
    };
  }

  @override
  void dispose() {
    for (var controller in inputControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextChart() {
    setState(() {
      currentIndex = (currentIndex + 1) % chartTitles.length;
    });
  }

  void _previousChart() {
    setState(() {
      currentIndex = (currentIndex - 1) % chartTitles.length;
      if (currentIndex < 0) currentIndex = chartTitles.length - 1;
    });
  }

  void _addNewData() {
    showDialog(
      context: context,
      builder: (context) => NewDataDialog(
        id: currentIndex.toString(),
      ),
    ).then((data) {
      if (data != null && data.isNotEmpty) {
        setState(() {
          inputControllers[chartTitles[currentIndex]]!.text = data;
        });
        print("Data baru: $data");
      }
    });
  }

  void _showHistory() async {
    List<String> historyData = ['70 Kg', '65 Kg', '72 Kg', '68 Kg'];
    await showDialog(
      context: context,
      builder: (context) {
        return HistoryDialog(
          data: historyData,
          onDelete: (index) {
            setState(() {
              historyData.removeAt(index);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentTitle = chartTitles[currentIndex];
    final Map<String, List<FlSpot>> currentData =
        widget.chartsData[currentTitle]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomLineChart(
                title: currentTitle,
                datas: currentData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text(
                  'Saat ini :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: inputControllers[currentTitle],
                    cursorColor: const Color(0xFFC35804),
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFC35804).withOpacity(0.1),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC35804)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC35804)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC35804)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Kg',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.add,
                  onPressed: _addNewData,
                ),
                const SizedBox(width: 10),
                _buildIconButton(
                  icon: Icons.history,
                  onPressed: _showHistory,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousChart,
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFFC35804)),
            ),
            Center(
              child: Text(
                'Chart ${currentIndex + 1} dari ${chartTitles.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC35804),
                ),
              ),
            ),
            IconButton(
              onPressed: _nextChart,
              icon: const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFFC35804)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFC35804),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}
