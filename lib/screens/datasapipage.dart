// ignore_for_file: unnecessary_string_interpolations

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

  const DataSapiPage({
    super.key,
    required this.id,
    required this.gender,
    required this.age,
    required this.healthStatus,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DataSapiPageState createState() => _DataSapiPageState();
}

class _DataSapiPageState extends State<DataSapiPage> {
  int _currentChartIndex = 0;
  List<String> historyData = ['70 Kg', '65 Kg', '72 Kg', '68 Kg'];
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
          susu = List<double>.from(data['recent_milk_production']?.map(
                  (item) => double.parse(item['production_amount'] ?? '0')) ??
              []);
          pakanHijau = List<double>.from(data['recent_feed_hijauan']
                  ?.map((item) => double.parse(item['amount'] ?? '0')) ??
              []);
          pakanSentrat = List<double>.from(data['recent_feed_sentrate']
                  ?.map((item) => double.parse(item['amount'] ?? '0')) ??
              []);
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
    } 
    else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC35804),
        title: Text('ID SAPI: ${widget.id}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),

            const Text(
              'PRODUKSI SUSU & BERAT BADAN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousChart,
                ),
                Expanded(child: _buildChart()),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextChart,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.orange),
                  onPressed: _addNewData,
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.orange),
                  onPressed: _showHistory,
                ),
              ],
            ),

            _buildConditionsSection(),
            const SizedBox(height: 20),
            _buildPopulationStructureSection(),
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

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/cow.png'),
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
                  Text('Tanggal = ${DateTime.now().toString().split(" ")[0]}'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.healthStatus.toUpperCase() == 'SEHAT' ? Colors.green : Colors.red,
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
    );
  }

  Widget _buildChart() {
    return IndexedStack(
      index: _currentChartIndex,
      children: [
        _buildLineChart('PRODUKSI SUSU', susu),
        _buildLineChart('BERAT BADAN', beratBadan),
        _buildLineChart('PAKAN HIJAU', pakanHijau),
        _buildLineChart('PAKAN SENTRAT', pakanSentrat),
      ],
    );
  }

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

    // Convert values to FlSpot list for dynamic chart data
    List<FlSpot> spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble() + 1, entry.value);
    }).toList();

    double currentValue = values.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFFC35804),
                  dotData: const FlDotData(show: true),
                ),
              ],
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
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


  Widget _buildConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPopulationStructureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

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
            icon: const Icon(Icons.edit, color: Color(0xFFC35804)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Dialog untuk menambahkan data baru
class _NewDataDialog extends StatelessWidget {
  final String id;

  const _NewDataDialog({required this.id});

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
