import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ternaknesia/screens/nambahsapi.dart';
import 'package:ternaknesia/screens/datasapipage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Model Data Sapi
class Cattle {
  final String id;
  final int weight;
  final int age;
  final String gender;
  final String healthStatus;

  Cattle({
    required this.id,
    required this.weight,
    required this.age,
    required this.gender,
    required this.healthStatus,
  });

  factory Cattle.fromJson(Map<String, dynamic> json) {
    String healthStatus =
        (json['health_record'] != null && json['health_record'] == true)
            ? 'Sehat'
            : 'Tidak Sehat';

    return Cattle(
      id: json['cow_id']?.toString() ?? 'Unknown ID',
      weight: int.tryParse(json['weight']?.toString() ?? '0') ??
          0, // Convert to int if possible, default to 0
      age: int.tryParse(json['age']?.toString() ?? '0') ??
          0, // Convert to int if possible, default to 0
      gender: json['gender']?.toString() ?? 'Unknown',
      healthStatus: healthStatus,
    );
  }

  @override
  String toString() {
    return 'Cattle{id: $id, weight: $weight, age: $age, gender: $gender, healthStatus: $healthStatus}';
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

  @override
  void initState() {
    super.initState();
    cattleData = fetchCattleData();
  }

  Future<List<Cattle>> fetchCattleData() async {
    try {
      final response = await http.get(Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows'));

      if (response.statusCode == 200) {
        List<dynamic> cattleJson = json.decode(response.body);

        // Map each JSON item to a Cattle instance
        return cattleJson.map((json) {
          try {
            return Cattle.fromJson(json);
          } catch (e) {
            // Log and handle specific errors for each item
            throw Exception('Error parsing item: ${json['cow_id']} - $e');
          }
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
      appBar: AppBar(
        backgroundColor: Color(0xFFC35804),
        title: const Text(
          'DATA PAGE',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FutureBuilder for cattle data
            FutureBuilder<List<Cattle>>(
              future: cattleData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Menampilkan pesan error dengan detail yang lebih lengkap
                  return Center(
                      child: Text('Error loading data: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                } else {
                  // Filter data berdasarkan query
                  final filteredCattle = snapshot.data!.where((cattle) {
                    return cattle.id.toLowerCase().contains(searchQuery) ||
                        cattle.healthStatus.toLowerCase().contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCattle.length,
                    itemBuilder: (context, index) {
                      final cattle = filteredCattle[index];
                      return _buildCattleCard(
                        context,
                        id: cattle.id,
                        weight: cattle.weight,
                        age: cattle.age,
                        status: cattle.healthStatus,
                        statusColor:
                            cattle.healthStatus.toLowerCase() == 'sehat'
                                ? Colors.green
                                : Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataSapiPage(
                                id: cattle.id,
                                gender: cattle.gender,
                                age: cattle.age.toString(),
                                healthStatus: cattle.healthStatus,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahSapiPage(),
            ),
          );
        },
        elevation: 0,
        backgroundColor: Color(0xFFC35804),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCattleCard(BuildContext context,
      {required String id,
      required int weight,
      required int age,
      required String status,
      required Color statusColor,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/cow.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID SAPI = $id',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text('Berat = $weight kg'),
                    Text('Umur = $age bulan'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
