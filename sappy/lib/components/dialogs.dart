import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sappy/provider/user_role.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

class NewDataDialog extends StatelessWidget {
  final String id;

  const NewDataDialog({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Input Data Baru",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: controller,
                cursorColor: const Color(0xFFC35804),
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: "Masukkan Data",
                  labelStyle: TextStyle(color: Color(0xFFC35804)),
                  suffixStyle: TextStyle(color: Color(0xFFC35804)),
                  fillColor: Color(0xFFF9E2B5),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String data = controller.text;
                    Navigator.of(context).pop(data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC35804),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditDataDialog extends StatelessWidget {
  final String id;
  final String initialData;
  final String title;
  final DateTime date;
  final Function(String)? onEditOkButton;
  

  const EditDataDialog({
    super.key,
    required this.id,
    required this.title,
    required this.initialData,
    required this.date,
    this.onEditOkButton,
  });

  TextInputType _getKeyboardType(String data) {
    if (int.tryParse(data) != null) {
      return TextInputType.number;
    } else if (double.tryParse(data) != null) {
      return const TextInputType.numberWithOptions(decimal: true);
    } else {
      return TextInputType.text;
    }
  }

  Future<int> _updateDataOnServer(BuildContext context, String input) async {
    // String filteredInput = input.replaceAll(',', '.');
    // filteredInput = filteredInput.replaceAll(RegExp(r'[^0-9.]'), '');
    String filteredInput = input;

    String filteredTitle = title.replaceAll(' ', '_').toLowerCase();
    String? formattedDate = date.toIso8601String();
    final data = {
      "tanggal": formattedDate,
      "data": filteredInput,
      "key": filteredTitle,
    };

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/updatedata/${id}');

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return 1;
      } else {
        final errorDetails = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ?? 'Tidak ada detail error'
            : 'Response kosong dari server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal mengupdate data di server dari multi chart, error $errorDetails")),
        );
        return 0;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat akan update data: $e")),
      );
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialData);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "Edit Data - $title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: controller,
                cursorColor: const Color(0xFFC35804),
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: "Masukkan Data Baru",
                  labelStyle: TextStyle(color: Color(0xFFC35804)),
                  suffixStyle: TextStyle(color: Color(0xFFC35804)),
                  fillColor: Color(0xFFF9E2B5),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                ),
                keyboardType: _getKeyboardType(initialData),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String updatedData = controller.text;

                    if (updatedData == initialData) {
                      ShowResultDialog.show(context, false,
                          customMessage: 'Data tidak berubah');
                    } else {
                      _updateDataOnServer(context, updatedData).then((result) {
                        if (result == 1) {
                          ShowResultDialog.show(context, true,
                              customMessage: 'Data keluaran berhasil diubah');
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context).pop(updatedData);
                          });
                        } else {
                          ShowResultDialog.show(context, false,
                              customMessage: 'Data gagal diubah');
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC35804),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditDataWithDropdownDialog extends StatelessWidget {
  final String id;
  final String title;
  final String initialData;
  final List<String> dropdownItems;
  final DateTime? date;

  const EditDataWithDropdownDialog({
    super.key,
    required this.id,
    required this.title,
    required this.initialData,
    required this.dropdownItems,
    this.date,
  });

  Future<int> _updateKondisiHewan(BuildContext context, String input) async {
    String filteredTitle = title.replaceAll(' ', '_').toLowerCase();
    String? formattedDate = date?.toIso8601String();
    final data = {
      "tanggal": formattedDate,
      "data": input,
      "key": filteredTitle,
    };

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/updatedata/${id}');

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      

      if (response.statusCode == 200) {
        return 1;
      } else {
        final errorDetails = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ?? 'Tidak ada detail error'
            : 'Response kosong dari server';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal mengupdate data di server dari multi chart, error $errorDetails")),
        );
        return 0;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat akan update data: $e")),
      );
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialData);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "Edit Data - $title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _getInitialDropdownValue(initialData),
                onChanged: (newValue) {
                  controller.text = newValue ?? '';
                },
                items: dropdownItems
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Pilih Data Baru",
                  labelStyle: TextStyle(color: Color(0xFFC35804)),
                  fillColor: Color(0xFFF9E2B5),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC35804))),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String updatedData = controller.text;

                    if (updatedData == initialData) {
                      ShowResultDialog.show(context, false,
                          customMessage: 'Data tidak berubah');
                    } else {
                      _updateKondisiHewan(context, updatedData).then((result) {
                        if (result == 1) {
                          ShowResultDialog.show(context, true,
                              customMessage:
                                  'Data kondisi sapi berhasil diubah');
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context).pop(updatedData);
                          });
                        } else {
                          ShowResultDialog.show(context, false,
                              customMessage: 'Data gagal diubah');
                        }
                      }).catchError((error) {
                        ShowResultDialog.show(context, false,
                            customMessage:
                                'Terjadi kesalahan: ${error.toString()}');
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC35804),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This function ensures the initial value is in the dropdown items
  String? _getInitialDropdownValue(String initialData) {
    return dropdownItems.contains(initialData) ? initialData : null;
  }
}

class HistoryDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(String value, DateTime date)? onEditDynamic;

  const HistoryDialog({
    super.key,
    required this.title,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    this.onEditDynamic,
  });

  @override
  _HistoryDialogState createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: widget.data.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> value = entry.value;
                  DateTime date = value['date'];
                  String formattedDate =
                      MaterialLocalizations.of(context).formatShortDate(date);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFC35804),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${value['data']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          if (userRole.role == 'user')
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFFC35804)),
                                  onPressed: () => widget.onEdit(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Color(0xFFC35804)),
                                  onPressed: () => widget.onDelete(index),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userRole.role == 'user')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xFFC35804),
                              )),
                        ),
                        child: const Text(
                          'Batal',
                          style:
                              TextStyle(color: Color(0xFFC35804), fontSize: 16),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFC35804),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowAddEditDataResultDialog {
  static void show(BuildContext context, bool isSuccess,
      {String? customMessage}) {
    Iconify icon;
    String message;
    Color iconColor;

    if (isSuccess) {
      icon =
          const Iconify(Ic.twotone_check_circle, color: Colors.green, size: 40);
      message = customMessage ?? 'Berhasil!';
      iconColor = Colors.green;
    } else {
      icon = const Iconify(Ic.outline_close, color: Colors.red, size: 40);
      message = customMessage ?? 'Gagal!';
      iconColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor),
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}

class ShowResultDialog {
  static void show(BuildContext context, bool isSuccess,
      {String? customMessage}) {
    Iconify icon;
    String message;
    Color iconColor;

    if (isSuccess) {
      icon =
          const Iconify(Ic.twotone_check_circle, color: Colors.green, size: 40);
      message = customMessage ?? 'Berhasil!';
      iconColor = Colors.green;
    } else {
      icon = const Iconify(Ic.outline_close, color: Colors.red, size: 40);
      message = customMessage ?? 'Gagal!';
      iconColor = Colors.red;
    }

    showDialog(
      context: Navigator.of(context, rootNavigator: true)
          .context, // Gunakan context global
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor),
                  ),
                ),
              ],
            ));
      },
    );

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      Navigator.of(context).pop();
    });
  }
}
