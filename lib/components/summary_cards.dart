import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final List<Map<String, String>> data;

  const SummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((item) {
          return SummaryCard(
            title: item['title'] ?? 'Loading...',
            subtitle: item['subtitle'] ?? '',
          );
        }).toList(),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC35804),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF8F3505),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
