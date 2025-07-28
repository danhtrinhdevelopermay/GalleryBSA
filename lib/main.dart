import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const VehicleGalleryApp());
}

class VehicleGalleryApp extends StatelessWidget {
  const VehicleGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Gallery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}