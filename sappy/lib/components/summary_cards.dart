import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sappy/provider/user_role.dart';

class SummaryCards extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SummaryCards({
    super.key,
    required this.data,
  });

@override
Widget build(BuildContext context) {
  final userRole = Provider.of<UserRole>(context);

  // Dapatkan kartu berdasarkan peran pengguna
  List<SummaryCard> cards = getSummaryCards(userRole.role);

  return IntrinsicHeight(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cards,
    ),
  );
}

// Fungsi untuk mendapatkan summary card berdasarkan peran pengguna
List<SummaryCard> getSummaryCards(String role) {
  String getValue(int index, String defaultValue) {
    return data.length > index && data[index]['value'] != null
        ? data[index]['value'].toString()
        : defaultValue;
  }

  switch (role) {
    case 'user':
      return [
        SummaryCard(
            title: "${getValue(0, '0')} L",
            subtitle: 'Perolehan susu hari ini'),
        SummaryCard(
            title: getValue(1, '0'), subtitle: 'Sapi yang telah diperah'),
        SummaryCard(
            title: getValue(2, '0'), subtitle: 'Sapi yang telah diberi pakan'),
      ];
    case 'doctor':
    case 'dokter':
      return [
        SummaryCard(title: getValue(0, '0'), subtitle: 'Sapi sehat'),
        SummaryCard(
            title: getValue(1, '0'), subtitle: 'Sapi terindikasi sakit'),
      ];
    case 'admin':
      return [
        SummaryCard(
            title: "${getValue(0, '0')} L",
            subtitle: 'Perolehan susu hari ini'),
        SummaryCard(
            title: getValue(1, '0'), subtitle: 'Sapi yang telah diperah'),
        SummaryCard(
            title: getValue(2, '0'), subtitle: 'Sapi yang telah diberi pakan'),
      ];
    default:
      return [];
  }
}
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const SummaryCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9E2B5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC35804),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC35804),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11, color: Color(0xFF8F3505)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
