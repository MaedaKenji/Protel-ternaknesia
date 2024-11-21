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
  List<String> historyData = ['70 Kg', '65 Kg', '72 Kg', '68 Kg'];
  int _currentChartIndex = 0;

  bool isLoading = false;
  String errorMessage = '';

  Map<String, Map<String, List<FlSpot>>> feedData = {
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

  Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
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
    _refreshData();
  }

 
  void _nextChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex + 1) % 4;
    });
  }

  void _previousChart() {
    setState(() {
      _currentChartIndex = (_currentChartIndex - 1) % 4;
      if (_currentChartIndex < 0) {
        _currentChartIndex = 3;
      }
    });
  }

  void _addNewData() {
    String key;
    if (_currentChartIndex == 0) {
      key = 'produksiSusu';
    } else if (_currentChartIndex == 1) {
      key = 'beratBadan';
    } else if (_currentChartIndex == 2) {
      key = 'pakanHijau';
    } else {
      key = 'pakanSentrat';
    }

    showDialog(
      context: context,
      builder: (context) =>
          _NewDataDialog(id: '${widget.id}'), // Ganti dengan ID yang sesuai
    ).then((data) {
      if (data != null && data.isNotEmpty) {
        final Map<String, String> dictionary = {key: data};
        _sendDataToServer(dictionary);
      }
    });
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
      print(response.body);

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
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.orange, size: 40),
              SizedBox(width: 10),
              Text("PERUBAHAN DATA SAPI BERHASIL"),
            ],
          ),
        );
      },
    );
  }

  void _showHistory() async {
    await showDialog(
      context: context,
      builder: (context) {
        return _HistoryDialog(
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

 
  // Fetch data from API
 Future<http.Response> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    print("Fetching data...");

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/${widget.id}');
      final response = await http.get(url);
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return response; // Tambahkan return di sini
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data. Status code: ${response.statusCode}';
        });
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
      rethrow; // Jangan swallow error, lempar ulang error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

Map<String, Map<String, List<FlSpot>>> processFeedData(
      List<Map<String, dynamic>> feedHijauan,
      List<Map<String, dynamic>> feedSentrate) {
    Map<String, Map<String, List<FlSpot>>> feedData = {
      'Pakan Hijau': {},
      'Pakan Sentrat': {},
    };

    // Proses data Pakan Hijauan
    feedHijauan.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB); // Mengurutkan dari yang paling lama
    });

    for (var feed in feedHijauan) {
      DateTime date = DateTime.parse(feed['date']);
      double amount = double.tryParse(feed['amount']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      feedData['Pakan Hijau'] ??= {};
      feedData['Pakan Hijau']?[monthWithYear] ??= [];
      feedData['Pakan Hijau']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), amount));
    }

    // Proses data Pakan Sentrate
    feedSentrate.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB); // Mengurutkan dari yang paling lama
    });

    for (var feed in feedSentrate) {
      DateTime date = DateTime.parse(feed['date']);
      double amount = double.tryParse(feed['amount']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      feedData['Pakan Sentrat'] ??= {};
      feedData['Pakan Sentrat']?[monthWithYear] ??= [];
      feedData['Pakan Sentrat']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), amount));
    }

    return feedData;
  }

