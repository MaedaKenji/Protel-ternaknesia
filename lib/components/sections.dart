import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/successful_dialog.dart';
import 'package:ternaknesia/provider/user_role.dart';

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
    final userRole = Provider.of<UserRole>(context);
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
        if (userRole.role == 'user')
          Row(
            children: [
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
          )
        else
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const SuccessfulDialog(
                      content: 'Riwayat berhasil ditampilkan!',
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Color(0xFFC35804)),
                  )),
              child:
                  const Text('Riwayat', style: TextStyle(color: Color(0xFFC35804)))),
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
    final userRole = Provider.of<UserRole>(context);
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
        if (userRole.role == 'user')
          Row(
            children: [
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
          )
        else
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const SuccessfulDialog(
                      content: 'Riwayat berhasil ditampilkan!',
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Color(0xFFC35804)),
                  )),
              child:
                  const Text('Riwayat', style: TextStyle(color: Color(0xFFC35804)))),
      ],
    );
  }
}
