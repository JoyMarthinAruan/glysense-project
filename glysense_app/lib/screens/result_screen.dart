import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// Layar hasil setelah skrining. Menyimpan hasil ke riwayat satu kali.
class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();

    _saveResultToHistory();
  }

  Future<void> _saveResultToHistory() async {
    if (_historySaved) {
      return;
    }

    _historySaved = true;

    try {
      await HistoryService.saveHistory(widget.result);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Riwayat gagal disimpan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Skrining')),
      body: SafeArea(
        child: ResultView(
          result: widget.result,
          catatanRiwayat: true,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi hasil skrining. Dipakai juga oleh layar detail riwayat.
class ResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final String? tanggal;
  final bool catatanRiwayat;
  final List<Widget> actions;

  const ResultView({
    super.key,
    required this.result,
    this.tanggal,
    this.catatanRiwayat = false,
    this.actions = const [],
  });

  double _angka(dynamic nilai) {
    if (nilai is num) {
      return nilai.toDouble();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final RiskInfo risiko = RiskInfo.of(result);

    final String prediction =
        result['prediction']?.toString() ?? 'Tidak diketahui';

    final String message = result['message']?.toString() ??
        'Hasil ini merupakan skrining awal.';

    final dynamic mentah = result['probability'];
    final Map<String, dynamic> probability = mentah is Map
        ? Map<String, dynamic>.from(mentah)
        : <String, dynamic>{};

    final double tidakDiabetes = _angka(probability['tidak_diabetes']);
    final double prediabetes = _angka(probability['prediabetes']);
    final double diabetes = _angka(probability['diabetes']);
    final double threshold = _angka(result['prediabetes_threshold']);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _hero(risiko, prediction),
        if (tanggal != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Dilakukan pada $tanggal',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tingkat risiko',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              RiskMeter(position: risiko.gauge, markerColor: risiko.color),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rendah',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Sedang',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Tinggi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yang perlu Anda lakukan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < risiko.steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == risiko.steps.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: risiko.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: risiko.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          risiko.steps[i],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (risiko.level == 1) ...[
          const SizedBox(height: 16),
          const InfoBanner(
            icon: Icons.tune_rounded,
            color: AppColors.primary,
            text: 'Peringatan Prediabetes sengaja dibuat sensitif agar lebih '
                'banyak kasus awal terdeteksi. Akibatnya, sebagian orang yang '
                'diberi peringatan ternyata tidak mengalami prediabetes. '
                'Gunakan hasil ini sebagai pengingat untuk memeriksakan diri, '
                'bukan sebagai diagnosis.',
          ),
        ],
        const SizedBox(height: 16),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 18),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              shape: const Border(),
              collapsedShape: const Border(),
              leading: const Icon(
                Icons.analytics_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Detail teknis',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              children: [
                const Text(
                  'Skor di bawah adalah keluaran model, bukan peluang sebenarnya. '
                  'Model dilatih dengan pembobotan kelas, sehingga skor Prediabetes '
                  'cenderung lebih tinggi dari kejadian nyata.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _barisSkor('Tidak Diabetes', tidakDiabetes, AppColors.riskLow),
                const SizedBox(height: 12),
                _barisSkor('Prediabetes', prediabetes, AppColors.riskMedium),
                const SizedBox(height: 12),
                _barisSkor('Diabetes', diabetes, AppColors.riskHigh),
                const SizedBox(height: 14),
                Text(
                  'Ambang Prediabetes: ${threshold.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (catatanRiwayat) ...[
          const SizedBox(height: 16),
          const InfoBanner(
            icon: Icons.save_rounded,
            color: AppColors.riskLow,
            text: 'Hasil skrining ini telah disimpan ke Riwayat Skrining.',
          ),
        ],
        const SizedBox(height: 16),
        const DisclaimerBanner(
          text: 'Hasil ini merupakan skrining awal dan bukan diagnosis medis. '
              'Pemeriksaan dan diagnosis tetap dilakukan oleh tenaga kesehatan.',
        ),
        for (final Widget aksi in actions) ...[
          const SizedBox(height: 14),
          aksi,
        ],
      ],
    );
  }

  Widget _hero(RiskInfo risiko, String prediction) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [risiko.color, risiko.colorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: risiko.color.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(risiko.icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hasil skrining',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prediction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    risiko.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  risiko.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barisSkor(String label, double nilai, Color warna) {
    final double persen = nilai * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${persen.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: nilai.clamp(0.0, 1.0).toDouble(),
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: AppColors.border,
          color: warna,
        ),
      ],
    );
  }
}
