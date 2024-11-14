import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ternaknesia/screens/nambahsapi.dart';
import 'package:ternaknesia/screens/datasapipage.dart';

// Data Page
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final List<Map<String, dynamic>> _cattleData = [
    {
      'id': '001',
      'weight': 100,
      'age': '2 Bulan',
      'status': 'SAKIT',
      'gender': 'Betina',
      'statusColor': Colors.red,
    },
    {
      'id': '002',
      'weight': 100,
      'age': '2 Bulan',
      'status': 'SEHAT',
      'gender': 'Jantan',
      'statusColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'DATA PAGE',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
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
                  borderSide: const BorderSide(color: Color(0xFFC35804)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC35804)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of Cattle Cards
            Expanded(
              child: ListView.builder(
                itemCount: _cattleData.length,
                itemBuilder: (context, index) {
                  final cattle = _cattleData[index];
                  return Column(
                    children: [
                      _buildCattleCard(
                        context,
                        id: cattle['id'],
                        weight: cattle['weight'],
                        age: cattle['age'],
                        status: cattle['status'],
                        statusColor: cattle['statusColor'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataSapiPage(
                                id: cattle['id'],
                                gender: cattle['gender'],
                                age: cattle['age'],
                                healthStatus: cattle['status'],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahSapiPage(),
            ),
          );

          if (newData != null) {
            setState(() {
              _cattleData.add({
                'id': newData['id'],
                'weight': newData['weight'],
                'age': '${newData['age']} Bulan',
                'status': newData['status'],
                'gender': newData['gender'],
                'statusColor':
                    newData['status'] == 'SAKIT' ? Colors.red : Colors.green,
              });
            });
          }
        },
        backgroundColor: const Color(0xFFC35804),
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
