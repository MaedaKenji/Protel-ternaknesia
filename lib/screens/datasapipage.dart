import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataSapiPage extends StatefulWidget {
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
  _DataSapiPageState createState() => _DataSapiPageState();
}

class _DataSapiPageState extends State<DataSapiPage> {
  int _currentChartIndex = 0;
  List<String> historyData = ['70 Kg', '65 Kg', '72 Kg', '68 Kg'];

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

  void _addNewData() async {
    String? newData = await showDialog(
      context: context,
      builder: (context) {
        return _NewDataDialog();
      },
    );
    if (newData != null) {
      setState(() {
        historyData.add(newData);
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC35804),
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
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousChart,
                ),
                Expanded(child: _buildChart()),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextChart,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.orange),
                  onPressed: _addNewData,
                ),
                IconButton(
                  icon: Icon(Icons.history, color: Colors.orange),
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
                color: widget.healthStatus == 'SEHAT' ? Colors.green : Colors.red,
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
        _buildLineChart('Berat Badan', 70),
        _buildLineChart('Produksi Susu', 25),
        _buildLineChart('Pakan Hijauan', 30),
        _buildLineChart('Pakan Sentrat', 20),
      ],
    );
  }

  Widget _buildLineChart(String title, double currentValue) {
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
                  spots: [
                    FlSpot(1, 20),
                    FlSpot(2, 30),
                    FlSpot(3, 40),
                    FlSpot(4, currentValue),
                    FlSpot(5, 60),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFFC35804),
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
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: Text("SILAHKAN INPUT DATA BARU :"),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(suffixText: "Kg"),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("BATAL"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text + " Kg"),
          child: Text("OK"),
        ),
      ],
    );
  }
}

// Dialog untuk riwayat data
class _HistoryDialog extends StatelessWidget {
  final List<String> data;
  final Function(int) onDelete;

  _HistoryDialog({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("RIWAYAT PAKAN"),
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
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {}, // Logika untuk edit data
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.orange),
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
          child: Text("BATAL"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
      ],
    );
  }
}
