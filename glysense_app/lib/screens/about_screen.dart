import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang GlySense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.water_drop_rounded,
              size: 95,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'GlySense',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
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

            const SizedBox(height: 28),

            const AboutCard(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              text:
                  'GlySense merupakan aplikasi skrining awal risiko '
                  'prediabetes dan diabetes melitus tipe 2 berdasarkan '
                  'informasi kesehatan dan pola gaya hidup pengguna.',
            ),

            const SizedBox(height: 16),

            const AboutCard(
              icon: Icons.psychology_rounded,
              title: 'Teknologi yang Digunakan',
              text:
                  'GlySense menggunakan model machine learning yang '
                  'dikembangkan dari data kesehatan terstruktur. '
                  'Model menggabungkan Random Forest dan XGBoost '
                  'menggunakan pendekatan Stacking dengan Logistic '
                  'Regression sebagai meta-learner.',
            ),

            const SizedBox(height: 16),

            const AboutCard(
              icon: Icons.balance_rounded,
              title: 'Penanganan Data Tidak Seimbang',
              text:
                  'Karena jumlah data Prediabetes lebih sedikit dibanding '
                  'kelas lainnya, model menggunakan pendekatan '
                  'Cost-Sensitive Learning agar kesalahan pada kelas '
                  'minoritas mendapat perhatian lebih besar.',
            ),

            const SizedBox(height: 16),

            const AboutCard(
              icon: Icons.tune_rounded,
              title: 'Threshold Prediabetes',
              text:
                  'Model menggunakan threshold khusus untuk kelas '
                  'Prediabetes. Threshold ini digunakan untuk membantu '
                  'meningkatkan kemampuan model dalam mengenali pola '
                  'Prediabetes pada proses skrining.',
            ),

            const SizedBox(height: 16),

            const AboutCard(
              icon: Icons.medical_information_rounded,
              title: 'Bukan Alat Diagnosis',
              text:
                  'GlySense tidak melakukan pemeriksaan kadar gula darah '
                  'dan tidak memberikan diagnosis medis. Hasil aplikasi '
                  'hanya digunakan sebagai skrining awal berdasarkan '
                  'informasi yang diberikan pengguna.',
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
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
                      'Jika hasil skrining menunjukkan risiko Prediabetes '
                      'atau Diabetes, pengguna disarankan melakukan '
                      'pemeriksaan lebih lanjut di fasilitas kesehatan.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const AboutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.red,
                size: 27,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
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