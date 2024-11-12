import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataSapiPage extends StatefulWidget {
  final String id;
  final String gender;
  final String age;
  final String healthStatus;

  DataSapiPage({
    Key? key,
    required this.id,
    required this.gender,
    required this.age,
    required this.healthStatus,
  }) : super(key: key);

  @override
  _DataSapiPageState createState() => _DataSapiPageState();
}

class _DataSapiPageState extends State<DataSapiPage> {
  List<double> beratBadan = [];
  List<double> susu = [];
  List<double> pakanHijau = [];
  List<double> pakanSentrat = [];

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from API
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/${widget.id}');
      final response = await http.get(url);


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        setState(() {
          // Mengisi list beratBadan dengan konversi String ke double
          beratBadan = List<double>.from(data['recent_weights']
                  ?.map((item) => double.parse(item['weight'] ?? '0')) ??
              []);

          // Kosongkan list lainnya jika tidak diperlukan
          susu = List<double>.from(data['recent_milk_production'] ?. map((item) => 
          double.parse(item['production_amount'] ?? '0')) ?? []);
          pakanHijau = List<double>.from(data['recent_feed_hijauan'] ?. map((item) =>
          double.parse(item['amount'] ?? '0')) ?? []);
          pakanSentrat = List<double>.from(data['recent_feed_sentrate'] ?. map((item) =>
          double.parse(item['amount'] ?? '0')) ?? []);
        });
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  // Function to build static line chart
  Widget _buildLineChart(String title, List<double> values) {
    if (values.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            alignment: Alignment.center,
            child: const Text('Data tidak tersedia'),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

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
                    for (int i = 0; i < values.length; i++)
                      FlSpot((i + 1).toDouble(), values[i])
                  ],
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.orange,
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
              values.isNotEmpty ? '${values.last} Kg' : '0 Kg',
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
    TextEditingController controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              readOnly:
                  true, // Set to true if you want to make it non-editable initially
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () {
              // Implement edit functionality here
              _showEditDialog(label, controller);
            },
          ),
        ],
      ),
    );
  }

  // Function to show dialog for editing fields
  void _showEditDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Implement save logic here
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID SAPI: ${widget.id}'),
        backgroundColor: Colors.orange[100],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Tambahkan ini
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
                                backgroundImage:
                                    AssetImage('assets/images/cow.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID SAPI = ${widget.id}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    Text('Kelamin = ${widget.gender}'),
                                    Text('Umur = ${widget.age}'),
                                    Text(
                                        'Tanggal = ${DateTime.now().toLocal().toString().split(" ")[0]}'),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.healthStatus.toLowerCase() ==
                                          'sehat'
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.healthStatus,
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
                      _buildLineChart('Berat Badan', beratBadan),
                      const SizedBox(height: 10),
                      _buildLineChart('Produksi Susu', susu),
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
                      _buildLineChart('Pakan Hijauan', pakanHijau),
                      const SizedBox(height: 10),
                      _buildLineChart('Pakan Sentrat', pakanSentrat),
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
                      _buildEditableField('Kesehatan', widget.healthStatus),

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
                      TextField(
                        maxLines: 4,
                        decoration: const InputDecoration(
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
                            // Tambahkan logika untuk mengeluarkan sapi dari kandang
                            _showRemoveConfirmation();
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

 
  // Function to show confirmation dialog for removing cow
  void _showRemoveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
              'Apakah Anda yakin ingin mengeluarkan sapi ini dari kandang?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () {
                // Implement logic to remove the cow
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sapi telah dikeluarkan dari kandang.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
