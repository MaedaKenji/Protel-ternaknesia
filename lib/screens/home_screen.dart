import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/summary_cards.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ternaknesia/components/custom_line_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<FlSpot> getDataPointsForGreenFodder() {
    // Data dummy untuk "Berat Pangan Hijauan"
    return [
      FlSpot(0, 10),
      FlSpot(1, 20),
      FlSpot(2, 70),
      FlSpot(3, 65),
      FlSpot(4, 30),
    ];
  }

  List<FlSpot> getDataPointsForConcentratedFodder() {
    // Data dummy untuk "Berat Pangan Sentrat"
    return [
      FlSpot(0, 15),
      FlSpot(1, 25),
      FlSpot(2, 60),
      FlSpot(3, 55),
      FlSpot(4, 35),
    ];
  }

  @override
  Widget build(BuildContext context) {
    String displayName = 'Atha Rafifi Azmi';
    displayName = displayName.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE6B87D), Color(0xFFF9E2B5)],
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
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/LogoTernaknesia.png',
                              width: 50,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SAPYY',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF8F3505),
                                  )),
                              Text('Selamat Bekerja!',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8F3505),
                                  )),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD38C31),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF9E2B5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Image(
                                  image: AssetImage(
                                      'assets/images/profileHome.png'),
                                  width: 65),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hai, $displayName',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      )),
                                  const Text(
                                    'Peternak',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  const Text(
                                    'Sabtu, 26 Oktober 2024',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SummaryCards(),
                    const SizedBox(height: 16),
                    CustomLineChart(
                      title: 'Berat Pangan Hijauan',
                      dataPoints: getDataPointsForGreenFodder(),
                    ),
                    CustomLineChart(
                      title: 'Berat Pangan Sentrat',
                      dataPoints: getDataPointsForConcentratedFodder(),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
