import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ternaknesia/provider/user_role.dart';
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

  const EditDataDialog(
      {super.key,
      required this.id,
      required this.title,
      required this.initialData});

  TextInputType _getKeyboardType(String data) {
    if (int.tryParse(data) != null) {
      return TextInputType.number;
    } else if (double.tryParse(data) != null) {
      return const TextInputType.numberWithOptions(decimal: true);
    } else {
      return TextInputType.text;
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
                      ShowResultDialog.show(context, true,
                          customMessage: 'Data berhasil diubah');
                    }

                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop(updatedData);
                    });
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

  const EditDataWithDropdownDialog({
    super.key,
    required this.id,
    required this.title,
    required this.initialData,
    required this.dropdownItems,
  });

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
                      ShowResultDialog.show(context, true,
                          customMessage: 'Data berhasil diubah');
                    }

                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop(updatedData);
                    });
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

  const HistoryDialog({
    super.key,
    required this.title,
    required this.data,
    required this.onEdit,
    required this.onDelete,
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

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      Navigator.of(context).pop();
    });
  }
}
