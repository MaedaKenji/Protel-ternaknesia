// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sappy/components/custom_pop_up_dialog.dart';
import 'package:sappy/components/dialogs.dart';
import 'package:sappy/components/multi_chart_container.dart';
import 'package:sappy/components/sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sappy/provider/user_role.dart';
import 'package:sappy/screens/addeditnfctag.dart';

// ignore: must_be_immutable
class DataSapiPage extends StatefulWidget {
  String id;
  String? gender;
  String? age;
  String? healthStatus;
  bool? isProductive;
  bool? isConnectedToNFCTag;
  double lastWeight;
  double predictionSusu = 0;
  double susuSaatIni = 0;
  double beratSaatIni = 0;
  double pakanHijauSaatIni = 0;
  double pakanSentratSaatIni = 0;

  DataSapiPage({
    super.key,
    this.lastWeight = 10,
    required this.id,
    this.gender,
    required this.age,
    this.healthStatus,
    this.isProductive,
    this.isConnectedToNFCTag,
  });

  @override
  _DataSapiPageState createState() => _DataSapiPageState();
}

class _DataSapiPageState extends State<DataSapiPage> {
  List<double> beratBadan = [];
  List<double> susu = [];
  List<double> pakanHijau = [];
  List<double> pakanSentrat = [];
  List<String> historyData = [];
  List<Map<String, dynamic>> historyDataNotes = [];
  List<Map<String, dynamic>> historyDataDiagnosis = [];

  double lastWeight = 0;
  Random random = Random();
  int currentIndex = 0;
  bool isLoading = true;
  String errorMessage = '';

  Map<String, Map<String, List<FlSpot>>> milkAndWeightDataDinamis = {
    'produksiSusu': {},
    'beratBadan': {},
  };
  Map<String, List<Map<String, dynamic>>>
      milkProductionAndWeightHistoryDynamic = {
    'produksiSusu': [],
    'beratBadan': [],
  };
  Map<String, Map<String, List<FlSpot>>> dinamisFeedData = {
    'pakanHijau': {},
    'pakanSentrat': {}
  };
  Map<String, List<Map<String, dynamic>>> dinamisFeedDataHistory = {
    'pakanHijau': [],
    'pakanSentrat': [],
  };

  TextEditingController stressLevelController = TextEditingController();
  TextEditingController healthStatusController = TextEditingController();
  TextEditingController birahiController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController _diagnosisController = TextEditingController();

