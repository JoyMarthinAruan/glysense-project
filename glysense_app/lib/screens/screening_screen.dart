import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'result_screen.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() =>
      _ScreeningScreenState();
}

class _ScreeningScreenState
    extends State<ScreeningScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController bmiController =
      TextEditingController();

  final TextEditingController mentHlthController =
      TextEditingController();

  final TextEditingController physHlthController =
      TextEditingController();

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

  bool isLoading = false;

  @override
  void dispose() {
    bmiController.dispose();
    mentHlthController.dispose();
    physHlthController.dispose();

    super.dispose();
  }

  List<DropdownMenuItem<int>> yesNoItems() {
    return const [
      DropdownMenuItem(
        value: 0,
        child: Text('Tidak'),
      ),
      DropdownMenuItem(
        value: 1,
        child: Text('Ya'),
      ),
    ];
  }

  Widget buildDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        items: items,
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Silakan pilih jawaban';
          }

          return null;
        },
      ),
    );
  }

  Future<void> prosesSkrining() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> result =
          await ApiService.predictDiabetes(
        highBP: highBP!,
        highChol: highChol!,
        cholCheck: cholCheck!,
        bmi: double.parse(
          bmiController.text,
        ),
        smoker: smoker!,
        stroke: stroke!,
        heartDiseaseOrAttack:
            heartDisease!,
        physActivity: physActivity!,
        fruits: fruits!,
        veggies: veggies!,
        heavyAlcohol: heavyAlcohol!,
        anyHealthcare: anyHealthcare!,
        noDocCost: noDocCost!,
        genHealth: genHealth!,
        mentHealth: int.parse(
          mentHlthController.text,
        ),
        physHealth: int.parse(
          physHlthController.text,
        ),
        diffWalk: diffWalk!,
        sex: sex!,
        age: age!,
        education: education!,
        income: income!,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(
            result: result,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skrining GlySense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const Text(
                'Data Kesehatan dan Gaya Hidup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Isi data berikut sesuai kondisi Anda. '
                'Data digunakan untuk membantu proses skrining awal.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              buildDropdown(
                label:
                    'Apakah memiliki tekanan darah tinggi?',
                value: highBP,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    highBP = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah memiliki kolesterol tinggi?',
                value: highChol,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    highChol = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Pernah melakukan pemeriksaan kolesterol?',
                value: cholCheck,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    cholCheck = value;
                  });
                },
              ),

              TextFormField(
                controller:
                    bmiController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    InputDecoration(
                  labelText: 'BMI',
                  hintText:
                      'Contoh: 24.5',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                ),
                validator: (value) {
                  final double? bmi =
                      double.tryParse(
                    value ?? '',
                  );

                  if (bmi == null ||
                      bmi <= 0) {
                    return 'Masukkan BMI yang valid';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              buildDropdown(
                label:
                    'Apakah pernah merokok?',
                value: smoker,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    smoker = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah pernah mengalami stroke?',
                value: stroke,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    stroke = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah memiliki penyakit jantung/serangan jantung?',
                value: heartDisease,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    heartDisease =
                        value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah melakukan aktivitas fisik?',
                value: physActivity,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    physActivity =
                        value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah rutin mengonsumsi buah?',
                value: fruits,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    fruits = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah rutin mengonsumsi sayur?',
                value: veggies,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    veggies = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah mengonsumsi alkohol secara berlebihan?',
                value: heavyAlcohol,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    heavyAlcohol =
                        value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Apakah memiliki akses layanan kesehatan?',
                value: anyHealthcare,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    anyHealthcare =
                        value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Pernah tidak ke dokter karena masalah biaya?',
                value: noDocCost,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    noDocCost = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Kondisi kesehatan secara umum',
                value: genHealth,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child:
                        Text('Sangat Baik'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child:
                        Text('Baik'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child:
                        Text('Cukup'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child:
                        Text('Kurang'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child:
                        Text('Buruk'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    genHealth = value;
                  });
                },
              ),

              TextFormField(
                controller:
                    mentHlthController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    InputDecoration(
                  labelText:
                      'Hari kesehatan mental terganggu (0-30 hari)',
                  hintText:
                      'Contoh: 2',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                ),
                validator: (value) {
                  final int? number =
                      int.tryParse(
                    value ?? '',
                  );

                  if (number == null ||
                      number < 0 ||
                      number > 30) {
                    return 'Masukkan angka 0 sampai 30';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    physHlthController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    InputDecoration(
                  labelText:
                      'Hari kesehatan fisik terganggu (0-30 hari)',
                  hintText:
                      'Contoh: 3',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                ),
                validator: (value) {
                  final int? number =
                      int.tryParse(
                    value ?? '',
                  );

                  if (number == null ||
                      number < 0 ||
                      number > 30) {
                    return 'Masukkan angka 0 sampai 30';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              buildDropdown(
                label:
                    'Apakah mengalami kesulitan berjalan?',
                value: diffWalk,
                items: yesNoItems(),
                onChanged: (value) {
                  setState(() {
                    diffWalk = value;
                  });
                },
              ),

              buildDropdown(
                label:
                    'Jenis kelamin',
                value: sex,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child:
                        Text('Perempuan'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child:
                        Text('Laki-laki'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    sex = value;
                  });
                },
              ),

              buildDropdown(
                label: 'Kelompok usia',
                value: age,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('18–24 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('25–29 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('30–34 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('35–39 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text('40–44 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 6,
                    child: Text('45–49 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 7,
                    child: Text('50–54 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 8,
                    child: Text('55–59 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 9,
                    child: Text('60–64 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: Text('65–69 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 11,
                    child: Text('70–74 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 12,
                    child: Text('75–79 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 13,
                    child: Text('80 tahun atau lebih'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    age = value;
                  });
                },
              ),

              buildDropdown(
                label: 'Tingkat pendidikan',
                value: education,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Tidak pernah sekolah / TK'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('SD kelas 1–8'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Sebagian SMA'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('Lulus SMA'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text('Kuliah 1–3 tahun'),
                  ),
                  DropdownMenuItem(
                    value: 6,
                    child: Text('Lulus perguruan tinggi'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    education = value;
                  });
                },
              ),

              buildDropdown(
                label: 'Pendapatan tahunan',
                value: income,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Kurang dari \$10.000'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('\$10.000–\$14.999'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('\$15.000–\$19.999'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('\$20.000–\$24.999'),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text('\$25.000–\$34.999'),
                  ),
                  DropdownMenuItem(
                    value: 6,
                    child: Text('\$35.000–\$49.999'),
                  ),
                  DropdownMenuItem(
                    value: 7,
                    child: Text('\$50.000–\$74.999'),
                  ),
                  DropdownMenuItem(
                    value: 8,
                    child: Text('\$75.000 atau lebih'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    income = value;
                  });
                },
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : prosesSkrining,
                  style:
                      ElevatedButton
                          .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Proses Skrining',
                          style:
                              TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Hasil skrining bukan merupakan diagnosis medis.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}