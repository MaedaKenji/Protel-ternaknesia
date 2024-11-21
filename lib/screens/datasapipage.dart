import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:ternaknesia/components/custom_pop_up_dialog.dart';
import 'package:ternaknesia/components/multi_chart_container.dart';
import 'package:ternaknesia/components/sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataSapiPage extends StatefulWidget {
  final String id;
  final String gender;
  final String age;
  final String healthStatus;

  const DataSapiPage({
    super.key,
    required this.id,
    required this.gender,
    required this.age,
    required this.healthStatus,
  });

  @override
  _DataSapiPageState createState() => _DataSapiPageState();
}

class _DataSapiPageState extends State<DataSapiPage> {
  List<double> beratBadan = [];
  List<double> susu = [];
  List<double> pakanHijau = [];
  List<double> pakanSentrat = [];

  bool isLoading = false;
  String errorMessage = '';

  final Map<String, Map<String, List<FlSpot>>> feedData = {
    'Pakan Hijau': {
      'Januari': [
        const FlSpot(0, 30),
        const FlSpot(1, 35),
        const FlSpot(2, 40)
      ],
      'Februari': [
        const FlSpot(0, 32),
        const FlSpot(1, 33),
        const FlSpot(2, 36)
      ],
    },
    'Pakan Sentrat': {
      'Januari': [
        const FlSpot(0, 20),
        const FlSpot(1, 25),
        const FlSpot(2, 30)
      ],
      'Februari': [
        const FlSpot(0, 22),
        const FlSpot(1, 23),
        const FlSpot(2, 26)
      ],
    },
  };

  final Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
    'Produksi Susu': {
      'Januari': [
        const FlSpot(0, 50),
        const FlSpot(1, 55),
        const FlSpot(2, 60)
      ],
      'Februari': [
        const FlSpot(0, 52),
        const FlSpot(1, 53),
        const FlSpot(2, 56)
      ],
    },
    'Berat Badan': {
      'Januari': [
        const FlSpot(0, 70),
        const FlSpot(1, 72),
        const FlSpot(2, 75)
      ],
      'Februari': [
        const FlSpot(0, 68),
        const FlSpot(1, 69),
        const FlSpot(2, 71)
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/${widget.id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          beratBadan = List<double>.from(data['recent_weights']
                  ?.map((item) => double.parse(item['weight'] ?? '0')) ??
              []);

          susu = List<double>.from(data['recent_milk_production']?.map(
                  (item) => double.parse(item['production_amount'] ?? '0')) ??
              []);
          pakanHijau = List<double>.from(data['recent_feed_hijauan']
                  ?.map((item) => double.parse(item['amount'] ?? '0')) ??
              []);
          pakanSentrat = List<double>.from(data['recent_feed_sentrate']
                  ?.map((item) => double.parse(item['amount'] ?? '0')) ??
              []);
        });
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildHeader(
      {required String id,
      required String gender,
      required String age,
      required String healthStatus}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID SAPI: $id',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E2B5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFC35804),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/images/cow_alt.png'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CustomPopUpDialog(
                                          title: 'ID SAPI',
                                          content: id,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    id,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8F3505),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildCowIndicator(
                                isHealthy:
                                    healthStatus.toUpperCase() == 'SEHAT',
                                isMale: gender.toUpperCase() == 'JANTAN',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCowInfo(
                                'Berat',
                                '350 Kg',
                                MaterialSymbols.weight,
                              ),
                              _buildCowInfo(
                                  'Umur', age, MaterialSymbols.calendar_month),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCowInfo(String label, String value, String icon) {
    return Expanded(
      child: Row(children: [
        Iconify(
          icon,
          size: 32,
          color: const Color(0xFF8F3505),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8F3505),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildCowIndicator({required bool isHealthy, required bool isMale}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              isHealthy ? Colors.green.shade300 : Colors.red.shade300,
              isHealthy ? Colors.green.shade600 : Colors.red.shade600,
            ]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHealthy ? Icons.check : Icons.error,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                isHealthy ? 'SEHAT' : 'SAKIT',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              isMale ? Colors.blue.shade300 : Colors.pink.shade300,
              isMale ? Colors.blue.shade600 : Colors.pink.shade600,
            ]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMale ? Icons.male : Icons.female,
                color: Colors.white,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                top: 200, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUKSI SUSU & BERAT BADAN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F3505),
                  ),
                ),
                const SizedBox(height: 10),
                MultiChartContainer(chartsData: milkAndWeightData),
                const SizedBox(height: 25),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                const SizedBox(height: 25),
                const Text(
                  'PAKAN YANG DIBERIKAN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F3505),
                  ),
                ),
                const SizedBox(height: 10),
                MultiChartContainer(chartsData: feedData),
                const SizedBox(height: 25),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                const SizedBox(height: 25),
                ConditionsSection(healthStatus: widget.healthStatus),
                const SizedBox(height: 20),
                const PopulationStructureSection(),
                const SizedBox(height: 20),
                const Text(
                  'CATATAN :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      color: Color(0xFF8F3505),
                    ),
                    hintStyle: const TextStyle(
                      color: Color(0xFF8F3505),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8F3505)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8F3505)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8F3505)),
                    ),
                    hintText: 'Masukkan catatan',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFFECEC),
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFFFF3939)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'KELUARKAN SAPI DARI KANDANG',
                      style: TextStyle(
                        color: Color(0xFFE33629),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
              ],
            ),
          ),
          _buildHeader(
            id: widget.id,
            gender: widget.gender,
            age: widget.age,
            healthStatus: widget.healthStatus,
          )
        ],
      ),
    );
  }
}
