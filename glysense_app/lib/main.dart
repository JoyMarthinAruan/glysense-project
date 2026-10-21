import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const GlySenseApp());
}

class GlySenseApp extends StatelessWidget {
  const GlySenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlySense',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F7),
      ),
      home: const HomeScreen(),
    );
  }
}