Map<String, Map<String, List<FlSpot>>> processMilkAndWeightData(
      List<Map<String, dynamic>> milkProduction,
      List<Map<String, dynamic>> weights) {
    Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
      'Produksi Susu': {},
      'Berat Badan': {},
    };

    // Proses data Produksi Susu
    milkProduction.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB); // Mengurutkan dari yang paling lama
    });

    for (var milk in milkProduction) {
      DateTime date = DateTime.parse(milk['date']);
      double productionAmount =
          double.tryParse(milk['production_amount']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      milkAndWeightData['Produksi Susu'] ??= {};
      milkAndWeightData['Produksi Susu']?[monthWithYear] ??= [];
      milkAndWeightData['Produksi Susu']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), productionAmount));
    }

    // Proses data Berat Badan
    weights.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB); // Mengurutkan dari yang paling lama
    });

    for (var weight in weights) {
      DateTime date = DateTime.parse(weight['date']);
      double weightValue =
          double.tryParse(weight['weight']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      milkAndWeightData['Berat Badan'] ??= {};
      milkAndWeightData['Berat Badan']?[monthWithYear] ??= [];
      milkAndWeightData['Berat Badan']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), weightValue));
    }

    return milkAndWeightData;
  }


  // Map<String, Map<String, List<FlSpot>>> processFeedData(
  //     List<Map<String, dynamic>> feedHijauan,
  //     List<Map<String, dynamic>> feedSentrate) {
  //   Map<String, Map<String, List<FlSpot>>> feedData = {
  //     'Pakan Hijau': {},
  //     'Pakan Sentrat': {},
  //   };

  //   // Proses data Pakan Hijauan
  //   for (var feed in feedHijauan) {
  //     DateTime date = DateTime.parse(feed['date']);
  //     double amount = double.tryParse(feed['amount']?.toString() ?? '0') ?? 0;
  //     String monthWithYear = _getMonthWithYear(date);

  //     feedData['Pakan Hijau'] ??= {};
  //     feedData['Pakan Hijau']?[monthWithYear] ??= [];
  //     feedData['Pakan Hijau']?[monthWithYear]!
  //         .add(FlSpot(date.day.toDouble(), amount));
  //   }

  //   // Proses data Pakan Sentrate
  //   for (var feed in feedSentrate) {
  //     DateTime date = DateTime.parse(feed['date']);
  //     double amount = double.tryParse(feed['amount']?.toString() ?? '0') ?? 0;
  //     String monthWithYear = _getMonthWithYear(date);

  //     feedData['Pakan Sentrat'] ??= {};
  //     feedData['Pakan Sentrat']?[monthWithYear] ??= [];
  //     feedData['Pakan Sentrat']?[monthWithYear]!
  //         .add(FlSpot(date.day.toDouble(), amount));
  //   }

  //   return feedData;
  // }

  // Map<String, Map<String, List<FlSpot>>> processMilkAndWeightData(
  //     List<Map<String, dynamic>> milkProduction,
  //     List<Map<String, dynamic>> weights) {
  //   Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
  //     'Produksi Susu': {},
  //     'Berat Badan': {},
  //   };

  //   // Proses data Produksi Susu
  //   for (var milk in milkProduction) {
  //     DateTime date = DateTime.parse(milk['date']);
  //     double productionAmount =
  //         double.tryParse(milk['production_amount']?.toString() ?? '0') ?? 0;
  //     String monthWithYear = _getMonthWithYear(date);

  //     milkAndWeightData['Produksi Susu'] ??= {};
  //     milkAndWeightData['Produksi Susu']?[monthWithYear] ??= [];
  //     milkAndWeightData['Produksi Susu']?[monthWithYear]!
  //         .add(FlSpot(date.day.toDouble(), productionAmount));
  //   }

  //   // Proses data Berat Badan
  //   for (var weight in weights) {
  //     DateTime date = DateTime.parse(weight['date']);
  //     double weightValue =
  //         double.tryParse(weight['weight']?.toString() ?? '0') ?? 0;
  //     String monthWithYear = _getMonthWithYear(date);

  //     milkAndWeightData['Berat Badan'] ??= {};
  //     milkAndWeightData['Berat Badan']?[monthWithYear] ??= [];
  //     milkAndWeightData['Berat Badan']?[monthWithYear]!
  //         .add(FlSpot(date.day.toDouble(), weightValue));
  //   }

  //   return milkAndWeightData;
  // }

  String _getMonthWithYear(DateTime date) {
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

  void updateChartData(Map<String, dynamic> apiResponse) {
    List<Map<String, dynamic>> recentFeedHijauan =
        List<Map<String, dynamic>>.from(apiResponse['recent_feed_hijauan']);
    List<Map<String, dynamic>> recentFeedSentrate =
        List<Map<String, dynamic>>.from(apiResponse['recent_feed_sentrate']);
    List<Map<String, dynamic>> recentMilkProduction =
        List<Map<String, dynamic>>.from(apiResponse['recent_milk_production']);
    List<Map<String, dynamic>> recentWeights =
        List<Map<String, dynamic>>.from(apiResponse['recent_weights']);

    final feedData = processFeedData(recentFeedHijauan, recentFeedSentrate);
    final milkAndWeightData =
        processMilkAndWeightData(recentMilkProduction, recentWeights);

    // Gunakan feedData dan milkAndWeightData untuk widget MultiChartContainer
    setState(() {
      this.feedData = feedData;
      this.milkAndWeightData = milkAndWeightData;
    });
  }

  Future<void> _refreshData() async {
    try {
      // Fetch data from API
      final response = await fetchData(); // Sesuaikan dengan fungsi fetch Anda
      print("Berat Badan: $beratBadan");
      print("response body: ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // Proses data dengan pengecekan null
        final recentWeights = List<Map<String, dynamic>>.from(
            responseBody['recent_weights'] ?? []);
        final recentMilkProduction = List<Map<String, dynamic>>.from(
            responseBody['recent_milk_production'] ?? []);
        final recentFeedHijauan = List<Map<String, dynamic>>.from(
            responseBody['recent_feed_hijauan'] ?? []);
        final recentFeedSentrate = List<Map<String, dynamic>>.from(
            responseBody['recent_feed_sentrate'] ?? []);

        // Update state with processed data
        setState(() {
          feedData = processFeedData(recentFeedHijauan, recentFeedSentrate);
          milkAndWeightData =
              processMilkAndWeightData(recentMilkProduction, recentWeights);
        });
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error (e.g., show a message to the user)
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Agar tetap bisa di-scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cattle Card (Header bagian atas)
              Container(
                // padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: _buildHeader(
                  id: widget.id,
                  gender: widget.gender,
                  age: widget.age,
                  healthStatus: widget.healthStatus,
                ),
              ),
              const SizedBox(height: 80),

              // Konten utama setelah header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 10),
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
                          borderSide:
                              const BorderSide(color: Color(0xFF8F3505)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF8F3505)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF8F3505)),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // end of class

// Dialog untuk menambahkan data baru
class _NewDataDialog extends StatelessWidget {
  final String id;

  _NewDataDialog({required this.id});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text("SILAHKAN INPUT DATA BARU :"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(suffixText: "Kg/L"),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("BATAL"),
        ),
        TextButton(
          onPressed: () {
            String data = controller.text;
            Navigator.of(context)
                .pop(data); // Mengembalikan data ke _addNewData
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

// Dialog untuk riwayat data
class _HistoryDialog extends StatelessWidget {
  final List<String> data;
  final Function(int) onDelete;

  const _HistoryDialog({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("RIWAYAT PAKAN"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.asMap().entries.map((entry) {
          int index = entry.key;
          String value = entry.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {}, // Logika untuk edit data
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.orange),
                    onPressed: () => onDelete(index),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("BATAL"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
