import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const List<String> _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Contoh: 16 Nov 2026, 20:41
String formatTanggalJam(String iso) {
  try {
    final DateTime d = DateTime.parse(iso);
    final String jam = d.hour.toString().padLeft(2, '0');
    final String menit = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_namaBulan[d.month - 1]} ${d.year}, $jam:$menit';
  } catch (_) {
    return 'Tanggal tidak tersedia';
  }
}

// ---------------------------------------------------------------------------
// Kartu dasar
// ---------------------------------------------------------------------------
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget isi = Padding(padding: padding, child: child);

    return Material(
      color: color ?? AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor ?? AppColors.border),
      ),
      child: onTap == null ? isi : InkWell(onTap: onTap, child: isi),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const GradientHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.5,
                    height: 1.4,
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

class DisclaimerBanner extends StatelessWidget {
  final String text;

  const DisclaimerBanner({
    super.key,
    this.text =
        'GlySense digunakan untuk skrining awal. Hasil aplikasi bukan '
            'diagnosis medis dan tidak menggantikan pemeriksaan oleh '
            'tenaga kesehatan.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tingkat risiko dari hasil prediksi
// ---------------------------------------------------------------------------
class RiskInfo {
  final int level; // 0 = Tidak Diabetes, 1 = Prediabetes, 2 = Diabetes
  final String title;
  final String subtitle;
  final Color color;
  final Color colorDark;
  final IconData icon;
  final double gauge; // posisi penanda pada meter 0..1
  final List<String> steps;

  const RiskInfo({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colorDark,
    required this.icon,
    required this.gauge,
    required this.steps,
  });

  static int levelOf(Map<String, dynamic> result) {
    final dynamic kelas = result['predicted_class'];

    if (kelas is num) {
      final int v = kelas.toInt();
      if (v >= 0 && v <= 2) {
        return v;
      }
    }

    final String prediksi = result['prediction']?.toString() ?? '';

    if (prediksi == 'Diabetes') {
      return 2;
    }

    if (prediksi == 'Prediabetes') {
      return 1;
    }

    return 0;
  }

  static RiskInfo of(Map<String, dynamic> result) {
    return fromLevel(levelOf(result));
  }

  static RiskInfo fromLevel(int level) {
    switch (level) {
      case 2:
        return const RiskInfo(
          level: 2,
          title: 'Risiko Tinggi',
          subtitle:
              'Model mendeteksi pola yang mirip diabetes. Pemeriksaan oleh '
              'tenaga kesehatan sangat disarankan.',
          color: AppColors.riskHigh,
          colorDark: Color(0xFFB91C1C),
          icon: Icons.local_hospital_rounded,
          gauge: 0.83,
          steps: [
            'Segera periksakan gula darah ke dokter atau fasilitas kesehatan.',
            'Jangan menunda pemeriksaan meskipun belum ada gejala.',
            'Bawa hasil skrining ini sebagai catatan awal saat konsultasi.',
          ],
        );
      case 1:
        return const RiskInfo(
          level: 1,
          title: 'Perlu Waspada',
          subtitle:
              'Model mendeteksi pola yang mirip prediabetes. Ini peringatan '
              'dini, bukan diagnosis.',
          color: AppColors.riskMedium,
          colorDark: Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
          gauge: 0.5,
          steps: [
            'Periksakan gula darah (puasa atau HbA1c) di fasilitas kesehatan.',
            'Atur pola makan dan tingkatkan aktivitas fisik secara rutin.',
            'Jaga berat badan, kurangi gula dan makanan olahan.',
          ],
        );
      default:
        return const RiskInfo(
          level: 0,
          title: 'Risiko Rendah',
          subtitle:
              'Berdasarkan data yang Anda isi, model tidak mendeteksi tanda '
              'prediabetes atau diabetes.',
          color: AppColors.riskLow,
          colorDark: Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
          gauge: 0.17,
          steps: [
            'Pertahankan pola makan seimbang dan aktivitas fisik rutin.',
            'Periksa kesehatan secara berkala, terutama jika ada faktor risiko.',
            'Ulangi skrining jika kondisi kesehatan atau gaya hidup berubah.',
          ],
        );
    }
  }
}

/// Meter tiga warna dengan penanda posisi.
class RiskMeter extends StatelessWidget {
  final double position;
  final Color markerColor;

  const RiskMeter({
    super.key,
    required this.position,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double marker = 22;
        final double lebar = constraints.maxWidth;
        final double kiri = (lebar * position.clamp(0.0, 1.0).toDouble()) -
            (marker / 2);

        return SizedBox(
          height: marker + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: (marker + 4 - 12) / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 12, color: AppColors.riskLow),
                      ),
                      Expanded(
                        child: Container(
                          height: 12,
                          color: AppColors.riskMedium,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 12,
                          color: AppColors.riskHigh,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: kiri,
                top: 2,
                child: Container(
                  width: marker,
                  height: marker,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: markerColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
