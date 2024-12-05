import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/components/dialogs.dart';
import 'package:ternaknesia/components/successful_dialog.dart';
import 'package:ternaknesia/provider/user_role.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';

class ConditionsSection extends StatefulWidget {
  final String healthStatus;
  final List<Map<String, dynamic>> stressLevelHistory;
  final List<Map<String, dynamic>> healthStatusHistory;
  final Function() addEditStressLevelDateNow;
  final Function() addEditHealthStatusDateNow;
  final Function(int) editStressLevel;
  final Function(int) editHealthStatus;
  final Function(int) deleteStressLevel;
  final Function(int) deleteHealthStatus;

  const ConditionsSection({
    super.key,
    required this.healthStatus,
    required this.stressLevelHistory,
    required this.healthStatusHistory,
    required this.addEditStressLevelDateNow,
    required this.addEditHealthStatusDateNow,
    required this.editStressLevel,
    required this.editHealthStatus,
    required this.deleteStressLevel,
    required this.deleteHealthStatus,
  });

  @override
  _ConditionsSectionState createState() => _ConditionsSectionState();
}

class _ConditionsSectionState extends State<ConditionsSection> {
  late TextEditingController stressLevelController;
  late TextEditingController healthStatusController;

  @override
  void initState() {
    super.initState();
    stressLevelController = TextEditingController();
    healthStatusController = TextEditingController();
    stressLevelController.text = widget.stressLevelHistory.isNotEmpty
        ? widget.stressLevelHistory.last['data']
        : '';
    healthStatusController.text = widget.healthStatus;
  }

  @override
  void dispose() {
    stressLevelController.dispose();
    healthStatusController.dispose();
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
        ),
        const SizedBox(height: 10),
        _buildEditableField(
          context,
          'Kesehatan',
          healthStatusController,
          widget.healthStatusHistory,
          widget.addEditHealthStatusDateNow,
          widget.deleteHealthStatus,
        ),
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
          child: TextFormField(
            controller: controller,
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
                icon: const Iconify(
                  HeroiconsSolid.pencil_square,
                  color: Color(0xFFC35804),
                ),
                onPressed: () {
                  // Ambil nilai dari TextFormField
                  final updatedData = controller.text.trim();
                  final currentDate = DateTime.now();

                  if (updatedData.isNotEmpty) {
                    setState(() {
                      bool isUpdated =
                          false; // Menambahkan deklarasi isUpdated di sini

                      // Cek apakah sudah ada data dengan tanggal yang sama
                      if (label == 'Stress Level') {
                        for (var i = 0;
                            i < widget.stressLevelHistory.length;
                            i++) {
                          if (widget.stressLevelHistory[i]['date'].day ==
                                  currentDate.day &&
                              widget.stressLevelHistory[i]['date'].month ==
                                  currentDate.month &&
                              widget.stressLevelHistory[i]['date'].year ==
                                  currentDate.year) {
                            // Jika data dengan tanggal yang sama ditemukan, update
                            widget.stressLevelHistory[i]['data'] = updatedData;
                            isUpdated = true;
                            break;
                          }
                        }

                        if (!isUpdated) {
                          // Jika tidak ada data dengan tanggal yang sama, tambah data baru
                          widget.stressLevelHistory.add({
                            'date': currentDate,
                            'data': updatedData,
                          });
                        }
                      } else {
                        for (var i = 0;
                            i < widget.healthStatusHistory.length;
                            i++) {
                          if (widget.healthStatusHistory[i]['date'].day ==
                                  currentDate.day &&
                              widget.healthStatusHistory[i]['date'].month ==
                                  currentDate.month &&
                              widget.healthStatusHistory[i]['date'].year ==
                                  currentDate.year) {
                            // Jika data dengan tanggal yang sama ditemukan, update
                            widget.healthStatusHistory[i]['data'] = updatedData;
                            isUpdated = true;
                            break;
                          }
                        }

                        if (!isUpdated) {
                          // Jika tidak ada data dengan tanggal yang sama, tambah data baru
                          widget.healthStatusHistory.add({
                            'date': currentDate,
                            'data': updatedData,
                          });
                        }
                      }

                      // Menampilkan hasil sukses
                      ShowAddEditDataResultDialog.show(context, true,
                          customMessage:
                              '$label berhasil ${isUpdated ? "diperbarui" : "ditambahkan"}!');
                    });
                  } else {
                    // Menampilkan hasil gagal jika input kosong
                    ShowAddEditDataResultDialog.show(context, false,
                        customMessage:
                            'Gagal menambahkan atau memperbarui data! Input tidak boleh kosong.');
                  }
                },
              ),
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

                          // Menampilkan EditDataDialog dan menunggu hasilnya
                          String? updatedData = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return EditDataDialog(
                                id: historyData[index]['id'].toString(),
                                initialData: initialData,
                                title: MaterialLocalizations.of(context)
                                    .formatShortDate(historyData[index]['date'])
                                    .toString(),
                              );
                            },
                          );

                          if (updatedData != null && updatedData.isNotEmpty) {
                            setState(() {
                              historyData[index]['data'] = updatedData;
                            });

                            // Menampilkan hasil sukses
                            ShowResultDialog.show(context, true,
                                customMessage: '$label berhasil diperbarui!');
                          } else {
                            // Menampilkan hasil gagal
                            ShowResultDialog.show(context, false,
                                customMessage: 'Gagal memperbarui $label!');
                          }

                          // Menutup dialog setelah menampilkan hasil (tunda agar dialog berhasil muncul)
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context)
                                .pop(); // Menutup dialog setelah 2 detik
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
              ),
            ),
            child: const Text('Riwayat',
                style: TextStyle(color: Color(0xFFC35804))),
          ),
      ],
    );
  }
}

