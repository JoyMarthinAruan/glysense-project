import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang GlySense')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const SizedBox(height: 6),
            Center(
              child: Container(
                width: 92,
                height: 92,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'lib/assets/images/glysense_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'GlySense',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kenali Risiko Lebih Awal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const AboutCard(
              icon: Icons.info_outline_rounded,
              color: AppColors.primary,
              title: 'Tentang Aplikasi',
              text: 'GlySense merupakan aplikasi skrining awal risiko '
                  'prediabetes dan diabetes melitus tipe 2 berdasarkan '
                  'informasi kesehatan dan pola gaya hidup pengguna.',
            ),
            const SizedBox(height: 14),
            const AboutCard(
              icon: Icons.psychology_rounded,
              color: AppColors.accent,
              title: 'Teknologi yang Digunakan',
              text: 'GlySense menggunakan model machine learning yang '
                  'dikembangkan dari data kesehatan terstruktur. '
                  'Model menggabungkan Random Forest dan XGBoost '
                  'menggunakan pendekatan Stacking dengan Logistic '
                  'Regression sebagai meta-learner.',
            ),
            const SizedBox(height: 14),
            const AboutCard(
              icon: Icons.balance_rounded,
              color: AppColors.purple,
              title: 'Penanganan Data Tidak Seimbang',
              text: 'Karena jumlah data Prediabetes lebih sedikit dibanding '
                  'kelas lainnya, model menggunakan pendekatan '
                  'Cost-Sensitive Learning agar kesalahan pada kelas '
                  'minoritas mendapat perhatian lebih besar.',
            ),
            const SizedBox(height: 14),
            const AboutCard(
              icon: Icons.tune_rounded,
              color: AppColors.riskMedium,
              title: 'Threshold Prediabetes',
              text: 'Model menggunakan threshold khusus untuk kelas '
                  'Prediabetes. Threshold ini digunakan untuk membantu '
                  'meningkatkan kemampuan model dalam mengenali pola '
                  'Prediabetes pada proses skrining.',
            ),
            const SizedBox(height: 14),
            const AboutCard(
              icon: Icons.medical_information_rounded,
              color: AppColors.riskHigh,
              title: 'Bukan Alat Diagnosis',
              text: 'GlySense tidak melakukan pemeriksaan kadar gula darah '
                  'dan tidak memberikan diagnosis medis. Hasil aplikasi '
                  'hanya digunakan sebagai skrining awal berdasarkan '
                  'informasi yang diberikan pengguna.',
            ),
            const SizedBox(height: 18),
            const DisclaimerBanner(
              text: 'Jika hasil skrining menunjukkan risiko Prediabetes '
                  'atau Diabetes, pengguna disarankan melakukan '
                  'pemeriksaan lebih lanjut di fasilitas kesehatan.',
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dikembangkan oleh',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Monica Sitanggang\nJoy Marthin Aruan\nRido Jeremi Siagian',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tugas Akhir D3 Teknologi Informasi, Institut Teknologi Del',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
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

class AboutCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const AboutCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
