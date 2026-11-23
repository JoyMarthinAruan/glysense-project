import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_ui.dart';

class Opsi {
  final int nilai;
  final String teks;

  const Opsi(this.nilai, this.teks);
}

const List<Opsi> opsiYaTidak = [
  Opsi(1, 'Ya'),
  Opsi(0, 'Tidak'),
];

class _PesanError extends StatelessWidget {
  final String teks;

  const _PesanError(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 12, color: AppColors.riskHigh),
      ),
    );
  }
}

class _Pil extends StatelessWidget {
  final String teks;
  final bool terpilih;
  final VoidCallback onTap;

  const _Pil({
    required this.teks,
    required this.terpilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: terpilih ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: terpilih ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            teks,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: terpilih ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pertanyaan dengan pilihan tombol (Ya/Tidak, jenis kelamin, kondisi umum).
class ChoiceTile extends StatelessWidget {
  final String label;
  final String? hint;
  final List<Opsi> opsi;
  final int? value;
  final ValueChanged<int> onChanged;
  final bool showError;

  const ChoiceTile({
    super.key,
    required this.label,
    required this.opsi,
    required this.value,
    required this.onChanged,
    this.hint,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool error = showError && value == null;

    final List<Widget> pil = opsi
        .map(
          (o) => _Pil(
            teks: o.teks,
            terpilih: value == o.nilai,
            onTap: () => onChanged(o.nilai),
          ),
        )
        .toList();

    final List<Widget> baris = [];
    for (int i = 0; i < pil.length; i++) {
      if (i > 0) {
        baris.add(const SizedBox(width: 10));
      }
      baris.add(Expanded(child: pil[i]));
    }

    return SoftCard(
      borderColor: error ? AppColors.riskHigh : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (opsi.length <= 2)
            Row(children: baris)
          else
            Wrap(spacing: 8, runSpacing: 8, children: pil),
          if (error) const _PesanError('Silakan pilih jawaban'),
        ],
      ),
    );
  }
}

/// Pilihan dari daftar panjang lewat lembar bawah (usia, pendidikan, pendapatan).
class PickerField extends StatelessWidget {
  final String label;
  final List<Opsi> opsi;
  final int? value;
  final ValueChanged<int> onChanged;
  final bool showError;

  const PickerField({
    super.key,
    required this.label,
    required this.opsi,
    required this.value,
    required this.onChanged,
    this.showError = false,
  });

  String? get _teksTerpilih {
    for (final Opsi o in opsi) {
      if (o.nilai == value) {
        return o.teks;
      }
    }
    return null;
  }

  Future<void> _buka(BuildContext context) async {
    final int? hasil = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: opsi.map((o) {
                      final bool dipilih = o.nilai == value;

                      return ListTile(
                        title: Text(
                          o.teks,
                          style: TextStyle(
                            fontWeight:
                                dipilih ? FontWeight.w700 : FontWeight.w500,
                            color: dipilih
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: dipilih
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, o.nilai),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (hasil != null) {
      onChanged(hasil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool error = showError && value == null;
    final String? teks = _teksTerpilih;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftCard(
          borderColor: error ? AppColors.riskHigh : null,
          onTap: () => _buka(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teks ?? 'Pilih jawaban',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: teks == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (error) const _PesanError('Silakan pilih jawaban'),
      ],
    );
  }
}

/// Geser untuk memilih jumlah hari 0 sampai 30.
class DaysSliderTile extends StatelessWidget {
  final String label;
  final String hint;
  final int value;
  final ValueChanged<int> onChanged;

  const DaysSliderTile({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$value hari',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 30,
            divisions: 30,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '30',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Isian angka (desimal boleh memakai titik atau koma).
class NumberBox extends StatelessWidget {
  final String label;
  final String suffix;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const NumberBox({
    super.key,
    required this.label,
    required this.suffix,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        errorText: errorText,
      ),
    );
  }
}
