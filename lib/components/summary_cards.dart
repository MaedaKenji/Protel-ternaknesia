import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SummaryCard(title: '80,3L', subtitle: 'Perolehan susu hari ini'),
          SummaryCard(title: '18', subtitle: 'Sapi yang telah diperah'),
          SummaryCard(title: '20', subtitle: 'Sapi yang telah diberi pakan'),
        ],
      ),
    );
  }
}

// Komponen SummaryCard
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
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC35804),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF8F3505)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
