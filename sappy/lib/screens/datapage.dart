import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/custom_pop_up_dialog.dart';
import 'package:sappy/provider/cattle_provider.dart';
import 'package:sappy/screens/datasapipage.dart';
import 'package:sappy/screens/nambahsapi.dart';

class Cattle {
  final String id;
  final double weight;
  final int age;
  final String gender;
  final String healthStatus;
  final bool isProductive;
  final bool isConnectedToNFCTag;

  Cattle({
    required this.id,
    required this.weight,
    required this.age,
    required this.gender,
    required this.healthStatus,
    required this.isProductive,
    required this.isConnectedToNFCTag,
  });

  factory Cattle.fromJson(Map<String, dynamic> json) {
    return Cattle(
      id: json['id']?.toString() ?? 'Unknown ID',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0,
      age: int.tryParse(json['age']?.toString() ?? '0') ?? -1,
      gender: json['gender']?.toString() ?? 'Unknown',
      healthStatus: json['healthStatus'].toString(),
      isProductive: json['isProductive'] ?? false,
      isConnectedToNFCTag: json['is_connected_to_nfc_tag'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Cattle{id: $id, weight: $weight, age: $age, gender: $gender, healthStatus: $healthStatus, isProductive: $isProductive}';
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Future<List<Cattle>>? cattleData;
  bool useStaticData = false;

  @override
  void initState() {
    super.initState();
    cattleData = fetchCattleData();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _refreshData();
  }

  Future<List<Cattle>> fetchCattleData() async {
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cattles-relational');

    final response =
        await http.get(url).timeout(const Duration(seconds: 5), onTimeout: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out'),
        ),
      );
      return http.Response('Request timed out', 408);
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // debugPrint("data untuk datapage: $data");
      // Convert JSON to List<Cattle>
      final cattleList = data.map((item) => Cattle.fromJson(item)).toList();

      // Update provider
      if (mounted) {
        final cattleListProvider = data.map((item) => CattleProviderClass.fromJson(item)).toList();
        Provider.of<CattleProvider>(context, listen: false).setCattleList(cattleListProvider);
      }

      return cattleList;
    } else {
      // ignore: use_build_context_synchronously
      debugPrint('Failed to load cattle data with status code: ${response.statusCode} ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to load cattle data with status code: ${response.statusCode} ${response.body}'),
        ),
      );
    }
    return [];
  }

  Future<void> _refreshData() async {
    setState(() {
      cattleData = fetchCattleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        flexibleSpace: Stack(
          clipBehavior: Clip.none,
          children: [
        Container(
          height: 85,
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
        const Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Sapi',
              style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
              ),
            ),
          ],
            ),
          ),
        ), 
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Expanded(
              child: useStaticData
                  ? Center(child: Text("Static Page"))
                  : FutureBuilder<List<Cattle>>(
                      future: cattleData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Error loading data: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No data found.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return _buildFetchedDataList(snapshot.data!);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: const TambahSapiPage(),
                );
              },
            ),
          );
        },
        elevation: 0,
        backgroundColor: const Color(0xFFC35804),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFetchedDataList(List<Cattle> cattleData) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16),
      itemCount: cattleData.length,
      itemBuilder: (context, index) {
        final cattle = cattleData[index];
        return _buildCattleCard(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return DataSapiPage(
                  id: cattle.id,
                  gender: cattle.gender.toString(),
                  age: cattle.age.toString(),
                  lastWeight: cattle.weight.toDouble(),
                  healthStatus: cattle.healthStatus.toString(),
                  isProductive: cattle.isProductive,
                  isConnectedToNFCTag: cattle.isConnectedToNFCTag,
                );
              }),
            );
          },
          context,
          id: cattle.id,
          weight: cattle.weight,
          gender: cattle.gender,
          age: '${cattle.age} Bulan',
          status: cattle.healthStatus,
          statusColor: cattle.healthStatus.toLowerCase() == 'sehat'
              ? Colors.green
              : Colors.red,
          isProductive: cattle.isProductive,
        );
      },
    );
  }

  Widget _buildCattleCard(BuildContext context,
      {required String id,
      required double weight,
      required String age,
      required String status,
      required String gender,
      required Color statusColor,
      required bool isProductive,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/cow_alt.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gender.toLowerCase() == 'jantan'
                                    ? Colors.blue.shade300
                                    : Colors.pink.shade300,
                                gender.toLowerCase() == 'jantan'
                                    ? Colors.blue.shade600
                                    : Colors.pink.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gender.toLowerCase() == 'jantan'
                                    ? Icons.male
                                    : Icons.female,
                                color: Colors.white,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
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
                                    fontSize: 20,
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
                              isHealthy: status.toLowerCase() == 'sehat',
                              isProductive: isProductive,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildCowInfo(
                                'Berat', '$weight Kg', MaterialSymbols.weight),
                            _buildCowInfo(
                                'Umur', age, MaterialSymbols.calendar_month),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCowIndicator({
    bool? isHealthy,
    bool? isProductive,
  }) {
    return Row(
      children: [
        if (isHealthy != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isHealthy ? Colors.green.shade300 : Colors.red.shade300,
                  isHealthy ? Colors.green.shade600 : Colors.red.shade600,
                ],
              ),
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
        if (isProductive == true) const SizedBox(width: 8),

        // Indikator Produktifitas (Opsional)
        if (isProductive != null && isProductive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade300,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'PRODUKTIF',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
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
}
