import 'package:flutter/material.dart';
import 'pages/login_page.dart';  // ← Importa a tela de login
import 'core/themes/app_colors.dart';
import 'core/themes/app_dimensions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
              ),
            ),
            elevation: MaterialStateProperty.all(6),
            shadowColor: MaterialStateProperty.all(const Color(0x14000000)),
            backgroundColor: MaterialStateProperty.all(AppColors.primary),
            foregroundColor: MaterialStateProperty.all(AppColors.textLight),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}