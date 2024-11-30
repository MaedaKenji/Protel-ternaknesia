import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/custom_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ternaknesia/components/dialogs.dart';
import 'package:ternaknesia/provider/user_role.dart';

class MultiChartContainer extends StatefulWidget {
  final String label;
  final Map<String, Map<String, List<FlSpot>>> chartsData;
  final Map<String, List<Map<String, dynamic>>> historyData;
  final Function(int) onDelete;
  final String id;

  const MultiChartContainer(
      {super.key,
      required this.label,
      required this.chartsData,
      required this.historyData,
      required this.onDelete,
      required this.id});

  @override
  State<MultiChartContainer> createState() => _MultiChartContainerState();
}

class _MultiChartContainerState extends State<MultiChartContainer> {
  late List<String> chartTitles;
  int currentIndex = 0;
  late Map<String, TextEditingController> inputControllers;

  get http => null;

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

  Future<void> _sendDataToServer(Map<String, String> data) async {
    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/tambahdata/${widget.id}');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil dikirim ke server")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengirim data ke server")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print(e);
    }
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
        print("Data baru: $data akan mulai mengirim ke server");
        _sendDataToServer({chartTitles[currentIndex]: data});
      }
    });
  }

  String formatTitle(String title) {
    String formattedTitle =
        title.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
      return '${match.group(1)} ${match.group(2)}';
    });

    formattedTitle = formattedTitle.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return formattedTitle;
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);
    final String currentTitle = chartTitles[currentIndex];
    final Map<String, List<FlSpot>> currentData =
        widget.chartsData[currentTitle]!;
    final List<Map<String, dynamic>> currentHistoryData =
        widget.historyData[currentTitle] ?? [];
    final formattedTitle = formatTitle(currentTitle);
    print("$formattedTitle adalah: $currentData");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomLineChart(
                title: formattedTitle,
                datas: currentData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
            const SizedBox(height: 10),
            if (userRole.role == 'user')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(
                    icon: Icons.add,
                    onPressed: _addNewData,
                  ),
                  const SizedBox(width: 10),
                  _buildIconButton(
                      icon: Icons.history,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return HistoryDialog(
                              title: 'Riwayat $formattedTitle',
                              data: currentHistoryData,
                              onDelete: widget.onDelete,
                            );
                          },
                        );
                      }),
                ],
              ),
            if (userRole.role == 'admin' || userRole.role == 'doctor')
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return HistoryDialog(
                          title: '',
                          data: currentHistoryData,
                          onDelete: widget.onDelete);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFC35804),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text('Riwayat', style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
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
                'Grafik ${currentIndex + 1} dari ${chartTitles.length}',
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

  Widget _buildIconButton({required IconData icon, required onPressed}) {
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
