import 'package:flutter/material.dart';

class InputDataPage extends StatelessWidget {
  const InputDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'INPUT PAGE',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar dan Identitas Sapi
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                      'assets/images/profile_image.png'), // Gambar lokal
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SAPI 1',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID Sapi = 1390924248',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Bagian Pakan
            const Text(
              'Pakan yang diberikan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextInput('Pakan Hijauan', 'Kg'),
            const SizedBox(height: 10),
            _buildTextInput('Pakan Sentrat', 'Kg'),
            const SizedBox(height: 10),
            _buildTextInput('Berat Badan', 'Kg'),
            const SizedBox(height: 10),
            _buildTextInput('Hasil Perah', 'Liter'),

            const SizedBox(height: 30),

            // Kondisi Hewan
            const Text(
              'Kondisi Hewan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextInput('Stress Level', ''),
            const SizedBox(height: 10),
            _buildRadioInput('Sakit'),

            const SizedBox(height: 30),

            // Struktur Populasi
            const Text(
              'Struktur Populasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRadioInput('Birahi'),

            const SizedBox(height: 30),

            // Catatan
            const Text(
              'Catatan :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan catatan',
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Masukkan Data
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Tambahkan logika masukkan data di sini
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text(
                  'MASUKKAN DATA',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Indeks 'Input' aktif
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: 'Input',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Fungsi untuk membuat input teks dengan satuan di samping
  Widget _buildTextInput(String label, String unit) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          unit,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // Fungsi untuk membuat input radio button
  Widget _buildRadioInput(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            const Text('Ya'),
            Radio(
              value: true,
              groupValue: null, // Tambahkan logika state di sini
              onChanged: (value) {},
            ),
            const Text('Tidak'),
            Radio(
              value: false,
              groupValue: null, // Tambahkan logika state di sini
              onChanged: (value) {},
            ),
          ],
        ),
      ],
    );
  }
}
