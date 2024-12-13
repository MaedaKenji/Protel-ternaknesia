import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:ternaknesia/components/custom_pop_up_dialog.dart';
import 'package:ternaknesia/screens/datasapipage.dart';
import 'package:ternaknesia/screens/nambahsapi.dart';

class Cattle {
  final String id;
  final int weight;
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
      weight: double.tryParse(json['weight'].toString())?.round() ?? -1,
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

  bool useStaticData = true;

  final List<Map<String, dynamic>> _staticCattleData = [
    {
      'id': '001',
      'weight': 100,
      'age': '2 Bulan',
      'status': 'SAKIT',
      'isProductive': false,
      'isConnectedToNFCTag': false,
      'gender': 'Betina',
      'statusColor': Colors.red,
    },
    {
      'id': '002',
      'weight': 100,
      'age': '2 Bulan',
      'status': 'SEHAT',
      'isProductive': true,
      'isConnectedToNFCTag': true,
      'gender': 'Jantan',
      'statusColor': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    cattleData = fetchCattleData();
    _refreshData();
  }

  Future<List<Cattle>> fetchCattleData() async {
    final url =
        Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cattles-relational');

    final response =
        await http.get(url).timeout(const Duration(seconds: 5), onTimeout: () {
      throw Exception('Request timed out');
    });

    if (response.statusCode == 200) {
      // Jika server mengembalikan respons 200 OK, maka parse JSON
      List<dynamic> data = json.decode(response.body);
      // Mengonversi JSON ke daftar objek Cattle
      return data.map((item) => Cattle.fromJson(item)).toList();
    } else {
      // Jika respons tidak 200 OK, lemparkan exception
      throw Exception('Failed to load cattle data');
    }
  }
  

  
  Future<List<Cattle>> fetchCattleDataTapiRibetIniMauBuatBaruVersiRelationalTable() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Sort data berdasarkan cow_id
        cattleJson.sort((a, b) => (int.tryParse(a['cow_id'].toString()) ?? 0)
            .compareTo(int.tryParse(b['cow_id'].toString()) ?? 0));


        // Prepare filtered data by extracting only the relevant fields without randomization
        final filteredData = cattleJson.map((json) {
          return {
            'hijauan_weight':
                json['hijauan_weight'], // Passing the original value
            'sentrat_weight':
                json['sentrat_weight'], // Passing the original value
            'stress_level': json['stress_level'], // Passing the original value
            'health_status':
                json['health_status'], // Passing the original value
            'milk_production':
                json['milk_production'], // Passing the original value
          };
        }).toList();

        // Kirim data yang sudah difilter ke API Flask
        final classifyUrl = Uri.parse(
            '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/classify/cattle');
        final classifyResponse = await http.post(
          classifyUrl,
          body: json.encode(filteredData),
          headers: {'Content-Type': 'application/json'},
        );

        if (classifyResponse.statusCode == 200) {
          // Hasil klasifikasi dari backend
          List<dynamic> classifiedData = json.decode(classifyResponse.body);

          // Add 'isProductive' from classified data into the original cattleJson
          return cattleJson.map((originalJson) {
            // Assuming classifyData is a list and the order matches with cattleJson
            final isProductive = classifiedData.isNotEmpty
                ? classifiedData.first['is_productive'] ?? false
                : false; // Default value if empty or not available

            return Cattle(
              id: (originalJson['cow_id'] is String)
                  ? originalJson['cow_id']
                  : "0",
              weight: (originalJson['weight'] is int)
                  ? originalJson['weight']
                  : (originalJson['weight'] is String &&
                          originalJson['weight'].isNotEmpty)
                      ? int.tryParse(originalJson['weight']) ?? 0
                      : 0,
              age: originalJson['age'] ?? 0, // Default age
              gender: originalJson['gender'] ?? 'Unknown', // Default gender
              healthStatus:
                  (originalJson['health_record'] == true) ? "SEHAT" : "SAKIT",
              isProductive: isProductive, // Adding 'isProductive' directly
              isConnectedToNFCTag: originalJson['is_connected_to_nfc_tag'] ??
                  false, // Keep original NFC connection status
            );
          }).toList();
        } else {
          throw Exception('Failed to classify cattle productivity');
        }
      } else {
        throw Exception(
            'Failed to load cattle data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cattle data: $e');
    }
  }

  
  Future<List<Cattle>> fetchCattleDataRandom() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Sort data berdasarkan cow_id
        cattleJson.sort((a, b) => (int.tryParse(a['cow_id'].toString()) ?? 0)
            .compareTo(int.tryParse(b['cow_id'].toString()) ?? 0));

        final random = Random();

        // Hanya ambil kolom yang relevan untuk prediksi dan pastikan urutannya sesuai
        final filteredData = cattleJson.map((json) {
          return {
            'hijauan_weight': json['hijauan_weight'] is int
                ? json['hijauan_weight']
                : (json['hijauan_weight'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'sentrat_weight': json['sentrat_weight'] is int
                ? json['sentrat_weight']
                : (json['sentrat_weight'] as double?)?.toInt() ??
                    random.nextInt(16) + 10,
            'stress_level': json['stress_level'] is int
                ? json['stress_level']
                : (json['stress_level'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'health_status': json['health_status'] is int
                ? json['health_status']
                : (json['health_status'] as double?)?.toInt() ??
                    random.nextInt(21) + 70,
            'milk_production': json['milk_production'] is int
                ? json['milk_production']
                : (json['milk_production'] as double?)?.toInt() ??
                    random.nextInt(11) + 25,
          };
        }).toList();

        // Kirim data yang sudah difilter ke API Flask
        final classifyUrl = Uri.parse(
            '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/classify/cattle');
        final classifyResponse = await http.post(
          classifyUrl,
          body: json.encode(filteredData),
          headers: {'Content-Type': 'application/json'},
        );

        if (classifyResponse.statusCode == 200) {
          // Hasil klasifikasi dari backend
          List<dynamic> classifiedData = json.decode(classifyResponse.body);

          // Add 'isProductive' from classified data into the original cattleJson
          return cattleJson.map((originalJson) {
            // Assuming classifyData is a list and the order matches with cattleJson
            final isProductive = classifiedData.isNotEmpty
                ? classifiedData.first['is_productive'] ?? false
                : false; // Default value if empty or not available

            return Cattle(
              id: (originalJson['cow_id'] is String)
                  ? originalJson['cow_id']
                  : "0",
              weight: (originalJson['weight'] is int)
                  ? originalJson['weight']
                  : (originalJson['weight'] is String &&
                          originalJson['weight'].isNotEmpty)
                      ? int.tryParse(originalJson['weight']) ?? 0
                      : 0,
              age: originalJson['age'] ?? 0, // Default age
              gender: originalJson['gender'] ?? 'Unknown', // Default gender
              healthStatus:
                  (originalJson['health_record'] == true) ? "SEHAT" : "SAKIT",
              isProductive: isProductive, // Adding 'isProductive' directly
              isConnectedToNFCTag: originalJson['is_connected_to_nfc_tag'] ??
                  false, // Keep original NFC connection status
            );
          }).toList();
        } else {
          throw Exception('Failed to classify cattle productivity');
        }
      } else {
        throw Exception(
            'Failed to load cattle data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cattle data: $e');
    }
  }

  Future<List<Cattle>> fetchCattleData3() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Sort data berdasarkan cow_id
        cattleJson.sort((a, b) => (int.tryParse(a['cow_id'].toString()) ?? 0)
            .compareTo(int.tryParse(b['cow_id'].toString()) ?? 0));

        final random = Random();

        // Hanya ambil kolom yang relevan untuk prediksi dan pastikan urutannya sesuai
        final filteredData = cattleJson.map((json) {
          return {
            'hijauan_weight': json['hijauan_weight'] is int
                ? json['hijauan_weight']
                : (json['hijauan_weight'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'sentrat_weight': json['sentrat_weight'] is int
                ? json['sentrat_weight']
                : (json['sentrat_weight'] as double?)?.toInt() ??
                    random.nextInt(16) + 10,
            'stress_level': json['stress_level'] is int
                ? json['stress_level']
                : (json['stress_level'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'health_status': json['health_status'] is int
                ? json['health_status']
                : (json['health_status'] as double?)?.toInt() ??
                    random.nextInt(21) + 70,
            'milk_production': json['milk_production'] is int
                ? json['milk_production']
                : (json['milk_production'] as double?)?.toInt() ??
                    random.nextInt(11) + 25,
          };
        }).toList();

        // Kirim data yang sudah difilter ke API Flask
        final classifyUrl = Uri.parse(
            '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/classify/cattle');
        final classifyResponse = await http.post(
          classifyUrl,
          body: json.encode(filteredData),
          headers: {'Content-Type': 'application/json'},
        );

        if (classifyResponse.statusCode == 200) {
          // Hasil klasifikasi dari backend
          List<dynamic> classifiedData = json.decode(classifyResponse.body);

          // Map the classified data and combine it with original cattleJson data
          return cattleJson.map((originalJson) {
            final classifiedJson = classifiedData.firstWhere(
                (classified) =>
                    int.tryParse(classified['cow_id'].toString()) ==
                    int.tryParse(originalJson['cow_id'].toString()),
                orElse: () => {}); // Safely handle cases if no match is found

            return Cattle(
              id: (originalJson['cow_id'] is String)
                  ? originalJson['cow_id']
                  : "0",
              weight: (originalJson['weight'] is int)
                  ? originalJson['weight']
                  : (originalJson['weight'] is String &&
                          originalJson['weight'].isNotEmpty)
                      ? int.tryParse(originalJson['weight']) ?? 0
                      : 0,
              age: originalJson['age'] ?? 0, // Default age
              gender: originalJson['gender'] ?? 'Unknown', // Default gender
              healthStatus:
                  (originalJson['health_record'] == true) ? "SEHAT" : "SAKIT",
              isProductive: classifiedJson['is_productive'] ??
                  false, // Classified productivity
              isConnectedToNFCTag: classifiedJson['is_connected_to_nfc_tag'] ??
                  false, // Classified NFC
            );
          }).toList();
        } else {
          throw Exception('Failed to classify cattle productivity');
        }
      } else {
        throw Exception(
            'Failed to load cattle data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cattle data: $e');
    }
  }

  Future<List<Cattle>> fetchCattleData2() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Sort data berdasarkan cow_id
        cattleJson.sort(
            (a, b) => int.parse(a['cow_id']).compareTo(int.parse(b['cow_id'])));

        final random = Random();

        // Hanya ambil kolom yang relevan untuk prediksi dan pastikan urutannya sesuai
        final filteredData = cattleJson.map((json) {
          return {
            'hijauan_weight': json['hijauan_weight'] is int
                ? json['hijauan_weight']
                : (json['hijauan_weight'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'sentrat_weight': json['sentrat_weight'] is int
                ? json['sentrat_weight']
                : (json['sentrat_weight'] as double?)?.toInt() ??
                    random.nextInt(16) + 10,
            'stress_level': json['stress_level'] is int
                ? json['stress_level']
                : (json['stress_level'] as double?)?.toInt() ??
                    random.nextInt(21) + 20,
            'health_status': json['health_status'] is int
                ? json['health_status']
                : (json['health_status'] as double?)?.toInt() ??
                    random.nextInt(21) + 70,
            'milk_production': json['milk_production'] is int
                ? json['milk_production']
                : (json['milk_production'] as double?)?.toInt() ??
                    random.nextInt(11) + 25,
          };
        }).toList();

        // Kirim data yang sudah difilter ke API Flask
        final classifyUrl = Uri.parse(
            '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/classify/cattle');
        final classifyResponse = await http.post(
          classifyUrl,
          body: json.encode(filteredData),
          headers: {'Content-Type': 'application/json'},
        );

        if (classifyResponse.statusCode == 200) {
          // Hasil klasifikasi dari backend
          List<dynamic> classifiedData = json.decode(classifyResponse.body);

          return classifiedData.map((json) {
            return Cattle(
              id: json['cow_id']?.toString() ?? 'Unknown', // Default 'Unknown'
              weight: json['weight'] is double
                  ? json['weight']
                  : (json['weight'] as int?)?.toDouble() ??
                      0.0, // Handle double
              age: json['age'] ?? 0, // Default 0
              gender: json['gender'] ?? 'Unknown', // Default 'Unknown'
              healthStatus: json['health_status'] ?? 0, // Default 0
              isProductive: json['is_productive'] ?? false, // Default false
              isConnectedToNFCTag:
                  json['is_connected_to_nfc_tag'] ?? false, // Default false
            );
          }).toList();
        } else {
          throw Exception('Failed to classify cattle productivity');
        }
      } else {
        throw Exception(
            'Failed to load cattle data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cattle data: $e');
    }
  }

  Future<List<Cattle>> fetchCattleDataASLI() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows');

      final response = await http.get(url).timeout(const Duration(seconds: 5),
          onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Mengurutkan data berdasarkan cow_id (konversi String ke int)
        cattleJson.sort(
            (a, b) => int.parse(a['cow_id']).compareTo(int.parse(b['cow_id'])));

        return cattleJson.map((json) {
          return Cattle.fromJson({
            ...json,
            'is_connected_to_nfc_tag': json['nfc_id'] != null,
            'health_status': json['health_record'] ? 'SEHAT' : 'SAKIT'
          });
        }).toList();
      } else {
        throw Exception(
            'Failed to load cattle data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cattle data: $e');
    }
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Existing content from your original code
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 70,
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
                  top: 12,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Data Sapi',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Fetch',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Switch(
                            value: useStaticData,
                            onChanged: (value) {
                              setState(() {
                                useStaticData = value;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Data Statis',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: useStaticData
                  ? _buildStaticDataList()
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

  Widget _buildStaticDataList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _staticCattleData.length,
      itemBuilder: (context, index) {
        final cattle = _staticCattleData[index];
        return _buildCattleCard(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return DataSapiPage(
                  id: cattle['id'],
                  gender: cattle['gender'],
                  age: cattle['age'],
                  healthStatus: cattle['status'],
                  isProductive: cattle['isProductive'],
                  isConnectedToNFCTag: cattle['isConnectedToNFCTag'],
                );
              }),
            );
          },
          context,
          id: cattle['id'],
          weight: cattle['weight'],
          gender: cattle['gender'],
          age: cattle['age'],
          status: cattle['status'],
          statusColor: cattle['statusColor'],
          isProductive: cattle['isProductive'],
        );
      },
    );
  }

  Widget _buildFetchedDataList(List<Cattle> cattleData) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
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
                  gender: cattle.gender,
                  age: cattle.age.toString(),
                  healthStatus: cattle.healthStatus,
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
      required int weight,
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
                  // Membungkus gambar dan indikator gender dalam Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/cow_alt.png'),
                      ),
                      // Indikator jenis kelamin di pojok kanan bawah dari gambar
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
        // Indikator Kesehatan (Opsional)
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
