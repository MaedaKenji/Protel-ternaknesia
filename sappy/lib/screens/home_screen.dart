import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sappy/components/custom_pop_up_dialog.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:sappy/screens/datasapipage.dart';
import '../components/summary_cards.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sappy/components/custom_line_chart.dart';
import 'package:sappy/components/custom_bar_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Map<String, String>>> _futureSummaryData = Future.value([]);
  Future<List<Map<String, String>>> _futureSakitData = Future.value([]);

  Map<String, List<FlSpot>> milkProductionData = {};
  Map<String, List<FlSpot>> greenFodderData = {};
  Map<String, List<FlSpot>> concentratedFodderData = {};
  List<Map<String, dynamic>> susuBulanan = [];
  List<Map<String, dynamic>> sickIndicatedDinamis = [];
  double? hijauanWeight;
  double? sentratWeight;
  double predictedNextMonth = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _refreshData();
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
      setState(() {
        milkProductionData = {};
        greenFodderData = {};
        concentratedFodderData = {};
      });
    }
  }

  void parseSusuBulanan(List<dynamic> jsonData) {
    susuBulanan = jsonData.map((item) {
      return {
        'bulan': item['bulan'] as String,
        'totalProduksi': item['totalProduksi'].toDouble(),
      };
    }).toList();
    setState(() {
      susuBulanan = susuBulanan;
    });
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

  List<BarChartGroupData> milkProductionPerMonth() {
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

  List<BarChartGroupData> milkProductionPerMonthDynamics() {
    return List.generate(susuBulanan.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            toY: susuBulanan[index]['totalProduksi'],
            color: const Color(0xFFE6B87D),
            width: 20,
          ),
        ],
      );
    });
  }

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

  Future<String> _fetchWithTimeout(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      final value = json.decode(response.body)['value'].toString();
      return value;
    } catch (e) {
      if (e is TimeoutException) {
        return '0';
      }
      return 'Error';
    }
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
      final stopwatch = Stopwatch()..start();
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      // Berhentikan timer
      stopwatch.stop();

      // Hitung waktu respons dalam detik
      final responseTimeInSeconds = stopwatch.elapsedMilliseconds / 1000;

      // Tampilkan waktu respons
      // debugPrint('Response Time: $responseTimeInSeconds detik');

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
        debugPrint(
            'Failed to fetch chart data. Status code: ${response.statusCode}');
        return {
          'Error': {
            'Error': [const FlSpot(0, 0)]
          }
        };
      }
    } catch (e) {
      debugPrint(
        'Error fetching chart data: $e',
      );

      return {
        'Error': {
          'Error': [const FlSpot(0, 0)]
        }
      };
    }
  }

  Future<void> fetchBestCombination() async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cluster'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            hijauanWeight = double.parse(
                (data['data']['hijauan_weight'] ?? 0).toStringAsFixed(2));
            sentratWeight = double.parse(
                (data['data']['sentrat_weight'] ?? 0).toStringAsFixed(2));
          });
        } else {
          setState(() {
            hijauanWeight = 0;
            sentratWeight = 0;
          });
        }
      } else {
        setState(() {
          hijauanWeight = 0;
          sentratWeight = 0;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Gagal memuat data kombinasi pakan terbaik'),
        //   ),
        // );
      }
    } catch (e) {}
  }

  Future<void> _fetchBulananDanPredict() async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/predict/monthly'),
          )
          .timeout(const Duration(seconds: 5));

      final responseData = json.decode(response.body);
      double newPrediction = 0;
      if (responseData['success'] == true) {
        if (responseData['nextMonthPrediction'] is num) {
          newPrediction =
              (responseData['nextMonthPrediction'] as num).toDouble();
        } else {
          newPrediction = 0;
        }
      } else {
        newPrediction = 0;
      }

      parseSusuBulanan(responseData['data']);

      setState(() {
        predictedNextMonth = newPrediction;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Gagal memuat data'),
      //   ),
      // );
    }
  }

  Future<void> fetchSickIndicatedDinamis() async {
    String apiUrl =
        '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/dokter-home'; // Ganti dengan URL API Anda
    try {
      final response =
          await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Asumsikan API mengembalikan list of maps
        setState(() {
          sickIndicatedDinamis = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data'),
        ),
      );
    }
  }

  Future<List<Map<String, String>>> _fetchSakitData() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final port = dotenv.env['PORT'];
    final url = '$baseUrl:$port/api/data/summary/dokter';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        // Mengolah data dari JSON response
        final Map<String, String> dataMap = {
          for (var item in jsonResponse)
            item['status_kesehatan']: item['total'],
        };

        return [
          {
            'value': dataMap['sehat'] ?? '0',
            'subtitle': 'Sapi sehat',
          },
          {
            'value': dataMap['sakit'] ?? '0',
            'subtitle': 'Sapi terindikasi sakit',
          },
          {
            'value': '0',
            'subtitle': 'Sapi dalam pengobatan',
          },
        ];
      } else {
        // Handle jika status code bukan 200
        return [
          {'title': 'Error', 'subtitle': 'Gagal mengambil data dari server'},
          {'title': 'Error', 'subtitle': 'Gagal mengambil data dari server'},
          {'title': 'Error', 'subtitle': 'Gagal mengambil data dari server'},
        ];
      }
    } catch (e) {
      // Handle jika terjadi kesalahan
      return [
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
        {'title': 'Error', 'subtitle': 'Tidak ada data dari server'},
      ];
    }
  }

  Future<void> _refreshData() async {
    final rolerRole = Provider.of<UserRole>(context, listen: false).role;

    setState(() {
      isLoading = true;
    });

    try {
      if (rolerRole == 'dokter' || rolerRole == 'doctor') {
        final summarySakit = await _fetchSakitData();

        setState(() {
          _futureSakitData = Future.value(summarySakit);
        });

        await fetchSickIndicatedDinamis();
      } else {
        final summaryData = await _fetchSummaryData();

        setState(() {
          _futureSummaryData = Future.value(summaryData);
        });

        await assignFetchedData();
        await fetchBestCombination();
        await _fetchBulananDanPredict();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height * 0.2,
        elevation: 0,
        leading: null,
        flexibleSpace: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: kToolbarHeight * 2.8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          const Text(
                            'SAPYY',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8F3505),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8F3505),
                            ),
                          ),
                        ],
                      ),
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
                        CircleAvatar(
                          backgroundImage: userRole.role == 'user'
                              ? const AssetImage('assets/images/farmer.png')
                              : userRole.role == 'admin'
                                  ? const AssetImage('assets/images/admin.png')
                                  : const AssetImage(
                                      'assets/images/doctor.png'),
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hai, $displayName!',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              role,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.white,
              child: Column(
                children: [
                  if (userRole.role == 'user' || userRole.role == 'admin')
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
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
                                } else if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  final data = snapshot.data!;
                                  return SummaryCards(data: data);
                                } else {
                                  return const Text('No data available');
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            if (userRole.role != 'admin')
                              CustomLineChart(
                                title: 'Hasil Perolehan Susu ',
                                datas: milkProductionData,
                                predictionPointWidget: 0.0,
                              ),
                            CustomLineChart(
                              title: 'Berat Pangan Hijauan',
                              datas: greenFodderData,
                              otherInfo: 'Pakan Hijauan Terbaik saat ini :',
                              valueInfo: 6.2,
                              predictionPointWidget: 6.2,
                            ),
                            CustomLineChart(
                              title: 'Berat Pangan Sentrat',
                              datas: concentratedFodderData,
                              otherInfo: 'Pakan Sentrat Terbaik saat ini :',
                              valueInfo: 4.8,
                              predictionPointWidget: 4.8,
                            ),
                            CustomBarChart(
                              title: 'Produksi Susu Per Bulan',
                              barGroupData: milkProductionPerMonthDynamics(),
                              predictedNextMonth: predictedNextMonth,
                              data: susuBulanan,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (userRole.role == 'doctor' || userRole.role == 'dokter')
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            FutureBuilder<List<Map<String, String>>>(
                              future: _futureSakitData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  final data = snapshot.data!;
                                  return SummaryCards(data: data);
                                } else {
                                  return const Text('No data available');
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            if (sickIndicatedDinamis.isNotEmpty)
                              const Text(
                                'Sapi Terindikasi Sakit :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8F3505),
                                ),
                              ),
                            if (sickIndicatedDinamis.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Semua sapi sehat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            for (var cattle in sickIndicatedDinamis)
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
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
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
