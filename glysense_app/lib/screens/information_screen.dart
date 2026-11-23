import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Diabetes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: const [
            GradientHeader(
              icon: Icons.menu_book_rounded,
              title: 'Kenali Lebih Dalam',
              subtitle:
                  'Informasi sederhana tentang prediabetes dan diabetes tipe 2.',
            ),
            SizedBox(height: 18),
            InformationCard(
              icon: Icons.monitor_heart_rounded,
              color: AppColors.primary,
              title: 'Apa Itu Prediabetes?',
              text: 'Prediabetes adalah kondisi ketika kadar gula darah '
                  'lebih tinggi dari normal, tetapi belum termasuk '
                  'diabetes. Kondisi ini dapat menjadi tanda awal '
                  'meningkatnya risiko diabetes tipe 2.',
            ),
            SizedBox(height: 14),
            InformationCard(
              icon: Icons.health_and_safety_rounded,
              color: AppColors.accent,
              title: 'Apa Itu Diabetes Tipe 2?',
              text: 'Diabetes melitus tipe 2 terjadi ketika tubuh tidak '
                  'menggunakan insulin dengan baik sehingga kadar gula '
                  'darah dapat meningkat. Kondisi ini dapat berhubungan '
                  'dengan berbagai faktor kesehatan dan gaya hidup.',
            ),
            SizedBox(height: 14),
            InformationCard(
              icon: Icons.search_rounded,
              color: AppColors.purple,
              title: 'Mengapa Skrining Awal Penting?',
              text: 'Skrining awal membantu mengenali pola risiko lebih '
                  'dini berdasarkan informasi kesehatan dan gaya hidup. '
                  'Namun hasil skrining tidak dapat digunakan sebagai '
                  'diagnosis medis.',
            ),
            SizedBox(height: 14),
            InformationCard(
              icon: Icons.restaurant_rounded,
              color: AppColors.riskLow,
              title: 'Gaya Hidup Sehat',
              text: 'Menjaga pola makan, melakukan aktivitas fisik secara '
                  'teratur, menjaga berat badan, dan melakukan pemeriksaan '
                  'kesehatan dapat membantu menjaga kondisi kesehatan.',
            ),
            SizedBox(height: 14),
            InformationCard(
              icon: Icons.local_hospital_rounded,
              color: AppColors.riskHigh,
              title: 'Kapan Perlu Pemeriksaan Lebih Lanjut?',
              text: 'Jika hasil skrining menunjukkan risiko Prediabetes '
                  'atau Diabetes, pengguna disarankan melakukan pemeriksaan '
                  'lebih lanjut di fasilitas kesehatan. Diagnosis tetap '
                  'harus dilakukan oleh tenaga kesehatan.',
            ),
            SizedBox(height: 20),
            DisclaimerBanner(
              text: 'Informasi pada aplikasi ini hanya digunakan '
                  'sebagai edukasi dan skrining awal. GlySense '
                  'tidak melakukan diagnosis medis dan tidak '
                  'menggantikan pemeriksaan oleh tenaga kesehatan.',
            ),
          ],
        ),
      ),
    );
  }
}

class InformationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const InformationCard({
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