class PopulationStructureSection extends StatefulWidget {
  final List<Map<String, dynamic>> birahiHistory;
  final List<Map<String, dynamic>> statusHistory;
  final Function() addEditBirahiDateNow;
  final Function() addEditStatusDateNow;
  final Function(int) editBirahi;
  final Function(int) editStatus;
  final Function(int) deleteBirahi;
  final Function(int) deleteStatus;

  const PopulationStructureSection(
      {super.key,
      required this.birahiHistory,
      required this.statusHistory,
      required this.addEditBirahiDateNow,
      required this.addEditStatusDateNow,
      required this.editBirahi,
      required this.editStatus,
      required this.deleteBirahi,
      required this.deleteStatus});

  @override
  _PopulationStructureSectionState createState() =>
      _PopulationStructureSectionState();
}

class _PopulationStructureSectionState
    extends State<PopulationStructureSection> {
  late TextEditingController birahiController;
  late TextEditingController statusController;

  @override
  void initState() {
    super.initState();
    birahiController = TextEditingController();
    statusController = TextEditingController();
    birahiController.text = widget.birahiHistory.isNotEmpty
        ? widget.birahiHistory.last['data']
        : '';
    statusController.text = widget.statusHistory.isNotEmpty
        ? widget.statusHistory.last['data']
        : '';
  }

  @override
  void dispose() {
    birahiController.dispose();
    statusController.dispose();
    super.dispose();
  }

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
            context,
            'Birahi',
            birahiController,
            widget.birahiHistory,
            widget.addEditBirahiDateNow,
            widget.deleteBirahi),
        const SizedBox(height: 10),
        _buildEditableField(
            context,
            'Status',
            statusController,
            widget.statusHistory,
            widget.addEditStatusDateNow,
            widget.deleteStatus),
      ],
    );
  }

  Widget _buildEditableField(
      BuildContext context,
      String label,
      TextEditingController controller,
      List<Map<String, dynamic>> historyData,
      Function() addOrEditDataDateNow,
      Function(int) onDelete) {
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
            controller: controller,
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
                    // Ambil nilai dari TextFormField
                    final updatedData = controller.text.trim();
                    final currentDate = DateTime.now();

                    if (updatedData.isNotEmpty) {
                      setState(() {
                        bool isUpdated = false;

                        // Cek apakah sudah ada data dengan tanggal yang sama
                        if (label == 'Birahi') {
                          for (var i = 0;
                              i < widget.birahiHistory.length;
                              i++) {
                            if (widget.birahiHistory[i]['date'].day ==
                                    currentDate.day &&
                                widget.birahiHistory[i]['date'].month ==
                                    currentDate.month &&
                                widget.birahiHistory[i]['date'].year ==
                                    currentDate.year) {
                              // Jika data dengan tanggal yang sama ditemukan, update
                              widget.birahiHistory[i]['data'] = updatedData;
                              isUpdated = true;
                              break;
                            }
                          }

                          if (!isUpdated) {
                            // Jika tidak ada data dengan tanggal yang sama, tambah data baru
                            widget.birahiHistory.add({
                              'date': currentDate,
                              'data': updatedData,
                            });
                          }
                        } else {
                          for (var i = 0;
                              i < widget.statusHistory.length;
                              i++) {
                            if (widget.statusHistory[i]['date'].day ==
                                    currentDate.day &&
                                widget.statusHistory[i]['date'].month ==
                                    currentDate.month &&
                                widget.statusHistory[i]['date'].year ==
                                    currentDate.year) {
                              // Jika data dengan tanggal yang sama ditemukan, update
                              widget.statusHistory[i]['data'] = updatedData;
                              isUpdated = true;
                              break;
                            }
                          }

                          if (!isUpdated) {
                            // Jika tidak ada data dengan tanggal yang sama, tambah data baru
                            widget.statusHistory.add({
                              'date': currentDate,
                              'data': updatedData,
                            });
                          }
                        }

                        // Menampilkan hasil sukses
                        ShowAddEditDataResultDialog.show(context, true,
                            customMessage:
                                '$label berhasil ${isUpdated ? "diperbarui" : "ditambahkan"}!');
                      });
                    } else {
                      // Menampilkan hasil gagal jika input kosong
                      ShowAddEditDataResultDialog.show(context, false,
                          customMessage:
                              'Gagal menambahkan atau memperbarui data! Input tidak boleh kosong.');
                    }
                  }),
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
                          onEdit: (index) async {
                            Navigator.of(context).pop();
                            String initialData =
                                historyData[index]['data'].toString();

                            // Menampilkan EditDataDialog dan menunggu hasilnya
                            String? updatedData = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                return EditDataDialog(
                                    id: historyData[index]['id'].toString(),
                                    initialData: initialData,
                                    title: MaterialLocalizations.of(context)
                                        .formatShortDate(
                                            historyData[index]['date'])
                                        .toString());
                              },
                            );

                            if (updatedData != null && updatedData.isNotEmpty) {
                              historyData[index]['data'] = updatedData;
                            }
                          },
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
