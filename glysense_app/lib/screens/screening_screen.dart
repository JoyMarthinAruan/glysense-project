import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/form_widgets.dart';
import 'result_screen.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  static const int _jumlahLangkah = 5;

  static const List<String> _judulLangkah = [
    'Data Diri',
    'Tubuh',
    'Riwayat Kesehatan',
    'Gaya Hidup',
    'Kondisi Umum',
  ];

  static const List<String> _deskripsiLangkah = [
    'Informasi dasar untuk membantu skrining.',
    'Tinggi dan berat badan dipakai untuk menghitung BMI.',
    'Jawab sesuai kondisi Anda saat ini atau yang pernah dialami.',
    'Kebiasaan sehari-hari yang memengaruhi risiko.',
    'Gambaran kesehatan Anda secara umum.',
  ];

  static const List<Opsi> _opsiKelamin = [
    Opsi(1, 'Laki-laki'),
    Opsi(0, 'Perempuan'),
  ];

  static const List<Opsi> _opsiUsia = [
    Opsi(1, '18–24 tahun'),
    Opsi(2, '25–29 tahun'),
    Opsi(3, '30–34 tahun'),
    Opsi(4, '35–39 tahun'),
    Opsi(5, '40–44 tahun'),
    Opsi(6, '45–49 tahun'),
    Opsi(7, '50–54 tahun'),
    Opsi(8, '55–59 tahun'),
    Opsi(9, '60–64 tahun'),
    Opsi(10, '65–69 tahun'),
    Opsi(11, '70–74 tahun'),
    Opsi(12, '75–79 tahun'),
    Opsi(13, '80 tahun atau lebih'),
  ];

  static const List<Opsi> _opsiPendidikan = [
    Opsi(1, 'Tidak pernah sekolah / TK'),
    Opsi(2, 'SD kelas 1–8'),
    Opsi(3, 'Sebagian SMA'),
    Opsi(4, 'Lulus SMA'),
    Opsi(5, 'Kuliah 1–3 tahun'),
    Opsi(6, 'Lulus perguruan tinggi'),
  ];

  static const List<Opsi> _opsiPendapatan = [
    Opsi(1, 'Kurang dari \$10.000'),
    Opsi(2, '\$10.000–\$14.999'),
    Opsi(3, '\$15.000–\$19.999'),
    Opsi(4, '\$20.000–\$24.999'),
    Opsi(5, '\$25.000–\$34.999'),
    Opsi(6, '\$35.000–\$49.999'),
    Opsi(7, '\$50.000–\$74.999'),
    Opsi(8, '\$75.000 atau lebih'),
  ];

  static const List<Opsi> _opsiKondisiUmum = [
    Opsi(1, 'Sangat baik'),
    Opsi(2, 'Baik'),
    Opsi(3, 'Cukup'),
    Opsi(4, 'Kurang'),
    Opsi(5, 'Buruk'),
  ];

  final ScrollController _scroll = ScrollController();
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();

  int _langkah = 0;
  bool _tampilkanError = false;
  bool _isLoading = false;

  int? highBP;
  int? highChol;
  int? cholCheck;
  int? smoker;
  int? stroke;
  int? heartDisease;
  int? physActivity;
  int? fruits;
  int? veggies;
  int? heavyAlcohol;
  int? anyHealthcare;
  int? noDocCost;
  int? genHealth;
  int? diffWalk;
  int? sex;
  int? age;
  int? education;
  int? income;

  int mentHealth = 0;
  int physHealth = 0;

  @override
  void dispose() {
    _scroll.dispose();
    _tinggiController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // BMI dari tinggi dan berat
  // -------------------------------------------------------------------------
  double? _angka(String teks) {
    return double.tryParse(teks.trim().replaceAll(',', '.'));
  }

  double? get _tinggi => _angka(_tinggiController.text);
  double? get _berat => _angka(_beratController.text);

  double? get _bmi {
    final double? t = _tinggi;
    final double? b = _berat;

    if (t == null || b == null || t <= 0 || b <= 0) {
      return null;
    }

    final double meter = t / 100;
    return b / (meter * meter);
  }

  String? get _errorTinggi {
    if (!_tampilkanError) {
      return null;
    }

    final double? t = _tinggi;
    if (t == null || t < 100 || t > 250) {
      return 'Masukkan tinggi 100 sampai 250 cm';
    }
    return null;
  }

  String? get _errorBerat {
    if (!_tampilkanError) {
      return null;
    }

    final double? b = _berat;
    if (b == null || b < 20 || b > 300) {
      return 'Masukkan berat 20 sampai 300 kg';
    }
    return null;
  }

  bool get _bmiValid {
    final double? t = _tinggi;
    final double? b = _berat;
    final double? bmi = _bmi;

    if (t == null || b == null || bmi == null) {
      return false;
    }

    return t >= 100 && t <= 250 && b >= 20 && b <= 300 && bmi >= 12 && bmi <= 98;
  }

  String _kategoriBmi(double bmi) {
    if (bmi < 18.5) {
      return 'Berat badan kurang';
    }
    if (bmi < 25) {
      return 'Normal';
    }
    if (bmi < 30) {
      return 'Berat badan lebih';
    }
    return 'Obesitas';
  }

  Color _warnaBmi(double bmi) {
    if (bmi >= 18.5 && bmi < 25) {
      return AppColors.riskLow;
    }
    if (bmi < 30) {
      return AppColors.riskMedium;
    }
    return AppColors.riskHigh;
  }

  // -------------------------------------------------------------------------
  // Validasi dan navigasi langkah
  // -------------------------------------------------------------------------
  bool _langkahValid(int langkah) {
    switch (langkah) {
      case 0:
        return sex != null && age != null && education != null && income != null;
      case 1:
        return _bmiValid;
      case 2:
        return highBP != null &&
            highChol != null &&
            cholCheck != null &&
            stroke != null &&
            heartDisease != null &&
            diffWalk != null;
      case 3:
        return smoker != null &&
            physActivity != null &&
            fruits != null &&
            veggies != null &&
            heavyAlcohol != null;
      default:
        return genHealth != null && anyHealthcare != null && noDocCost != null;
    }
  }

  void _keAtas() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks),
        backgroundColor: AppColors.riskHigh,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _lanjut() {
    if (!_langkahValid(_langkah)) {
      setState(() {
        _tampilkanError = true;
      });
      _pesan('Lengkapi isian yang ditandai merah.');
      _keAtas();
      return;
    }

    setState(() {
      _langkah++;
      _tampilkanError = false;
    });
    _keAtas();
  }

  void _kembali() {
    if (_langkah == 0 || _isLoading) {
      return;
    }

    setState(() {
      _langkah--;
      _tampilkanError = false;
    });
    _keAtas();
  }

  Future<void> _prosesSkrining() async {
    // Periksa seluruh langkah; lompat ke langkah pertama yang belum lengkap.
    for (int i = 0; i < _jumlahLangkah; i++) {
      if (!_langkahValid(i)) {
        setState(() {
          _langkah = i;
          _tampilkanError = true;
        });
        _pesan('Masih ada isian yang belum lengkap pada langkah ${i + 1}.');
        _keAtas();
        return;
      }
    }

    final double bmiMentah = _bmi!;
    final double bmi = double.parse(bmiMentah.toStringAsFixed(1));

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> result = await ApiService.predictDiabetes(
        highBP: highBP!,
        highChol: highChol!,
        cholCheck: cholCheck!,
        bmi: bmi,
        smoker: smoker!,
        stroke: stroke!,
        heartDiseaseOrAttack: heartDisease!,
        physActivity: physActivity!,
        fruits: fruits!,
        veggies: veggies!,
        heavyAlcohol: heavyAlcohol!,
        anyHealthcare: anyHealthcare!,
        noDocCost: noDocCost!,
        genHealth: genHealth!,
        mentHealth: mentHealth,
        physHealth: physHealth,
        diffWalk: diffWalk!,
        sex: sex!,
        age: age!,
        education: education!,
        income: income!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String teks = error.toString();
      final bool masalahJaringan = teks.contains('SocketException') ||
          teks.contains('ClientException') ||
          teks.contains('Connection') ||
          teks.contains('TimeoutException');

      _pesan(
        masalahJaringan
            ? 'Tidak dapat terhubung ke server. Pastikan backend sedang '
                'berjalan dan alamat server sudah benar.'
            : 'Terjadi kesalahan: $error',
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Isi tiap langkah
  // -------------------------------------------------------------------------
  Widget _jarak() => const SizedBox(height: 12);

  List<Widget> _isiLangkah() {
    switch (_langkah) {
      case 0:
        return [
          ChoiceTile(
            label: 'Jenis kelamin',
            opsi: _opsiKelamin,
            value: sex,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => sex = v),
          ),
          _jarak(),
          PickerField(
            label: 'Kelompok usia',
            opsi: _opsiUsia,
            value: age,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => age = v),
          ),
          _jarak(),
          PickerField(
            label: 'Tingkat pendidikan',
            opsi: _opsiPendidikan,
            value: education,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => education = v),
          ),
          _jarak(),
          PickerField(
            label: 'Pendapatan tahunan',
            opsi: _opsiPendapatan,
            value: income,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => income = v),
          ),
        ];

      case 1:
        final double? bmi = _bmi;

        return [
          NumberBox(
            label: 'Tinggi badan',
            suffix: 'cm',
            hint: 'Contoh: 165',
            controller: _tinggiController,
            errorText: _errorTinggi,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          NumberBox(
            label: 'Berat badan',
            suffix: 'kg',
            hint: 'Contoh: 60',
            controller: _beratController,
            errorText: _errorBerat,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: Row(
              children: [
                IconBadge(
                  icon: Icons.monitor_weight_rounded,
                  color: bmi == null ? AppColors.textSecondary : _warnaBmi(bmi),
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMI Anda',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        bmi == null ? '–' : bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bmi != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _warnaBmi(bmi).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _kategoriBmi(bmi),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _warnaBmi(bmi),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const InfoBanner(
            icon: Icons.info_outline_rounded,
            color: AppColors.primary,
            text: 'BMI dihitung otomatis dari tinggi dan berat badan. '
                'Gunakan titik atau koma untuk desimal.',
          ),
        ];

      case 2:
        return [
          ChoiceTile(
            label: 'Apakah memiliki tekanan darah tinggi?',
            opsi: opsiYaTidak,
            value: highBP,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => highBP = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah memiliki kolesterol tinggi?',
            opsi: opsiYaTidak,
            value: highChol,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => highChol = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Pernah melakukan pemeriksaan kolesterol?',
            hint: 'Dalam 5 tahun terakhir.',
            opsi: opsiYaTidak,
            value: cholCheck,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => cholCheck = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah pernah mengalami stroke?',
            opsi: opsiYaTidak,
            value: stroke,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => stroke = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah memiliki penyakit jantung/serangan jantung?',
            opsi: opsiYaTidak,
            value: heartDisease,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => heartDisease = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah mengalami kesulitan berjalan?',
            hint: 'Termasuk kesulitan menaiki tangga.',
            opsi: opsiYaTidak,
            value: diffWalk,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => diffWalk = v),
          ),
        ];

      case 3:
        return [
          ChoiceTile(
            label: 'Apakah pernah merokok?',
            hint: 'Setidaknya 100 batang rokok sepanjang hidup.',
            opsi: opsiYaTidak,
            value: smoker,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => smoker = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah melakukan aktivitas fisik?',
            hint: 'Di luar pekerjaan, dalam 30 hari terakhir.',
            opsi: opsiYaTidak,
            value: physActivity,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => physActivity = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah rutin mengonsumsi buah?',
            hint: 'Satu kali atau lebih per hari.',
            opsi: opsiYaTidak,
            value: fruits,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => fruits = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah rutin mengonsumsi sayur?',
            hint: 'Satu kali atau lebih per hari.',
            opsi: opsiYaTidak,
            value: veggies,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => veggies = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah mengonsumsi alkohol secara berlebihan?',
            opsi: opsiYaTidak,
            value: heavyAlcohol,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => heavyAlcohol = v),
          ),
        ];

      default:
        return [
          ChoiceTile(
            label: 'Kondisi kesehatan secara umum',
            opsi: _opsiKondisiUmum,
            value: genHealth,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => genHealth = v),
          ),
          _jarak(),
          DaysSliderTile(
            label: 'Hari kesehatan mental terganggu',
            hint: 'Dalam 30 hari terakhir (stres, depresi, atau masalah emosi).',
            value: mentHealth,
            onChanged: (v) => setState(() => mentHealth = v),
          ),
          _jarak(),
          DaysSliderTile(
            label: 'Hari kesehatan fisik terganggu',
            hint: 'Dalam 30 hari terakhir (sakit atau cedera).',
            value: physHealth,
            onChanged: (v) => setState(() => physHealth = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Apakah memiliki akses layanan kesehatan?',
            hint: 'Misalnya asuransi atau jaminan kesehatan.',
            opsi: opsiYaTidak,
            value: anyHealthcare,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => anyHealthcare = v),
          ),
          _jarak(),
          ChoiceTile(
            label: 'Pernah tidak ke dokter karena masalah biaya?',
            hint: 'Dalam 12 bulan terakhir.',
            opsi: opsiYaTidak,
            value: noDocCost,
            showError: _tampilkanError,
            onChanged: (v) => setState(() => noDocCost = v),
          ),
        ];
    }
  }

  // -------------------------------------------------------------------------
  // Tampilan
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool terakhir = _langkah == _jumlahLangkah - 1;

    return PopScope(
      canPop: _langkah == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _kembali();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Skrining GlySense')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Langkah ${_langkah + 1} dari $_jumlahLangkah',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _judulLangkah[_langkah],
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_langkah + 1) / _jumlahLangkah,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  children: [
                    Text(
                      _judulLangkah[_langkah],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _deskripsiLangkah[_langkah],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ..._isiLangkah(),
                    if (terakhir) ...[
                      const SizedBox(height: 18),
                      const DisclaimerBanner(
                        text: 'Hasil skrining bukan merupakan diagnosis medis.',
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    if (_langkah > 0) ...[
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _kembali,
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 3,
                      child: FilledButton(
                        onPressed: _isLoading
                            ? null
                            : (terakhir ? _prosesSkrining : _lanjut),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(terakhir ? 'Proses Skrining' : 'Lanjut'),
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
