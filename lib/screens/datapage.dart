import 'package:flutter/material.dart';
import 'package:ternaknesia/screens/nambahsapi.dart';
import 'package:ternaknesia/screens/datasapipage.dart';

// Data Page
class DataPage extends StatelessWidget {
  const DataPage({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
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

            // List of Cattle Cards
            Expanded(
              child: ListView(
                children: [
                  _buildCattleCard(
                    context,
                    id: '001',
                    weight: 100,
                    age: '2 Bulan',
                    status: 'SAKIT',
                    statusColor: Colors.red,
                    onTap: () {
                      // Navigate to Data Sapi Page for Sapi 001
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataSapiPage(
                            id: '001',
                            gender: 'Betina',
                            age: '2 Bulan',
                            healthStatus: 'SAKIT',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCattleCard(
                    context,
                    id: '002',
                    weight: 100,
                    age: '2 Bulan',
                    status: 'SEHAT',
                    statusColor: Colors.green,
                    onTap: () {
                      // Navigate to Data Sapi Page for Sapi 002
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataSapiPage(
                            id: '002',
                            gender: 'Jantan',
                            age: '2 Bulan',
                            healthStatus: 'SEHAT',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button to Add New Cattle
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Tambah Sapi Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahSapiPage(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Function to build individual cattle card
  Widget _buildCattleCard(BuildContext context,
      {required String id,
      required int weight,
      required String age,
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
              CircleAvatar(
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
                    Text('Umur = $age'),
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
