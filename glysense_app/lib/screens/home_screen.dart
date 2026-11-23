import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'history_screen.dart';
import 'information_screen.dart';
import 'screening_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TopBar(
              onInfoTap: () => _openPage(context, const AboutScreen()),
            ),
            const SizedBox(height: 20),
            _HeroCard(
              onStart: () => _openPage(context, const ScreeningScreen()),
            ),
            const SizedBox(height: 28),
            const _SectionTitle('Cara Kerja'),
            const SizedBox(height: 12),
            const _StepsRow(),
            const SizedBox(height: 28),
            const _SectionTitle('Menu Lainnya'),
            const SizedBox(height: 12),
            HomeMenuCard(
              icon: Icons.history_rounded,
              color: AppColors.primary,
              title: 'Riwayat Skrining',
              description: 'Lihat kembali hasil skrining yang pernah dilakukan.',
              onTap: () => _openPage(context, const HistoryScreen()),
            ),
            HomeMenuCard(
              icon: Icons.menu_book_rounded,
              color: AppColors.accent,
              title: 'Informasi Diabetes',
              description:
                  'Pelajari informasi sederhana tentang prediabetes dan diabetes tipe 2.',
              onTap: () => _openPage(context, const InformationScreen()),
            ),
            HomeMenuCard(
              icon: Icons.info_outline_rounded,
              color: AppColors.purple,
              title: 'Tentang GlySense',
              description:
                  'Ketahui tujuan, teknologi, dan penggunaan aplikasi GlySense.',
              onTap: () => _openPage(context, const AboutScreen()),
            ),
            const SizedBox(height: 8),
            const _TipCard(),
            const SizedBox(height: 16),
            const _DisclaimerCard(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header atas: logo + nama aplikasi
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final VoidCallback onInfoTap;

  const _TopBar({required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GlySense',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Skrining risiko diabetes',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onInfoTap,
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Tentang GlySense',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu utama (hero) dengan tombol Mulai Skrining
// ---------------------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  final VoidCallback onStart;

  const _HeroCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ornamen lingkaran dekoratif
          Positioned(
            right: -40,
            top: -40,
            child: _circle(160, 0.08),
          ),
          Positioned(
            right: 30,
            bottom: -50,
            child: _circle(110, 0.06),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Icon(
              Icons.monitor_heart_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),

          // Konten
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Prediabetes & DM Tipe 2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Kenali Risiko\nLebih Awal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Skrining awal risiko prediabetes dan diabetes melitus '
                  'tipe 2 berdasarkan informasi kesehatan dan pola gaya hidup.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.health_and_safety_rounded),
                    label: const Text('Mulai Skrining'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Judul section
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3 langkah cara kerja
// ---------------------------------------------------------------------------
class _StepsRow extends StatelessWidget {
  const _StepsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StepItem(
            number: 1,
            icon: Icons.edit_note_rounded,
            label: 'Isi data kesehatan',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StepItem(
            number: 2,
            icon: Icons.analytics_rounded,
            label: 'Analisis risiko',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StepItem(
            number: 3,
            icon: Icons.fact_check_rounded,
            label: 'Lihat hasil',
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;

  const _StepItem({
    required this.number,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu menu (dipakai ulang)
// ---------------------------------------------------------------------------
class HomeMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color color;

  const HomeMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu tips edukasi
// ---------------------------------------------------------------------------
class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahukah Anda?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Prediabetes sering tidak menimbulkan gejala. Aktivitas fisik '
                  'rutin dan pola makan seimbang dapat membantu menurunkan risiko '
                  'berkembang menjadi diabetes tipe 2.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
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

// ---------------------------------------------------------------------------
// Disclaimer medis
// ---------------------------------------------------------------------------
class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'GlySense digunakan untuk skrining awal. Hasil aplikasi bukan '
              'diagnosis medis dan tidak menggantikan pemeriksaan oleh '
              'tenaga kesehatan.',
              style: TextStyle(
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