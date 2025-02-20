import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/custom_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class MultiChartContainer extends StatefulWidget {
  final String label;
  final Map<String, Map<String, List<FlSpot>>> chartsData;
  final Map<String, List<Map<String, dynamic>>> historyData;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final String id;
  final VoidCallback? onHistoryPressed;
  double predictionSusu = 0.0;
  double susuSaatIni = 0;
  double beratSaatIni = 0;
  double pakanHijauSaatIni = 0;
  double pakanSentratSaatIni = 0;

  MultiChartContainer(
      {super.key,
      required this.label,
      required this.chartsData,
      required this.historyData,
      required this.onEdit,
      required this.onDelete,
      required this.id,
      this.predictionSusu = 0.0,
      this.onHistoryPressed});

  @override
  State<MultiChartContainer> createState() => _MultiChartContainerState();
}

class _MultiChartContainerState extends State<MultiChartContainer> {
  late List<String> chartTitles;
  int currentIndex = 0;
  late Map<String, TextEditingController> inputControllers;
  FlSpot? lastSpot; // Variabel untuk menyimpan nilai terakhir
  List<FlSpot?> lastSpots = []; // Menyimpan nilai lastSpot setiap halaman

  @override
  void initState() {
    super.initState();
    chartTitles = widget.chartsData.keys.toList();

    inputControllers = {
      for (var title in chartTitles) title: TextEditingController(text: '1')
    };

    // Inisialisasi list lastSpots sesuai jumlah halaman
    lastSpots = List<FlSpot?>.generate(
      widget.chartsData.length,
      (index) => widget.chartsData[chartTitles[index]]?.isNotEmpty == true
          ? widget.chartsData[chartTitles[index]]!.values.expand((e) => e).first
          : null,
    );
    lastSpot = lastSpots[currentIndex];
  }

  // Callback untuk menangani nilai terakhir
  void _handleLastPointUpdatedOnPageChange(int pageIndex) {
    setState(() {
      lastSpot = lastSpots[pageIndex];
    });
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
        ShowResultDialog.show(context, true,
            customMessage: 'Data berhasil dikirim ke server');
        Future.delayed(const Duration(seconds: 2), () {
        });
      } else {
        final errorDetails = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ?? 'Tidak ada detail error'
            : 'Response kosong dari server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal mengirim data ke server dari multi chart, error $errorDetails")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
    final List<Map<String, dynamic>> currentHistoryData =
        widget.historyData[currentTitle] ?? [];
    final formattedTitle = formatTitle(currentTitle);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 400,
            child: PageView.builder(
              itemCount: chartTitles.length,
              itemBuilder: (context, index) {
                final String title = chartTitles[index];
                final data = widget.chartsData[title]!;
                return CustomLineChart(
                  title: formatTitle(title),
                  datas: data,
                  predictionPointWidget: widget.predictionSusu,
                  // onLastPointUpdated: (point) => _handleLastPointUpdated(point, index), // Tambahkan index
                );
              },
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  lastSpot =
                      lastSpots[index]; // Perbarui nilai berdasarkan halaman
                });
                _handleLastPointUpdatedOnPageChange(index);
              },
            ),
          ),
          const SizedBox(height: 10),
          // EDIT DATA UNTUK TAMBAH DAN RIWAYAT
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (userRole.role == 'user')
                    Row(
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
                                    onEdit: (int index) {
                                      Navigator.of(context).pop();
                                      print(
                                          "date: ${currentHistoryData[index]['date']}");

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return EditDataDialog(
                                              id: widget.id,
                                              title: formattedTitle,
                                              initialData:
                                                  currentHistoryData[index]
                                                      ['data'],
                                              date: currentHistoryData[index]
                                                  ['date'],
                                            );
                                          });
                                    },
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
                                title: 'Riwayat $formattedTitle',
                                data: currentHistoryData,
                                onEdit: widget.onEdit,
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
                          borderRadius: BorderRadius.circular(10.0),
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
                          Text('Riwayat',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      const Text(
                        'Saat ini:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC35804),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFC35804),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${lastSpot?.y.toStringAsFixed(2) ?? '-'} ${currentTitle == 'produksiSusu' ? 'L' : 'Kg'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
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
