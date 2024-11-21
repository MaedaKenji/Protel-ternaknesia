import 'package:flutter/material.dart';
import 'package:ternaknesia/components/successful_dialog.dart';

class ConditionsSection extends StatelessWidget {
  final String healthStatus;

  const ConditionsSection({super.key, required this.healthStatus});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 10),
        _buildEditableField(context, 'Stress Level', 'Normal'),
        const SizedBox(height: 10),
        _buildEditableField(context, 'Kesehatan', healthStatus),
      ],
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8F3505),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFC35804)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessfulDialog(
                  content: 'Data berhasil diubah!',
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Color(0xFFC35804)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessfulDialog(
                  content: 'Catatan berhasil disimpan!',
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class PopulationStructureSection extends StatelessWidget {
  const PopulationStructureSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 10),
        _buildEditableField(context, 'Birahi', 'Tidak'),
        const SizedBox(height: 10),
        _buildEditableField(context, 'Status', 'Aktif'),
      ],
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8F3505),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFC35804)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessfulDialog(
                  content: 'Data berhasil diubah!',
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Color(0xFFC35804)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessfulDialog(
                  content: 'Catatan berhasil disimpan!',
                );
              },
            );
          },
        ),
      ],
    );
  }
}
