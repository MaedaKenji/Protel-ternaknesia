import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/dialogs.dart';
import 'package:ternaknesia/components/successful_dialog.dart';
import 'package:ternaknesia/provider/user_role.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';

class ConditionsSection extends StatelessWidget {
  final String healthStatus;
  final List<Map<String, dynamic>> stressLevelHistory;
  final List<Map<String, dynamic>> healthStatusHistory;
  final Function(int) deleteStressLevel;
  final Function(int) deleteHealthStatus;

  const ConditionsSection(
      {super.key,
      required this.healthStatus,
      required this.stressLevelHistory,
      required this.healthStatusHistory,
      required this.deleteStressLevel,
      required this.deleteHealthStatus});

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
        _buildEditableField(
          context,
          'Stress Level',
          'Normal',
          stressLevelHistory,
          deleteStressLevel,
        ),
        const SizedBox(height: 10),
        _buildEditableField(context, 'Kesehatan', healthStatus,
            healthStatusHistory, deleteHealthStatus),
      ],
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value,
      List<Map<String, dynamic>> historyData, Function(int) onDelete) {
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
                icon: const Iconify(HeroiconsSolid.pencil_square,
                    color: Color(0xFFC35804)),
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
                icon: const Iconify(MaterialSymbols.history,
                    color: Color(0xFFC35804)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return HistoryDialog(
                          title: 'Riwayat $label',
                          data: historyData,
                          onDelete: onDelete);
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
              child: const Text('Riwayat',
                  style: TextStyle(color: Color(0xFFC35804)))),
      ],
    );
  }
}

class PopulationStructureSection extends StatelessWidget {
  final List<Map<String, dynamic>> birahiHistory;
  final List<Map<String, dynamic>> statusHistory;
  final Function(int) deleteBirahi;
  final Function(int) deleteStatus;

  const PopulationStructureSection(
      {super.key,
      required this.birahiHistory,
      required this.statusHistory,
      required this.deleteBirahi,
      required this.deleteStatus});

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
        _buildEditableField(
            context, 'Birahi', 'Tidak', birahiHistory, deleteBirahi),
        const SizedBox(height: 10),
        _buildEditableField(
            context, 'Status', 'Aktif', statusHistory, deleteStatus),
      ],
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value,
      List<Map<String, dynamic>> historyData, Function(int) onDelete) {
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
                icon: const Iconify(HeroiconsSolid.pencil_square,
                    color: Color(0xFFC35804)),
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
                icon: const Iconify(MaterialSymbols.history,
                    color: Color(0xFFC35804)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return HistoryDialog(
                          title: 'Riwayat $label',
                          data: historyData,
                          onDelete: (index) {
                            historyData.removeAt(index);
                          });
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
              child: const Text('Riwayat',
                  style: TextStyle(color: Color(0xFFC35804)))),
      ],
    );
  }
}
