import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}