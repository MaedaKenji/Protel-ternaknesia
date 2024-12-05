import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/custom_pop_up_dialog.dart';
import 'package:ternaknesia/provider/user_role.dart';
import 'package:ternaknesia/screens/datasapipage.dart';
import '../components/summary_cards.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ternaknesia/components/custom_line_chart.dart';
import 'package:ternaknesia/components/custom_bar_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  Future<List<Map<String, String>>> _futureSummaryData = Future.value([]);
  Map<String, List<FlSpot>> milkProductionData = {};
  Map<String, List<FlSpot>> greenFodderData = {};
  Map<String, List<FlSpot>> concentratedFodderData = {};
  final Map<String, List<FlSpot>> exampleServerData = {
    'September 2023': [
      const FlSpot(29.0, 15.0),
    ],
    'Oktober 2023': [
      const FlSpot(0.0, 32.0),
      const FlSpot(1.0, 30.0),
      const FlSpot(2.0, 34.0),
      const FlSpot(3.0, 28.0),
      const FlSpot(4.0, 26.0),
      const FlSpot(5.0, 30.0),
      const FlSpot(6.0, 28.0),
      const FlSpot(7.0, 32.0),
      const FlSpot(8.0, 30.0),
      const FlSpot(9.0, 25.0),
      const FlSpot(10.0, 0.0),
    ],
    'November 2024': [
      const FlSpot(14.0, 0.0),
    ],
  };
  int? hijauanWeight;
  int? sentratWeight;

  @override
  void initState() {
    super.initState();
    _futureSummaryData = _fetchSummaryData(); // Inisialisasi _futureSummaryData
    _refreshData();
  }

  Future<List<Map<String, String>>> _fetchSummaryData() async {
    final baseUrl = dotenv.env['BASE_URL']!;
    final port = dotenv.env['PORT']!;
    final endpoints = {
      'susu': '/api/cows/data/susu',
      'sapi_diperah': '/api/cows/data/sapi_diperah',
      'sapi_diberi_pakan': '/api/cows/data/sapi_diberi_pakan',
    };

    try {
      final responses = await Future.wait([
        _fetchWithTimeout('$baseUrl:$port${endpoints['susu']}'),
        _fetchWithTimeout('$baseUrl:$port${endpoints['sapi_diperah']}'),
        _fetchWithTimeout('$baseUrl:$port${endpoints['sapi_diberi_pakan']}'),
      ]);

      return [
        {
          'title': responses[0],
          'subtitle': responses[0] == '' || responses[0] == 'Error'
              ? 'Tidak ada data dari server'
              : 'Perolehan susu hari ini',
        },
        {
          'title': responses[1],
          'subtitle': responses[1] == '' || responses[1] == 'Error'
              ? 'Tidak ada data dari server'
              : 'Sapi yang telah diperah',
        },
        {
          'title': responses[2],
          'subtitle': responses[2] == '' || responses[2] == 'Error'
              ? 'Tidak ada data dari server'
              : 'Sapi yang telah diberi pakan',
        },
      ];
    } catch (e) {
      return [
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
      ];
    }
  }

  Future<Map<String, Map<String, List<FlSpot>>>> _fetchChartData() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://defaulturl.com';
    final port = dotenv.env['PORT'] ?? '8080';
    final url = '$baseUrl:$port/api/data/chart';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final rawData =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        Map<String, Map<String, List<FlSpot>>> chartData = {
          'Hijauan': {},
          'Sentrate': {},
          'Milk': {},
        };

        for (var entry in rawData) {
          final date = DateTime.parse(entry['date']);
          final monthYear = _monthYear(date);
          final day = date.day.toDouble() - 1;

          chartData['Hijauan']?[monthYear] ??= [];
          chartData['Sentrate']?[monthYear] ??= [];
          chartData['Milk']?[monthYear] ??= [];

          chartData['Hijauan']?[monthYear]
              ?.add(FlSpot(day, (entry['hijauan'] as num).toDouble()));
          chartData['Sentrate']?[monthYear]
              ?.add(FlSpot(day, (entry['sentrate'] as num).toDouble()));
          chartData['Milk']?[monthYear]
              ?.add(FlSpot(day, (entry['milk'] as num).toDouble()));
        }

        return chartData;
      } else {
        print('Error: Status code ${response.statusCode}');
        return {
          'Error': {
            'Error': [const FlSpot(0, 0)]
          }
        };
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      return {
        'Error': {
          'Error': [const FlSpot(0, 0)]
        }
      };
    }
  }

  String _monthYear(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> assignFetchedData() async {
    try {
      final fetchedData = await _fetchChartData();

      setState(() {
        milkProductionData = fetchedData['Milk'] ?? {};
        greenFodderData = fetchedData['Hijauan'] ?? {};
        concentratedFodderData = fetchedData['Sentrate'] ?? {};
      });
    } catch (e) {
      print('Error assigning fetched data: $e');

      setState(() {
        milkProductionData = {};
        greenFodderData = {};
        concentratedFodderData = {};
      });
    }
  }

  Future<String> _fetchWithTimeout(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      final value = json.decode(response.body)['value'].toString();
      return value;
    } catch (e) {
      if (e is TimeoutException) {
        print('Timeout while fetching $url');
        return '0';
      }
      print('Error while fetching $url: $e');
      return 'Error';
    }
  }

  Future<void> fetchBestCombination() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://defaulturl.com';
    final port = dotenv.env['PORT'] ?? '8080';
    final url2 = '$baseUrl:$port/api/cluster';
    final url = Uri.parse(url2);
    // print(url);

    // final url = Uri.parse(
    //     'http://localhost:8080/api/cluster'); // Ganti dengan endpoint API Anda
    // print(url);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            hijauanWeight = data['data']['hijauan_weight'] ?? 0;
            sentratWeight = data['data']['sentrat_weight'] ?? 0;
          });
        } else {
          throw Exception('Failed to fetch data');
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _refreshData() async {
    try {
      final summaryData = await _fetchSummaryData();

      setState(() {
        _futureSummaryData = Future.value(summaryData);
      });

      _futureSummaryData = Future.value(summaryData);

      await assignFetchedData();
      await fetchBestCombination();
      await _fetchSummaryData();
    } catch (e) {
      print("Error during refresh: $e");
    }
  }

  final List<Map<String, dynamic>> sickIndicated = [
    {
      'id': '001',
      'gender': 'Betina',
      'info': 'Tidak nafsu makan dan mata merah',
      'checked': true,
      'isConnectedToNFCTag': false,
      'age': '2 Tahun',
    },
    {
      'id': '002',
      'gender': 'Jantan',
      'info': 'Diare',
      'checked': false,
      'isConnectedToNFCTag': true,
      'age': '3 Tahun',
    },
    {
      'id': '003',
      'gender': 'Betina',
      'info': 'Luka di mulut dan demam',
      'checked': false,
      'isConnectedToNFCTag': true,
      'age': '1 Tahun',
    },
    {
      'id': '004',
      'gender': 'Betina',
      'info': 'Kaki pincang',
      'checked': false,
      'isConnectedToNFCTag': false,
      'age': '2 Tahun',
    },
  ];

  final List<Map<String, dynamic>> sickCowAndTreatment = [
    {
      'id': '005',
      'gender': 'Betina',
      'info': 'Bovine Viral Diarrhea (BVD)',
      'checked': false,
      'isConnectedToNFCTag': true,
      'age': '2 Tahun',
    },
    {
      'id': '006',
      'gender': 'Jantan',
      'info': 'Tidak nafsu makan dan mata merah',
      'checked': false,
      'isConnectedToNFCTag': false,
      'age': '3 Tahun',
    },
    {
      'id': '007',
      'gender': 'Betina',
      'info': 'Tidak nafsu makan dan mata merah',
      'checked': false,
      'isConnectedToNFCTag': true,
      'age': '1 Tahun',
    },
    {
      'id': '008',
      'gender': 'Betina',
      'info': 'Tidak nafsu makan dan mata merah',
      'checked': false,
      'isConnectedToNFCTag': false,
      'age': '2 Tahun',
    },
  ];

  List<BarChartGroupData> sickCowPerMonthData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            toY: 500,
            color: const Color(0xFFE6B87D),
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            toY: 250,
            color: const Color(0xFFE6B87D),
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            toY: 900,
            color: const Color(0xFFE6B87D),
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            toY: 100,
            color: const Color(0xFFE6B87D),
            width: 20,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);
    final displayName = userRole.name;
    final role = userRole.role == 'user'
        ? 'Peternak'
        : userRole.role == 'admin'
            ? 'Admin'
            : 'Dokter Hewan';

    DateTime now = DateTime.now();
    String formattedDate =
        MaterialLocalizations.of(context).formatFullDate(now);
    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
            onRefresh: _refreshData,
            child: Column(children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE6B87D), Color(0xFFF9E2B5)],
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
                    top: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/LogoTernaknesia.png',
                                width: 50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('SAPYY',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8F3505),
                                    )),
                                Text(formattedDate,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8F3505),
                                    )),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC35804),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF9E2B5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Image(
                                    image: AssetImage(
                                        'assets/images/profileHome.png'),
                                    width: 65),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hai, $displayName!',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                    Text(
                                      role,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              if (userRole.role == 'user' || userRole.role == 'admin')
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(children: [
                        FutureBuilder<List<Map<String, String>>>(
                          future: _futureSummaryData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final data = snapshot.data!;
                              return SummaryCards(data: data);
                            } else {
                              return const Text('No data available');
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomLineChart(
                            title: 'Hasil Perolehan Susu ',
                            datas: milkProductionData),
                        CustomLineChart(
                          title: 'Berat Pangan Hijauan',
                          datas: greenFodderData,
                          otherInfo: 'Pakan Hijauan Terbaik saat ini :',
                          valueInfo: hijauanWeight,
                        ),
                        CustomLineChart(
                          title: 'Berat Pangan Sentrat',
                          datas: concentratedFodderData,
                          otherInfo: 'Pakan Sentrat Terbaik saat ini :',
                          valueInfo: sentratWeight,
                        ),
                        CustomLineChart(
                          title: 'Contoh Data dari Server',
                          datas: exampleServerData,
                        ),
                      ])),
                ),
              if (userRole.role == 'doctor' || userRole.role == 'dokter')
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        FutureBuilder<List<Map<String, String>>>(
                          future: _futureSummaryData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final data = snapshot.data!;
                              return SummaryCards(data: data);
                            } else {
                              return const Text('No data available');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sapi Terindikasi Sakit :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8F3505),
                          ),
                        ),
                        for (var cattle in sickIndicated)
                          _buildCattleCard(
                            context,
                            id: cattle['id'],
                            gender: cattle['gender'],
                            info: cattle['info'],
                            checked: cattle['checked'] ?? false,
                            onPressed: () {
                              return DataSapiPage(
                                id: cattle['id'],
                                gender: cattle['gender'],
                                age: cattle['age'],
                                healthStatus: 'SAKIT',
                                isProductive: true,
                                isConnectedToNFCTag:
                                    cattle['isConnectedToNFCTag'],
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sapi Sakit & Dalam Pengobatan :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8F3505),
                          ),
                        ),
                        for (var cattle in sickCowAndTreatment)
                          _buildCattleCard(
                            context,
                            id: cattle['id'],
                            gender: cattle['gender'],
                            info: cattle['info'],
                            checked: cattle['checked'] ?? false,
                            onPressed: () {
                              return DataSapiPage(
                                id: cattle['id'],
                                gender: cattle['gender'],
                                age: cattle['age'],
                                healthStatus: 'SAKIT',
                                isProductive: true,
                                isConnectedToNFCTag:
                                    cattle['isConnectedToNFCTag'],
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        CustomBarChart(
                            title: 'Jumlah Sapi Sakit per Bulan',
                            data: sickCowPerMonthData()),
                      ],
                    ),
                  ),
                ),
            ])));
  }

  Widget _buildCattleCard(
    BuildContext context, {
    required String id,
    required String gender,
    required String info,
    required bool checked,
    required onPressed,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9E2B5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFC35804),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/cow_alt.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8F3505),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8F3505),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              _buildPeriksaButton(
                  onPressed: onPressed, checked: checked, context: context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriksaButton({
    required BuildContext context,
    required onPressed,
    required bool checked,
  }) {
    return ElevatedButton(
      onPressed: checked
          ? () {}
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => onPressed(),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: checked ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: checked ? Colors.green : const Color(0xFFC35804),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: checked
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : const Text(
              'Periksa',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC35804),
              ),
            ),
    );
  }
}
