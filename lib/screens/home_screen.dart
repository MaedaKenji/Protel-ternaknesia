import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  late Future<List<Map<String, String>>> _futureSummaryData;
  Future<Map<String, List<FlSpot>>> _futureChartData = Future.value({});

//     return [
//       BarChartGroupData(
//         x: 0,
//         barRods: [
//           BarChartRodData(
//             borderRadius: const BorderRadius.all(Radius.circular(0)),
//             toY: 500,
//             color: const Color(0xFFE6B87D),
//             width: 20,
//           ),
//         ],
//       ),
//       BarChartGroupData(
//         x: 1,
//         barRods: [
//           BarChartRodData(
//             borderRadius: const BorderRadius.all(Radius.circular(0)),
//             toY: 250,
//             color: const Color(0xFFE6B87D),
//             width: 20,
//           ),
//         ],
//       ),
//       BarChartGroupData(
//         x: 2,
//         barRods: [
//           BarChartRodData(
//             borderRadius: const BorderRadius.all(Radius.circular(0)),
//             toY: 900,
//             color: const Color(0xFFE6B87D),
//             width: 20,
//           ),
//         ],
//       ),
//       BarChartGroupData(
//         x: 3,
//         barRods: [
//           BarChartRodData(
//             borderRadius: const BorderRadius.all(Radius.circular(0)),
//             toY: 100,
//             color: const Color(0xFFE6B87D),
//             width: 20,
//           ),
//         ],
//       ),
//     ];
//   }
  @override
  void initState() {
    super.initState();
    _futureChartData = _fetchChartData();
    _futureSummaryData = _fetchSummaryData();
  }

  Future<List<Map<String, String>>> _fetchSummaryData() async {
    final baseUrl = dotenv.env['BASE_URL']!;
    final port = dotenv.env['PORT']!;
    final endpoints = {
      'susu': '/api/cows/susu',
      'sapi_diperah': '/api/cows/sapi_diperah',
      'sapi_diberi_pakan': '/api/cows/sapi_diberi_pakan',
    };

    try {
      final responses = await Future.wait([
        _fetchWithTimeout('$baseUrl:$port${endpoints['susu']}'),
        _fetchWithTimeout('$baseUrl:$port${endpoints['sapi_diperah']}'),
        _fetchWithTimeout('$baseUrl:$port${endpoints['sapi_diberi_pakan']}'),
      ]);

      // Tentukan subtitle berdasarkan nilai yang dikembalikan
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
      // Jika terjadi error global
      return [
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
      ];
    }
  }

  Future<String> _fetchWithTimeout(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5)); // Timeout 5 detik
      final value = json.decode(response.body)['value'].toString();
      return value;
    } catch (e) {
      if (e is TimeoutException) {
        print('Timeout while fetching $url');
        return '0'; // Return '0' if timeout
      }
      print('Error while fetching $url: $e');
      return 'Error'; // Return 'Error' for other exceptions
    }
  }

Future<Map<String, List<FlSpot>>> _fetchChartData() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://defaulturl.com';
    final port = dotenv.env['PORT'] ?? '8080';
    final url = '$baseUrl:$port/api/data/chart'; // API endpoint for chart data

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final rawData =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Transform the raw data into the required Map<String, List<FlSpot>> format
        Map<String, List<FlSpot>> chartData = {};
        for (var entry in rawData) {
          final month =
              entry['month'] as String; // Example: 'Oktober', 'November'
          final points = (entry['data'] as List<dynamic>?)
                  ?.map((point) => FlSpot(
                        (point['x'] as num?)?.toDouble() ?? 0.0,
                        (point['y'] as num?)?.toDouble() ?? 0.0,
                      ))
                  .toList() ??
              [];

          chartData[month] = points;
        }

        return chartData;
      } else {
        // Return a default value indicating an error
        return {
          'Error': [FlSpot(0, 0)] // Example default value
        };
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      // Return a default value indicating an error
      return {
        'Error': [FlSpot(0, 0)] // Example default value
      };
    }
  }


  Future<void> _refreshData() async {
    setState(() {
      _futureSummaryData = _fetchSummaryData();
      _futureChartData = _fetchChartData();
      print('Chart datanya = $_futureSummaryData');
    });
    await _futureSummaryData;
    await _futureChartData;
    _futureChartData.then((data) {
      print(data); // Ini akan mencetak data saat Future selesai
    }).catchError((error) {
      print('Error: $error'); // Jika terjadi error
    });
  }

  Widget build(BuildContext context) {
    String displayName = 'Atha Rafifi Azmi';
    displayName = displayName.toUpperCase();

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          child: Column(
            children: [
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
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SAPYY',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8F3505),
                                    )),
                                Text('Selamat Bekerja!',
                                    style: TextStyle(
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
                                    Text('Hai, $displayName',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                    const Text(
                                      'Peternak',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    const Text(
                                      'Sabtu, 26 Oktober 2024',
                                      style: TextStyle(
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
              const SizedBox(height: 60),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(0.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SummaryCards(),
                        const SizedBox(height: 16),

                        FutureBuilder<Map<String, List<FlSpot>>>(
                          future: _futureChartData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: SizedBox.shrink());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData) {
                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    CustomLineChart(
                                      title: 'Berat Pangan Hijauan',
                                      datas: snapshot.data!,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const Center(
                                  child: Text('Tidak ada data'));
                            }
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
