import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> predictDiabetes({
    required int highBP,
    required int highChol,
    required int cholCheck,
    required double bmi,
    required int smoker,
    required int stroke,
    required int heartDiseaseOrAttack,
    required int physActivity,
    required int fruits,
    required int veggies,
    required int heavyAlcohol,
    required int anyHealthcare,
    required int noDocCost,
    required int genHealth,
    required int mentHealth,
    required int physHealth,
    required int diffWalk,
    required int sex,
    required int age,
    required int education,
    required int income,
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/predict',
    );

    final Map<String, dynamic> requestData = {
      'HighBP': highBP,
      'HighChol': highChol,
      'CholCheck': cholCheck,
      'BMI': bmi,
      'Smoker': smoker,
      'Stroke': stroke,
      'HeartDiseaseorAttack': heartDiseaseOrAttack,
      'PhysActivity': physActivity,
      'Fruits': fruits,
      'Veggies': veggies,
      'HvyAlcoholConsump': heavyAlcohol,
      'AnyHealthcare': anyHealthcare,
      'NoDocbcCost': noDocCost,
      'GenHlth': genHealth,
      'MentHlth': mentHealth,
      'PhysHlth': physHealth,
      'DiffWalk': diffWalk,
      'Sex': sex,
      'Age': age,
      'Education': education,
      'Income': income,
    };

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Gagal melakukan prediksi. '
      'Status code: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }
}