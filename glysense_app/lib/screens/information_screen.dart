import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informasi Diabetes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            InformationCard(
              icon: Icons.monitor_heart_rounded,
              title: 'Apa Itu Prediabetes?',
              text:
                  'Prediabetes adalah kondisi ketika kadar gula darah '
                  'lebih tinggi dari normal, tetapi belum termasuk '
                  'diabetes. Kondisi ini dapat menjadi tanda awal '
                  'meningkatnya risiko diabetes tipe 2.',
            ),

            SizedBox(height: 16),

            InformationCard(
              icon: Icons.health_and_safety_rounded,
              title: 'Apa Itu Diabetes Tipe 2?',
              text:
                  'Diabetes melitus tipe 2 terjadi ketika tubuh tidak '
                  'menggunakan insulin dengan baik sehingga kadar gula '
                  'darah dapat meningkat. Kondisi ini dapat berhubungan '
                  'dengan berbagai faktor kesehatan dan gaya hidup.',
            ),

            SizedBox(height: 16),

            InformationCard(
              icon: Icons.search_rounded,
              title: 'Mengapa Skrining Awal Penting?',
              text:
                  'Skrining awal membantu mengenali pola risiko lebih '
                  'dini berdasarkan informasi kesehatan dan gaya hidup. '
                  'Namun hasil skrining tidak dapat digunakan sebagai '
                  'diagnosis medis.',
            ),

            SizedBox(height: 16),

            InformationCard(
              icon: Icons.restaurant_rounded,
              title: 'Gaya Hidup Sehat',
              text:
                  'Menjaga pola makan, melakukan aktivitas fisik secara '
                  'teratur, menjaga berat badan, dan melakukan pemeriksaan '
                  'kesehatan dapat membantu menjaga kondisi kesehatan.',
            ),

            SizedBox(height: 16),

            InformationCard(
              icon: Icons.local_hospital_rounded,
              title: 'Kapan Perlu Pemeriksaan Lebih Lanjut?',
              text:
                  'Jika hasil skrining menunjukkan risiko Prediabetes '
                  'atau Diabetes, pengguna disarankan melakukan pemeriksaan '
                  'lebih lanjut di fasilitas kesehatan. Diagnosis tetap '
                  'harus dilakukan oleh tenaga kesehatan.',
            ),

            SizedBox(height: 24),

            DisclaimerCard(),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InformationCard({
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

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Informasi pada aplikasi ini hanya digunakan '
              'sebagai edukasi dan skrining awal. GlySense '
              'tidak melakukan diagnosis medis dan tidak '
              'menggantikan pemeriksaan oleh tenaga kesehatan.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}