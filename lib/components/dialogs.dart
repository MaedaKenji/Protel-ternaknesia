import 'package:flutter/material.dart';

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
                  suffixText: "Kg/L",
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

class HistoryDialog extends StatelessWidget {
  final List<String> data;
  final Function(int) onDelete;

  const HistoryDialog({super.key, required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.history, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Riwayat Pakan",
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
              child: Column(
                children: data.asMap().entries.map((entry) {
                  int index = entry.key;
                  String value = entry.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFFC35804)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Color(0xFFC35804)),
                            onPressed: () => onDelete(index),
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC35804),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
