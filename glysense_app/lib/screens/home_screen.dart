import 'package:flutter/material.dart';

import 'screening_screen.dart';
import 'history_screen.dart';
import 'information_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GlySense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.water_drop_rounded,
                size: 85,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              const Text(
                'GlySense',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Kenali Risiko Lebih Awal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Skrining awal risiko prediabetes dan diabetes '
                'melitus tipe 2 berdasarkan informasi kesehatan '
                'dan pola gaya hidup.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              HomeMenuCard(
                icon: Icons.health_and_safety_rounded,
                title: 'Mulai Skrining',
                description:
                    'Isi data kesehatan dan gaya hidup untuk melakukan skrining awal.',
                onTap: () {
                  openPage(
                    context,
                    const ScreeningScreen(),
                  );
                },
              ),

              HomeMenuCard(
                icon: Icons.history_rounded,
                title: 'Riwayat Skrining',
                description:
                    'Lihat kembali hasil skrining yang pernah dilakukan.',
                onTap: () {
                  openPage(
                    context,
                    const HistoryScreen(),
                  );
                },
              ),

              HomeMenuCard(
                icon: Icons.menu_book_rounded,
                title: 'Informasi Diabetes',
                description:
                    'Pelajari informasi sederhana tentang prediabetes dan diabetes tipe 2.',
                onTap: () {
                  openPage(
                    context,
                    const InformationScreen(),
                  );
                },
              ),

              HomeMenuCard(
                icon: Icons.info_outline_rounded,
                title: 'Tentang GlySense',
                description:
                    'Ketahui tujuan, teknologi, dan penggunaan aplikasi GlySense.',
                onTap: () {
                  openPage(
                    context,
                    const AboutScreen(),
                  );
                },
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'GlySense digunakan untuk skrining awal. '
                        'Hasil aplikasi bukan diagnosis medis dan '
                        'tidak menggantikan pemeriksaan oleh tenaga kesehatan.',
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const HomeMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}