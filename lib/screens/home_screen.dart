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
  Map<String, List<FlSpot>> milkProductionData = {};
  Map<String, List<FlSpot>> greenFodderData = {};
  Map<String, List<FlSpot>> concentratedFodderData = {};
  final Map<String, List<FlSpot>> exampleServerData = {
    'September 2023': [
      FlSpot(29.0, 15.0),
    ],
    'Oktober 2023': [
      FlSpot(0.0, 32.0),
      FlSpot(1.0, 30.0),
      FlSpot(2.0, 34.0),
      FlSpot(3.0, 28.0),
      FlSpot(4.0, 26.0),
      FlSpot(5.0, 30.0),
      FlSpot(6.0, 28.0),
      FlSpot(7.0, 32.0),
      FlSpot(8.0, 30.0),
      FlSpot(9.0, 25.0),
      FlSpot(10.0, 0.0),
      FlSpot(11.0, 0.0),
      FlSpot(12.0, 0.0),
      FlSpot(13.0, 0.0),
      FlSpot(14.0, 0.0),
      FlSpot(15.0, 0.0),
      FlSpot(16.0, 0.0),
      FlSpot(17.0, 0.0),
      FlSpot(18.0, 0.0),
    ],
    'November 2024': [
      FlSpot(14.0, 0.0),
    ],
  };

  @override
  void initState() {
    super.initState();
    _refreshData();
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

  Future<Map<String, Map<String, List<FlSpot>>>> _fetchChartData() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://defaulturl.com';
    final port = dotenv.env['PORT'] ?? '8080';
    final url = '$baseUrl:$port/api/data/chart'; // API endpoint for chart data

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print("body dari fetchchart = ${response.body}");
      print("statusCode dari fetchchart = ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final rawData =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Initialize the chart data structure
        Map<String, Map<String, List<FlSpot>>> chartData = {
          'Hijauan': {},
          'Sentrate': {},
          'Milk': {}, // Add milk data
        };

        // Transform the raw data
        for (var entry in rawData) {
          final date = DateTime.parse(entry['date']); // Parse the date
          final monthYear = _monthYear(date); // Convert to "Month Year" format
          final day =
              date.day.toDouble() - 1; // Use the day of the month as x-axis

          // Initialize month-year data if it doesn't exist
          chartData['Hijauan']?[monthYear] ??= [];
          chartData['Sentrate']?[monthYear] ??= [];
          chartData['Milk']?[monthYear] ??= [];

          // Add data points for hijauan, sentrate, and milk
          chartData['Hijauan']?[monthYear]
              ?.add(FlSpot(day, (entry['hijauan'] as num).toDouble()));
          chartData['Sentrate']?[monthYear]
              ?.add(FlSpot(day, (entry['sentrate'] as num).toDouble()));
          chartData['Milk']?[monthYear]
              ?.add(FlSpot(day, (entry['milk'] as num).toDouble()));
        }

        print("Response dari fetchchart = $chartData");
        return chartData;
      } else {
        print('Error: Status code ${response.statusCode}');
        return {
          'Error': {
            'Error': [FlSpot(0, 0)]
          } // Default value for error
        };
      }
    } catch (e) {
      print('Error fetching chart data: $e');
      return {
        'Error': {
          'Error': [FlSpot(0, 0)]
        } // Default value for error
      };
    }
  }

// Helper to format "Month Year"
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
      // Fetch chart data from the API
      final fetchedData = await _fetchChartData();
      print("Fetched data: $fetchedData");

      // Assign the fetched data to respective variables
      setState(() {
        milkProductionData = fetchedData['Milk'] ?? {};
        greenFodderData = fetchedData['Hijauan'] ?? {};
        concentratedFodderData = fetchedData['Sentrate'] ?? {};
      });

      print("\n");
      print("Milk Production Data: $milkProductionData");
      print("\n");
      print("Green Fodder Data: $greenFodderData");
      print("\n");
      print("Concentrated Fodder Data: $concentratedFodderData");
    } catch (e) {
      print('Error assigning fetched data: $e');

      // Assign empty data in case of an error
      setState(() {
        milkProductionData = {};
        greenFodderData = {};
        concentratedFodderData = {};
      });
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

  Future<void> _refreshData() async {
    print("Refreshing data...");
    try {
      // Fetch and assign the summary and chart data
      final summaryData = await _fetchSummaryData();
      // Update state with the fetched data
      setState(() {
        _futureSummaryData = Future.value(summaryData);
      });

      // Assign fetched chart data to specific variables
      await assignFetchedData();
      print("Chart data refreshed successfully.");
    } catch (e) {
      print("Error during refresh: $e");
    }
  }

  Widget build(BuildContext context) {
    String displayName = 'Atha Rafifi Azmi';
    displayName = displayName.toUpperCase();
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
                child: ListView(
                  children: [
                  const SummaryCards(),
                  const SizedBox(height: 16),
                  // Kalo mau pake data statis pake ini
                  // CustomLineChart(title: 'Hasil Perolehan Susu', datas: milkProductionData),
                  CustomLineChart(
                      title: 'Hasil Perolehan Susu ',
                      datas: milkProductionData),
                  CustomLineChart(
                      title: 'Berat Pangan Hijauan', datas: greenFodderData),
                  CustomLineChart(
                      title: 'Berat Pangan Sentrat',
                      datas: concentratedFodderData),
                  CustomLineChart(
                    title: 'Contoh Data dari Server',
                    datas:
                        exampleServerData, // Data statis menyerupai hasil server
                  ),
                ]
                ),
                
                

                // RefreshIndicator(
                //     onRefresh: _refreshData,
                //     child: ListView(
                //         physics: const AlwaysScrollableScrollPhysics(),
                //         padding: const EdgeInsets.all(0.0),
                //         children: []))
              )
            ])));
  }
}
//   @override
//   Widget build(BuildContext context) {
//     String displayName = 'Atha Rafifi Azmi';
//     displayName = displayName.toUpperCase();
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(children: [
//          ]));
//   }
// }