  Map<String, Map<String, List<FlSpot>>> feedData = {
    'pakanHijau': {
      'Januari': [
        const FlSpot(0, 30),
        const FlSpot(1, 35),
        const FlSpot(2, 40)
      ],
      'Februari': [
        const FlSpot(0, 32),
        const FlSpot(1, 33),
        const FlSpot(2, 36)
      ],
    },
    'pakanSentrat': {
      'Januari': [
        const FlSpot(0, 20),
        const FlSpot(1, 25),
        const FlSpot(2, 30)
      ],
      'Februari': [
        const FlSpot(0, 22),
        const FlSpot(1, 23),
        const FlSpot(2, 26)
      ],
    },
  };
  Map<String, List<Map<String, dynamic>>> feedDataHistory = {
    'pakanHijau': [
      {'date': DateTime(2024, 11, 28), 'data': '50 kg'},
      {'date': DateTime(2024, 11, 29), 'data': '52 kg'},
      {'date': DateTime(2024, 11, 30), 'data': '55 kg'},
      {'date': DateTime(2024, 12, 1), 'data': '48 kg'},
    ],
    'pakanSentrat': [
      {'date': DateTime(2024, 11, 28), 'data': '60 kg'},
      {'date': DateTime(2024, 11, 29), 'data': '58 kg'},
      {'date': DateTime(2024, 11, 30), 'data': '62 kg'},
      {'date': DateTime(2024, 12, 1), 'data': '65 kg'},
    ],
  };
  // Start milkAndWeightData
  Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
    'produksiSusu': {
      'Januari': [
        const FlSpot(0, 50),
        const FlSpot(1, 55),
        const FlSpot(2, 60)
      ],
      'Februari': [
        const FlSpot(0, 52),
        const FlSpot(1, 53),
        const FlSpot(2, 56)
      ],
    },
    'beratBadan': {
      'Januari': [
        const FlSpot(0, 70),
        const FlSpot(1, 72),
        const FlSpot(2, 75)
      ],
      'Februari': [
        const FlSpot(0, 68),
        const FlSpot(1, 69),
        const FlSpot(2, 71)
      ],
    },
  };
  Map<String, List<Map<String, dynamic>>> milkProductionAndWeightHistory = {
    'produksiSusu': [],
    'beratBadan': [],
  };
  // End milkAndWeightData
  List<Map<String, dynamic>> stressLevelHistory = [
    {'date': DateTime(2024, 11, 28), 'data': 'Tidak'},
    {'date': DateTime(2024, 11, 29), 'data': 'Ringan'},
    {'date': DateTime(2024, 11, 30), 'data': 'Berat'},
    {'date': DateTime(2024, 12, 6), 'data': 'Ringan'},
  ];
  List<Map<String, dynamic>> healthStatusHistory = [
    {'date': DateTime(2024, 11, 28), 'data': 'Sehat'},
    {'date': DateTime(2024, 11, 29), 'data': 'Sakit'},
    {'date': DateTime(2024, 11, 30), 'data': 'Sehat'},
    {'date': DateTime(2024, 12, 1), 'data': 'Sakit'},
  ];
  List<Map<String, dynamic>> birahiHistory = [
    {'date': DateTime(2024, 11, 28), 'data': 'Ya'},
    {'date': DateTime(2024, 11, 29), 'data': 'Tidak'},
    {'date': DateTime(2024, 11, 30), 'data': 'Ya'},
    {'date': DateTime(2024, 12, 1), 'data': 'Ya'},
  ];

  List<Map<String, dynamic>> stressLevelHistoryDinamis = [];
  List<Map<String, dynamic>> healthStatusHistoryDinamis = [];
  List<Map<String, dynamic>> birahiHistoryDinamis = [];

  @override
  void initState() {
    super.initState();
    lastWeight = widget.lastWeight;
    _refreshData();
  }

  Map<String, Map<String, List<FlSpot>>> processFeedData(
      List<Map<String, dynamic>> feedHijauan,
      List<Map<String, dynamic>> feedSentrate) {
    Map<String, Map<String, List<FlSpot>>> feedData = {
      'pakanHijau': {},
      'pakanSentrat': {},
    };

    feedHijauan.sort((a, b) {
      DateTime dateA = DateTime.parse(a['tanggal']);
      DateTime dateB = DateTime.parse(b['tanggal']);
      return dateA.compareTo(dateB);
    });

    for (var feed in feedHijauan) {
      DateTime date = DateTime.parse(feed['tanggal']);
      double amount = double.tryParse(feed['pakan']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      feedData['pakanHijau'] ??= {};
      feedData['pakanHijau']?[monthWithYear] ??= [];
      feedData['pakanHijau']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), amount));
    }

    feedSentrate.sort((a, b) {
      DateTime dateA = DateTime.parse(a['tanggal']);
      DateTime dateB = DateTime.parse(b['tanggal']);
      return dateA.compareTo(dateB);
    });

    for (var feed in feedSentrate) {
      DateTime date = DateTime.parse(feed['tanggal']);
      double amount = double.tryParse(feed['pakan']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      feedData['pakanSentrat'] ??= {};
      feedData['pakanSentrat']?[monthWithYear] ??= [];
      feedData['pakanSentrat']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), amount));
    }

    return feedData;
  }

  Map<String, Map<String, List<FlSpot>>> processMilkAndWeightData(
      List<Map<String, dynamic>> milkProduction,
      List<Map<String, dynamic>> weights) {
    Map<String, Map<String, List<FlSpot>>> milkAndWeightData = {
      'produksiSusu': {},
      'beratBadan': {},
    };

    milkProduction.sort((a, b) {
      DateTime dateA = DateTime.parse(a['tanggal']);
      DateTime dateB = DateTime.parse(b['tanggal']);
      return dateA.compareTo(dateB);
    });

    for (var milk in milkProduction) {
      DateTime date = DateTime.parse(milk['tanggal']);
      double productionAmount =
          double.tryParse(milk['produksi']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      milkAndWeightData['produksiSusu'] ??= {};
      milkAndWeightData['produksiSusu']?[monthWithYear] ??= [];
      milkAndWeightData['produksiSusu']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), productionAmount));
    }

    weights.sort((a, b) {
      DateTime dateA = DateTime.parse(a['tanggal']);
      DateTime dateB = DateTime.parse(b['tanggal']);
      return dateA.compareTo(dateB);
    });

    for (var weight in weights) {
      DateTime date = DateTime.parse(weight['tanggal']);
      double weightValue =
          double.tryParse(weight['berat']?.toString() ?? '0') ?? 0;
      String monthWithYear = _getMonthWithYear(date);

      milkAndWeightData['beratBadan'] ??= {};
      milkAndWeightData['beratBadan']?[monthWithYear] ??= [];
      milkAndWeightData['beratBadan']?[monthWithYear]!
          .add(FlSpot(date.day.toDouble(), weightValue));
    }

    return milkAndWeightData;
  }

  String _getMonthWithYear(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String formattedDate(DateTime date) {
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  Map<String, Map<String, List<FlSpot>>> processMilkAndWeightDataDinamis(
    List<Map<String, dynamic>> milkProduction,
    List<Map<String, dynamic>> weightHistory,
  ) {
    Map<String, Map<String, List<FlSpot>>> result = {
      'produksiSusu': {},
      'beratBadan': {},
    };

    for (var item in milkProduction) {
      String monthYear = DateFormat('MMMM yyyy').format(item['date']);
      if (!result['produksiSusu']!.containsKey(monthYear)) {
        result['produksiSusu']![monthYear] = [];
      }
      int day = DateTime.parse(item['date'].toString()).day; // Extract the day
      result['produksiSusu']![monthYear]!.add(FlSpot(
          day.toDouble(), double.parse(item['data'].replaceAll(' L', ''))));
    }

    // Proses berat badan
    for (var item in weightHistory) {
      String monthYear = DateFormat('MMMM yyyy').format(item['date']);
      if (!result['beratBadan']!.containsKey(monthYear)) {
        result['beratBadan']![monthYear] = [];
      }
      int day = DateTime.parse(item['date'].toString()).day; // Extract the day
      result['beratBadan']![monthYear]!.add(FlSpot(
          day.toDouble(), double.parse(item['data'].replaceAll(' Kg', ''))));
    }

    return result;
  }

  Map<String, Map<String, List<FlSpot>>> processFeed(
    List<Map<String, dynamic>> feedDataHijauan,
    List<Map<String, dynamic>> feedDataSentrat,
  ) {
    Map<String, Map<String, List<FlSpot>>> result = {
      'pakanHijau': {},
      'pakanSentrat': {},
    };

    // Proses pakan hijauan
    for (var item in feedDataHijauan) {
      String monthYear = DateFormat('MMMM yyyy').format(item['date']);
      if (!result['pakanHijau']!.containsKey(monthYear)) {
        result['pakanHijau']![monthYear] = [];
      }
      int day = DateTime.parse(item['date'].toString()).day; // Extract the day
      result['pakanHijau']![monthYear]!.add(FlSpot(
          day.toDouble(), double.parse(item['data'].replaceAll(' kg', ''))));
    }

    // Proses pakan sentrat
    for (var item in feedDataSentrat) {
      String monthYear = DateFormat('MMMM yyyy').format(item['date']);
      if (!result['pakanSentrat']!.containsKey(monthYear)) {
        result['pakanSentrat']![monthYear] = [];
      }
      int day = DateTime.parse(item['date'].toString()).day; // Extract the day
      result['pakanSentrat']![monthYear]!.add(FlSpot(
          day.toDouble(), double.parse(item['data'].replaceAll(' kg', ''))));
    }

    return result;
  }

  void _handleDropdownValueChange(String field, String newValue) {
    setState(() {
      if (field == 'Stress Level') {
        stressLevelController.text = newValue;
      } else if (field == 'Kesehatan') {
        healthStatusController.text = newValue;
      } else if (field == 'Birahi') {
        birahiController.text = newValue;
      }
    });
  }

  void updateChartData(Map<String, dynamic> apiResponse) {
    List<Map<String, dynamic>> recentFeedHijauan =
        List<Map<String, dynamic>>.from(apiResponse['recent_feed_hijauan']);
    List<Map<String, dynamic>> recentFeedSentrate =
        List<Map<String, dynamic>>.from(apiResponse['recent_feed_sentrate']);
    List<Map<String, dynamic>> recentMilkProduction =
        List<Map<String, dynamic>>.from(apiResponse['recent_milk_production']);
    List<Map<String, dynamic>> recentWeights =
        List<Map<String, dynamic>>.from(apiResponse['recent_weights']);

    final feedData = processFeedData(recentFeedHijauan, recentFeedSentrate);
    final milkAndWeightData =
        processMilkAndWeightData(recentMilkProduction, recentWeights);

    setState(() {
      this.feedData = feedData;
      this.milkAndWeightData = milkAndWeightData;
    });
  }

  void _showNotesHistory() async {
    await showDialog(
      context: context,
      builder: (context) {
        return HistoryDialog(
          title: 'Riwayat Catatan',
          data: historyDataNotes,
          onEdit: (index) async {
            String initialData = historyDataNotes[index]['data'];
            await showDialog<String>(
                context: context,
                builder: (context) {
                  return EditDataDialog(
                    id: widget.id,
                    initialData: initialData,
                    title: "Catatan",
                    date: historyDataNotes[index]['date'],
                  );
                });
          },
          onDelete: (index) async {
            if (_deleteData(historyDataNotes[index]['date'], 'catatan') ==
                200) {
              setState(() {
                historyDataNotes.removeAt(index);
              });
            }

            Navigator.of(context).pop();
          },
          onEditDynamic: (value, date) => {},
        );
      },
    );
  }

  void _showTreatmentHistory() async {
    await showDialog(
      context: context,
      builder: (context) {
        return HistoryDialog(
          title: 'Riwayat Pengobatan',
          data: historyDataDiagnosis,
          onEdit: (index) async {
            String initialData = historyDataDiagnosis[index]['data'];

            await showDialog<String>(
              context: context,
              builder: (context) {
                return EditDataDialog(
                  id: widget.id,
                  initialData: initialData,
                  title: "Pengobatan",
                  date: historyDataDiagnosis[index]['date'],
                );
              },
            );
          },
          onDelete: (index) {
            if (_deleteData(historyDataDiagnosis[index]['date'], 'diagnosis') ==
                200) {
              setState(() {
                historyDataDiagnosis.removeAt(index);
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<int> _deleteData(DateTime date, String key) async {
    final url =
        '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/deletedata/${widget.id}';

    final Map<String, dynamic> data = {
      'id': widget.id,
      'tanggal': date.toIso8601String(),
      'key': key,
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        ShowResultDialog.show(context, true,
            customMessage: 'Data berhasil dihapus!');
        return 200;
      } else {
        ShowResultDialog.show(context, false,
            customMessage: 'Gagal menghapus data');
        return 400;
      }
    } catch (error) {
      ShowResultDialog.show(context, false,
          customMessage: 'Terjadi kesalahan: $error');
      return 400;
    }
  }

  Future<void> _submitData() async {
    final url =
        '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/kondisi/${widget.id}';

    // Membuat data yang akan dikirim
    final Map<String, dynamic> data = {
      'stress_level': stressLevelController.text,
      'sakit': healthStatusController.text,
      'birahi': birahiController.text,
      'catatan': catatanController.text,
    };

    try {
      // Mengirim permintaan POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      // Menangani respons dari server
      if (response.statusCode == 200) {
        setState(() {
          widget.healthStatus = healthStatusHistoryDinamis[0]["data"];
        });
        ShowResultDialog.show(context, true,
            customMessage: 'Data berhasil disimpan!');
      } else {
        // Jika gagal, tampilkan error
        ShowResultDialog.show(context, false,
            customMessage: 'Gagal mengirim data');
      }
    } catch (error) {
      // Jika terjadi error
      ShowResultDialog.show(context, false,
          customMessage: 'Terjadi kesalahan: $error');
    }
  }

  Future<void> _updateDiagnosis(String diagnosis) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/update-catatan/dokter'), // Ganti dengan URL server
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cow_id': widget.id,
          'catatan': diagnosis,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dikirim!')),
        );
      } else {
        // Gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal mengirim data ke server response status code != 201, error details: ${response.body} ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<http.Response> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/${widget.id}');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      // if (response.statusCode != 200) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Gagal mendapatkan data: ${response.body}'),
      //     ),
      //   );
      // }

      final data = json.decode(response.body);

      // Fetch data prediksi susu
      final urlString =
          '${dotenv.env['BASE_URL']}:${dotenv.env['PORT']}/api/cows/predict-milk/${widget.id}';
      final urlSusu = Uri.parse(urlString);
      final responseSusu =
          await http.get(urlSusu).timeout(const Duration(seconds: 5));

      double predictedDailyMilk = 0.0; // Default nilai jika gagal
      if (responseSusu.statusCode == 200) {
        try {
          final dataSusu = json.decode(responseSusu.body);
            predictedDailyMilk = dataSusu['predicted_daily_milk'] ?? 0.0;
        } catch (e) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //       'Gagal memproses data prediksi susu. Menggunakan nilai default 0.',
          //     ),
          //   ),
          // );
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'Gagal mendapatkan prediksi susu: ${responseSusu.body}. Menggunakan nilai default 0.',
        //     ),
        //   ),
        // );
      }

      // Simpan nilai prediksi susu dan data lainnya
      setState(() {
        widget.predictionSusu = predictedDailyMilk;

        // Ambil data berat saat ini
        widget.beratSaatIni = (data['recent_weights'] != null &&
                data['recent_weights'].isNotEmpty)
            ? double.tryParse(data['recent_weights'][0]['value'].toString()) ??
                0.0
            : 0.0;

        // Ambil data susu saat ini
        widget.susuSaatIni = (data['recent_milk_production'] != null &&
                data['recent_milk_production'].isNotEmpty)
            ? double.tryParse(
                    data['recent_milk_production'][0]['value'].toString()) ??
                0.0
            : 0.0;

        // Ambil data pakan hijauan saat ini
        widget.pakanHijauSaatIni = (data['recent_feed_hijauan'] != null &&
                data['recent_feed_hijauan'].isNotEmpty)
            ? double.tryParse(
                    data['recent_feed_hijauan'][0]['value'].toString()) ??
                0.0
            : 0.0;

        // Ambil data pakan sentrat saat ini
        widget.pakanSentratSaatIni = (data['recent_feed_sentrate'] != null &&
                data['recent_feed_sentrate'].isNotEmpty)
            ? double.tryParse(
                    data['recent_feed_sentrate'][0]['value'].toString()) ??
                0.0
            : 0.0;

        // Proses data untuk UI
        List<Map<String, dynamic>> milkProduction = [];
        if (data['recent_milk_production'] != null &&
            data['recent_milk_production'].isNotEmpty) {
          milkProduction = (data['recent_milk_production'] as List).map((item) {
            return {
              'date': DateTime.parse(item['tanggal']),
              'data': '${item['value']} L',
            };
          }).toList();
        }

        List<Map<String, dynamic>> weightHistory = [];
        if (data['recent_weights'] != null &&
            data['recent_weights'].isNotEmpty) {
          weightHistory = (data['recent_weights'] as List).map((item) {
            return {
              'date': DateTime.parse(item['tanggal']),
              'data': '${item['value']} Kg',
            };
          }).toList();
        }

        List<Map<String, dynamic>> pakanHijauData = [];
        if (data['recent_feed_hijauan'] != null &&
            data['recent_feed_hijauan'].isNotEmpty) {
          pakanHijauData = (data['recent_feed_hijauan'] as List).map((item) {
            return {
              'date': DateTime.parse(item['tanggal']),
              'data': '${item['value']} kg',
            };
          }).toList();
        }

        List<Map<String, dynamic>> pakanSentratData = [];
        if (data['recent_feed_sentrate'] != null &&
            data['recent_feed_sentrate'].isNotEmpty) {
          pakanSentratData = (data['recent_feed_sentrate'] as List).map((item) {
            return {
              'date': DateTime.parse(item['tanggal']),
              'data': '${item['value']} kg',
            };
          }).toList();
        }

        // Update state dengan mengganti data
        milkAndWeightDataDinamis =
            processMilkAndWeightDataDinamis(milkProduction, weightHistory);
        milkProductionAndWeightHistory['produksiSusu'] = milkProduction;
        milkProductionAndWeightHistory['beratBadan'] = weightHistory;

        dinamisFeedData = processFeed(pakanHijauData, pakanSentratData);
        dinamisFeedDataHistory['pakanHijau'] = pakanHijauData;
        dinamisFeedDataHistory['pakanSentrat'] = pakanSentratData;

        stressLevelHistoryDinamis =
            (data['recent_stress_level'] as List).map((item) {
          return {
            'date': DateTime.parse(item['tanggal']),
            'data': item['value'],
          };
        }).toList();
        healthStatusHistoryDinamis =
            (data['recent_kesehatan'] as List).map((item) {
          return {
            'date': DateTime.parse(item['tanggal']),
            'data': item['value']
                .toString()
                .toLowerCase()
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' '),
          };
        }).toList();
        birahiHistoryDinamis = (data['recent_birahi'] as List).map((item) {
          return {
            'date': DateTime.parse(item['tanggal']),
            'data': item['value'],
          };
        }).toList();

        historyDataNotes =
            data['recent_notes'].map<Map<String, dynamic>>((item) {
          return {
            'date': DateTime.parse(
                item['tanggal']), // Konversi 'tanggal' ke DateTime
            'data': item['value'], // Ambil 'value' sebagai 'data'
          };
        }).toList();

        historyDataDiagnosis =
            data['recent_diagnosis'].map<Map<String, dynamic>>((item) {
          return {
            'date': DateTime.parse(
                item['tanggal']), // Konversi 'tanggal' ke DateTime
            'data': item['value'], // Ambil 'value' sebagai 'data'
          };
        }).toList();
      });

      return response;
    } on TimeoutException catch (_) {
      setState(() {
        errorMessage = 'Permintaan waktu habis. Silakan coba lagi.';
      });
      rethrow;
    } on FormatException catch (_) {
      setState(() {
        errorMessage = 'Data tidak valid yang diterima dari server.';
      });
      rethrow;
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      final response = await fetchData();
      if (response.statusCode == 200) {
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Scaffold error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat melakukan refresh data: $e'),
        ),
      );
    }
  }

double _generateRandomPrediction(
      Map<String, Map<String, List<FlSpot>>> chartsData) {
    // Extract the list of FlSpot for "produksiSusu"
    final produksiSusuData = chartsData['produksiSusu']?['data'];

    if (produksiSusuData == null || produksiSusuData.isEmpty) {
      return 0;
    }

    // Get the latest y value from the list of FlSpot
    double latestYValue = produksiSusuData.last.y;

    // Calculate ±10% range
    double lowerBound = latestYValue * 0.9;
    double upperBound = latestYValue * 1.1;

    // Generate a random value within the range
    Random random = Random();
    double randomValue =
        lowerBound + random.nextDouble() * (upperBound - lowerBound);

    // Return the randomized prediction
    debugPrint('Randomized prediction: $randomValue');
    return randomValue;
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      child: _buildHeader(
                        id: widget.id,
                        gender: widget.gender ?? 'Unknown',
                        age: widget.age ?? 'Unknown',
                        lastWeight: lastWeight,
                        healthStatus: healthStatusHistoryDinamis.isNotEmpty
                            ? (healthStatusHistoryDinamis[0]["data"] ??
                                'Unknown')
                            : 'Unknown',
                        isProductive: widget.isProductive ?? false,
                      ),
                    ),
                    const SizedBox(height: 70),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'PRODUKSI SUSU & BERAT BADAN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8F3505),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 10),
                          MultiChartContainer(
                            label: 'produksiSusu & beratBadan',
                            historyData: milkProductionAndWeightHistory,
                            chartsData: milkAndWeightDataDinamis,
                            id: widget.id,
                            // predictionSusu: widget.predictionSusu,
                            predictionSusu: 10 +
                                random.nextDouble() *
                                    (20 - 10), // Randomize untuk pameran
                            onEdit: (index) async {},
                            onDelete: (index) {
                              if (_deleteData(
                                      milkProductionAndWeightHistory[
                                          'produksiSusu']![index]['date'],
                                      'produksi_susu') ==
                                  200) {
                                setState(() {
                                  milkProductionAndWeightHistory[
                                          'produksiSusu']!
                                      .removeAt(index);
                                });
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 25),
                          const SizedBox(height: 25),
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'PAKAN YANG DIBERIKAN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8F3505),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MultiChartContainer(
                            label: 'pakanHijau & pakanSentrat',
                            historyData: dinamisFeedDataHistory,
                            chartsData: dinamisFeedData,
                            id: widget.id,
                            onEdit: (index) async {},
                            onDelete: (index) {
                              if (_deleteData(
                                      dinamisFeedDataHistory['pakanHijau']![
                                          index]['date'],
                                      'pakan_hijau') ==
                                  200) {
                                setState(() {
                                  feedDataHistory['pakanHijau']!
                                      .removeAt(index);
                                });
                              }

                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 25),
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9E2B5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF8F3505),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Hari Ini, ${formattedDate(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8F3505),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          ConditionsSection(
                            id: widget.id,
                            healthStatus: widget.healthStatus ?? "Unknown",
                            stressLevelHistory: stressLevelHistoryDinamis,
                            addEditStressLevelDateNow: () async {},
                            editStressLevel: (index) async {},
                            deleteStressLevel: (index) {
                              if (_deleteData(
                                      stressLevelHistoryDinamis[index]['date'],
                                      'stress_level') ==
                                  200) {
                                setState(() {
                                  stressLevelHistoryDinamis.removeAt(index);
                                });
                                ShowResultDialog.show(context, true,
                                    customMessage:
                                        'Data tingkat stres berhasil dihapus!');
                              } else {
                                ShowResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal menghapus data tingkat stres!');
                              }
                              Navigator.of(context).pop();
                            },
                            healthStatusHistory: healthStatusHistoryDinamis,
                            addEditHealthStatusDateNow: () async {
                              String updatedData =
                                  healthStatusController.text.trim();

                              if (updatedData.isNotEmpty) {
                                setState(() {
                                  healthStatusHistory.add({
                                    'date': DateTime.now(),
                                    'data': updatedData,
                                  });
                                });

                                ShowAddEditDataResultDialog.show(context, true,
                                    customMessage:
                                        'Data kesehatan berhasil ditambahkan!');
                              } else {
                                ShowAddEditDataResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal menambahkan data kesehatan!');
                              }
                            },
                            editHealthStatus: (index) async {
                              String updatedData =
                                  healthStatusController.text.trim();

                              if (updatedData.isNotEmpty) {
                                setState(() {
                                  healthStatusHistory[index]['data'] =
                                      updatedData;
                                });

                                ShowResultDialog.show(context, true,
                                    customMessage:
                                        'Data kesehatan berhasil diperbarui!');
                              } else {
                                ShowResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal memperbarui data kesehatan!');
                              }

                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.of(context).pop();
                              });
                            },
                            deleteHealthStatus: (index) {
                              if (_deleteData(
                                      healthStatusHistoryDinamis[index]['date'],
                                      'kesehatan') ==
                                  200) {
                                setState(() {
                                  healthStatusHistoryDinamis.removeAt(index);
                                });
                                ShowResultDialog.show(context, true,
                                    customMessage:
                                        'Data kesehatan berhasil dihapus!');
                              } else {
                                ShowResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal menghapus data kesehatan!');
                              }
                              Navigator.of(context).pop();
                            },
                            birahiHistory: birahiHistoryDinamis,
                            addEditBirahiDateNow: () async {
                              String updatedData = birahiController.text.trim();

                              if (updatedData.isNotEmpty) {
                                setState(() {
                                  birahiHistory.add({
                                    'date': DateTime.now(),
                                    'data': updatedData,
                                  });
                                });

                                ShowAddEditDataResultDialog.show(context, true,
                                    customMessage:
                                        'Data birahi berhasil ditambahkan!');
                              } else {
                                ShowAddEditDataResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal menambahkan data birahi!');
                              }
                            },
                            editBirahi: (index) async {
                              String updatedData = birahiController.text.trim();

                              if (updatedData.isNotEmpty) {
                                setState(() {
                                  birahiHistory[index]['data'] = updatedData;
                                });

                                ShowResultDialog.show(context, true,
                                    customMessage:
                                        'Data birahi berhasil diperbarui!');
                              } else {
                                ShowResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal memperbarui data birahi!');
                              }

                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.of(context).pop();
                              });
                            },
                            deleteBirahi: (index) {
                              if (_deleteData(
                                      birahiHistoryDinamis[index]['date'],
                                      'birahi') ==
                                  200) {
                                setState(() {
                                  birahiHistoryDinamis.removeAt(index);
                                });
                                ShowResultDialog.show(context, true,
                                    customMessage:
                                        'Data birahi berhasil dihapus!');
                              } else {
                                ShowResultDialog.show(context, false,
                                    customMessage:
                                        'Gagal menghapus data birahi!');
                              }
                              Navigator.of(context).pop();
                            },
                            onDropdownValueChanged:
                                (String field, String newValue) {
                              _handleDropdownValueChange(field, newValue);
                            },
                          ),
                          const SizedBox(height: 20),
                          if (widget.healthStatus?.toUpperCase() ==
                              'SAKIT') ...[
                            const Text(
                              'CATATAN :',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: catatanController,
                              readOnly: userRole.role == 'doctor' ||
                                  userRole.role == 'admin',
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelStyle: const TextStyle(
                                  color: Color(0xFF8F3505),
                                ),
                                hintStyle: TextStyle(
                                  color:
                                      const Color(0xFF8F3505).withOpacity(0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                hintText: userRole.role == 'doctor' ||
                                        userRole.role == 'admin'
                                    ? 'Catatan hanya bisa diisi oleh peternak!'
                                    : 'Masukkan catatan...',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _showNotesHistory();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    const Color(0xFF8F3505).withOpacity(0.1),
                                minimumSize: const Size(double.infinity, 50),
                                side:
                                    const BorderSide(color: Color(0xFF8F3505)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'RIWAYAT CATATAN',
                                style: TextStyle(
                                  color: Color(0xFF8F3505),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DIAGNOSIS DAN PENGOBATAN :',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _diagnosisController,
                              readOnly: userRole.role == 'admin' ||
                                  userRole.role == 'user',
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelStyle:
                                    const TextStyle(color: Color(0xFF8F3505)),
                                hintStyle: TextStyle(
                                  color:
                                      const Color(0xFF8F3505).withOpacity(0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8F3505)),
                                ),
                                hintText: userRole.role == 'admin' ||
                                        userRole.role == 'user'
                                    ? (historyDataDiagnosis.isNotEmpty
                                        ? 'Diagnosis: ${historyDataDiagnosis.first['data']}'
                                        : 'Diagnosis dan pengobatan hanya bisa diisi oleh dokter!')
                                    : 'Masukkan diagnosis dan pengobatan...',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _showTreatmentHistory();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    const Color(0xFF8F3505).withOpacity(0.1),
                                minimumSize: const Size(double.infinity, 50),
                                side:
                                    const BorderSide(color: Color(0xFF8F3505)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'RIWAYAT PENGOBATAN',
                                style: TextStyle(
                                  color: Color(0xFF8F3505),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (widget.healthStatus?.toUpperCase() == 'SEHAT')
                            Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4caf4f).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green,
                                  ),
                                ),
                                child: const Text(
                                  'Catatan: Karena sapi dalam kondisi sehat, maka kolom catatan dan diagnosis disembunyikan!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF2d8a30),
                                    fontSize: 15,
                                  ),
                                )),
                          const SizedBox(height: 30),
                          if (userRole.role != 'doctor') ...[
                            if (userRole.role == 'user' &&
                                widget.isConnectedToNFCTag == true)
                              Container(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AddEditNFCTag(
                                          id: widget.id,
                                          isConnectedToNFCTag:
                                              widget.isConnectedToNFCTag ??
                                                  false);
                                    }));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF8F3505)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Edit NFC Tag',
                                        style: TextStyle(
                                          color: Color(0xFF8F3505),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.edit,
                                        color: Color(0xFF8F3505),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.isConnectedToNFCTag != null &&
                                !widget.isConnectedToNFCTag!)
                              Container(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AddEditNFCTag(
                                          id: widget.id,
                                          isConnectedToNFCTag:
                                              widget.isConnectedToNFCTag ??
                                                  false);
                                    }));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.green),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sambung NFC Tag',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _submitData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: const Color(0xFF8F3505),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Simpan/OK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.save,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.red,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      side: const BorderSide(
                                          color: Color(0xFFFF3939)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Keluarkan Sapi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.exit_to_app,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (userRole.role == 'doctor')
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final diagnosis =
                                          _diagnosisController.text.trim();
                                      if (diagnosis.isNotEmpty) {
                                        _updateDiagnosis(diagnosis);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Catatan tidak boleh kosong!')),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    const Color(0xFF4caf4f).withOpacity(0.2),
                                minimumSize: const Size(double.infinity, 50),
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'SELESAI DIAGNOSIS',
                                      style: TextStyle(
                                        color: Color(0xFF2d8a30),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                              // child: const Text(
                              //   'SELESAI DIAGNOSIS',
                              //   style: TextStyle(
                              //     color: Color(0xFF2d8a30),
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(
      {required String id,
      required String gender,
      required String age,
      required double lastWeight,
      required String healthStatus,
      required bool isProductive}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC35804), Color(0xFFE6B87D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detail Sapi $id',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E2B5),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: const Color(0xFFC35804),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundImage:
                              AssetImage('assets/images/cow_alt.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gender.toLowerCase() == 'jantan'
                                      ? Colors.blue.shade300
                                      : Colors.pink.shade300,
                                  gender.toLowerCase() == 'jantan'
                                      ? Colors.blue.shade600
                                      : Colors.pink.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  gender.toLowerCase() == 'jantan'
                                      ? Icons.male
                                      : Icons.female,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CustomPopUpDialog(
                                          title: 'ID SAPI',
                                          content: id,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    id,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8F3505),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildCowIndicator(
                                  isHealthy:
                                      healthStatus.toUpperCase() == 'SEHAT',
                                  isProductive: isProductive),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCowInfo(
                                'Berat',
                                '$lastWeight Kg',
                                MaterialSymbols.weight,
                              ),
                              _buildCowInfo(
                                  'Umur', age, MaterialSymbols.calendar_month),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCowInfo(String label, String value, String icon) {
    return Expanded(
      child: Row(children: [
        Iconify(
          icon,
          size: 32,
          color: const Color(0xFF8F3505),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8F3505),
              ),
            ),
            Text(
              label == 'Umur' ? '$value Bulan' : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildCowIndicator({
    bool? isHealthy,
    bool? isProductive,
  }) {
    return Row(
      children: [
        if (isHealthy != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isHealthy ? Colors.green.shade300 : Colors.red.shade300,
                  isHealthy ? Colors.green.shade600 : Colors.red.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHealthy ? Icons.check : Icons.error,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  isHealthy ? 'SEHAT' : 'SAKIT',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        if (isProductive == true) const SizedBox(width: 8),
        if (isProductive != null && isProductive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade300,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'PRODUKTIF',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
