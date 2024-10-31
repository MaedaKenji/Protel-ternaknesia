import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataSapiPage extends StatelessWidget {
  final String id;
  final String gender;
  final String age;
  final String healthStatus;

  const DataSapiPage({
    Key? key,
    required this.id,
    required this.gender,
    required this.age,
    required this.healthStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        title: Text('ID SAPI: $id'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
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
                          Text('Kelamin = $gender'),
                          Text('Umur = $age'),
                          Text(
                              'Tanggal = ${DateTime.now().toString().split(" ")[0]}'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            healthStatus == 'SEHAT' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        healthStatus,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Chart Section
            const Text(
              'PRODUKSI SUSU & BERAT BADAN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            _buildLineChart('Berat Badan', 70),
            const SizedBox(height: 10),
            _buildLineChart('Produksi Susu', 25),
            const SizedBox(height: 20),

            // Feed Section
            const Text(
              'PAKAN YANG DIBERIKAN :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            _buildLineChart('Pakan Hijauan', 30),
            const SizedBox(height: 10),
            _buildLineChart('Pakan Sentrat', 20),
            const SizedBox(height: 20),

            // Conditions Section
            const Text(
              'KONDISI HEWAN :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            _buildEditableField('Stress Level', 'Normal'),
            _buildEditableField('Kesehatan', healthStatus),

            // Population Structure Section
            const SizedBox(height: 20),
            const Text(
              'STRUKTUR POPULASI :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            _buildEditableField('Birahi', 'Tidak'),
            _buildEditableField('Status', 'Aktif'),

            const SizedBox(height: 20),
            const Text(
              'CATATAN :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan catatan',
              ),
            ),
            const SizedBox(height: 20),

            // Button to remove the cow from the barn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add logic to handle cow removal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text(
                  'KELUARKAN SAPI DARI KANDANG',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build static line chart
  Widget _buildLineChart(String title, double currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(1, 20),
                    FlSpot(2, 30),
                    FlSpot(3, 40),
                    FlSpot(4, currentValue),
                    FlSpot(5, 60),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.orange, // Use 'color' instead of 'colors'
                  dotData: FlDotData(show: true),
                ),
              ],
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Saat ini:'),
            Text(
              '$currentValue Kg',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Function to build editable fields with edit icons
  Widget _buildEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: value,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () {
              // Add logic for editing the condition
            },
          ),
        ],
      ),
    );
  }
}
