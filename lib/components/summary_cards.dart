import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/provider/user_role.dart';

class SummaryCards extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SummaryCards({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    print(data);
    final userRole = Provider.of<UserRole>(context);

    // Define a map of summary cards for each role
    final Map<String, List<SummaryCard>> summaryCardRole = {
      'user': [
        SummaryCard(
            title: data[0]['title'] + ' L',
            subtitle: 'Perolehan susu hari ini'),
        SummaryCard(
            title: data[1]['title'], subtitle: 'Sapi yang telah diperah'),
        SummaryCard(
            title: data[2]['title'], subtitle: 'Sapi yang telah diberi pakan'),
      ],
      'doctor': [
        const SummaryCard(title: '35', subtitle: 'Sapi sehat'),
        const SummaryCard(title: '8', subtitle: 'Sapi terindikasi sakit'),
        const SummaryCard(title: '5', subtitle: 'Sapi dalam pengobatan'),
      ],
      'dokter': [
        const SummaryCard(title: '35', subtitle: 'Sapi sehat'),
        const SummaryCard(title: '8', subtitle: 'Sapi terindikasi sakit'),
        const SummaryCard(title: '5', subtitle: 'Sapi dalam pengobatan'),
      ],
      'admin': [
        const SummaryCard(title: '80,3L', subtitle: 'Perolehan susu hari ini'),
        const SummaryCard(title: '18', subtitle: 'Sapi yang telah diperah'),
        const SummaryCard(
            title: '20', subtitle: 'Sapi yang telah diberi pakan'),
      ],
    };

    // Get the correct summary cards for the current role
    List<SummaryCard> cards = summaryCardRole[userRole.role] ?? [];

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: cards,
      ),
    );
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
