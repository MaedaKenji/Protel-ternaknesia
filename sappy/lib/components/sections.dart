import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:sappy/components/successful_dialog.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';

class ConditionsSection extends StatefulWidget {
  final String healthStatus;
  final List<Map<String, dynamic>> stressLevelHistory;
  final List<Map<String, dynamic>> healthStatusHistory;
  final List<Map<String, dynamic>> birahiHistory;
  final Function() addEditStressLevelDateNow;
  final Function() addEditHealthStatusDateNow;
  final Function() addEditBirahiDateNow;
  final Function(int) editStressLevel;
  final Function(int) editHealthStatus;
  final Function(int) editBirahi;
  final Function(int) deleteStressLevel;
  final Function(int) deleteHealthStatus;
  final Function(int) deleteBirahi;
  final Function(String, String)? onDropdownValueChanged;
  final String? id;

  const ConditionsSection({
    super.key,
    required this.healthStatus,
    required this.stressLevelHistory,
    required this.healthStatusHistory,
    required this.birahiHistory,
    required this.addEditStressLevelDateNow,
    required this.addEditHealthStatusDateNow,
    required this.addEditBirahiDateNow,
    required this.editStressLevel,
    required this.editHealthStatus,
    required this.editBirahi,
    required this.deleteStressLevel,
    required this.deleteHealthStatus,
    required this.deleteBirahi,
    this.onDropdownValueChanged,
    this.id,
  });

  @override
  _ConditionsSectionState createState() => _ConditionsSectionState();
}

class _ConditionsSectionState extends State<ConditionsSection> {
  late TextEditingController stressLevelController;
  late TextEditingController healthStatusController;
  late TextEditingController birahiController;

  @override
  void initState() {
    super.initState();
    stressLevelController = TextEditingController();
    healthStatusController = TextEditingController();
    birahiController = TextEditingController();
    stressLevelController.text = widget.stressLevelHistory.isNotEmpty
        ? widget.stressLevelHistory.first['data']
        : '';
    healthStatusController.text = widget.healthStatusHistory.isNotEmpty
        ? widget.healthStatusHistory.first['data']
        : '';
    birahiController.text = widget.birahiHistory.isNotEmpty
        ? widget.birahiHistory.first['data']
        : '';
  }

  @override
  void dispose() {
    stressLevelController.dispose();
    healthStatusController.dispose();
    birahiController.dispose();
    super.dispose();
  }

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
          stressLevelController,
          widget.stressLevelHistory,
          widget.addEditStressLevelDateNow,
          widget.deleteStressLevel,
          widget.onDropdownValueChanged, // Tambahkan field di callback
        ),
        const SizedBox(height: 10),
        _buildEditableField(
          context,
          'Kesehatan',
          healthStatusController,
          widget.healthStatusHistory,
          widget.addEditHealthStatusDateNow,
          widget.deleteHealthStatus,
          widget.onDropdownValueChanged, // Tambahkan field di callback
        ),
        const SizedBox(height: 10),
        _buildEditableField(
          context,
          'Birahi',
          birahiController,
          widget.birahiHistory,
          widget.addEditBirahiDateNow,
          widget.deleteBirahi,
          widget.onDropdownValueChanged, // Tambahkan field di callback
        )
      ],
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller,
    List<Map<String, dynamic>> historyData,
    Function() addOrEditDataDateNow,
    Function(int) onDelete,
    Function(String, String)? onDropdownChanged, // Tambahkan field di callback
  ) {
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
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC35804)),
              ),
              focusColor: Color(0xFFC35804),
            ),
            child: DropdownButtonFormField<String>(
              value: _getInitialValue(controller.text, label),
              onChanged: userRole.role == 'user'
                  ? (String? newValue) {
                      setState(() {
                        controller.text = newValue ?? '';
                      });
                      if (onDropdownChanged != null) {
                        onDropdownChanged(
                            label, newValue ?? ''); // Panggil callback dengan field
                      }
                    }
                  : null,
              items: _getDropdownItems(label),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (userRole.role == 'user')
          Row(
            children: [
              IconButton(
                icon: const Iconify(
                  MaterialSymbols.history,
                  color: Color(0xFFC35804),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return HistoryDialog(
                        title: 'Riwayat $label',
                        data: historyData,
                        onEdit: (index) async {
                          Navigator.of(context).pop();
                          String initialData = historyData[index]['data'];
                          List<String> dropdownItems;

                          if (label == 'Kesehatan') {
                            dropdownItems = ['Sehat', 'Sakit'];
                          } else if (label == 'Stress Level') {
                            dropdownItems = ['Tidak', 'Ringan', 'Berat'];
                          } else if (label == 'Birahi') {
                            dropdownItems = ['Ya', 'Tidak'];
                          } else {
                            dropdownItems =
                                []; 
                          }
                        
                          String? updatedData = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return EditDataWithDropdownDialog(
                                id: widget.id??'-321',
                                initialData: initialData,
                                date: historyData[index]['date'],
                                dropdownItems: dropdownItems,
                                title: label,
                              );
                            },
                          );

                          if (updatedData != null && updatedData.isNotEmpty) {
                            setState(() {
                              historyData[index]['data'] = updatedData;
                            });

                            ShowResultDialog.show(context, true,
                                customMessage: '$label berhasil diperbarui!');
                          } else {

                            ShowResultDialog.show(context, false,
                                customMessage: 'Gagal memperbarui $label!');
                          }

                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context)
                                .pop(); 
                          });
                        },
                        onDelete: onDelete,
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
                  return HistoryDialog(
                    title: 'Riwayat $label',
                    data: historyData,
                    onEdit: (index) async {
                      Navigator.of(context).pop();
                      String initialData = historyData[index]['data'];
                      List<String> dropdownItems;

                      if (label == 'Kesehatan') {
                        dropdownItems = ['Sehat', 'Sakit'];
                      } else if (label == 'Stress Level') {
                        dropdownItems = ['Tidak', 'Ringan', 'Berat'];
                      } else if (label == 'Birahi') {
                        dropdownItems = ['Ya', 'Tidak'];
                      } else {
                        dropdownItems =
                            [];
                      }
                    },
                    onDelete: onDelete,
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
              ),
            ),
            child: const Text('Riwayat',
                style: TextStyle(color: Color(0xFFC35804))),
          ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems(String label) {
    List<String> items = [];
    if (label == 'Kesehatan') {
      items = ['Sehat', 'Sakit'];
    } else if (label == 'Stress Level') {
      items = ['Tidak', 'Ringan', 'Berat'];
    } else if (label == 'Birahi') {
      items = ['Ya', 'Tidak'];
    }

    return items
        .map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ))
        .toList();
  }

  String? _getInitialValue(String text, String label) {
    final dropdownItems = _getDropdownItems(label);
    for (var item in dropdownItems) {
      if (item.value == text) {
        return text;
      }
    }
    return null; // Return null if no match is found
  }
}
