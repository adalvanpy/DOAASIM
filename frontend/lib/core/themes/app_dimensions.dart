import 'package:flutter/material.dart';

/// ===============================
/// DIMENSÕES
/// ===============================
class AppDimensions {
  // Espaçamentos gerais
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Alturas de cards
  static const double cardHeight = 100.0;
  static const double cardHeightLarge = 160.0;
  static const double cardHeightSmall = 80.0;

  // Larguras de cards
  static const double cardWidth = double.infinity;
  static const double cardWidthSmall = 160.0;
  static const double cardWidthMedium = 200.0;
  static const double cardWidthLarge = double.infinity;

  // Margens e paddings dos cards
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);

  static const EdgeInsets cardContentPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  // Raio dos cards
  static const double cardBorderRadius = 16.0;
  static const double cardBorderRadiusSmall = 12.0;
  static const double cardBorderRadiusLarge = 24.0;

  // Dimensões dos ícones
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeExtraLarge = 24.0;
  static const double iconSizeCard = 40.0;

  // Alturas de componentes
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 70.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;

  // Larguras de componentes
  static const double buttonWidth = double.infinity;
  static const double buttonWidthSmall = 120.0;

  // Raio de componentes
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;

  // Layout da tela principal
  static const double screenHorizontalPadding = 20.0;
  static const double screenVerticalPadding = 24.0;

  // Grid de cards
  static const int gridCrossAxisCount = 2;
  static const double gridCrossAxisSpacing = 16.0;
  static const double gridMainAxisSpacing = 16.0;

  // Header
  static const double headerTopPadding = 60.0;
  static const double avatarSize = 48.0;
  static const double scoreCircleSize = 80.0;
  static const double scoreCircleStrokeWidth = 6.0;

  // Mood
  static const double moodButtonSize = 48.0;
  static const double moodSpacing = 12.0;

  // Score diário
  static const double dailyScoreSize = 100.0;
  static const double dailyScoreStrokeWidth = 8.0;
}

/// ===============================
/// SOMBRAS
/// ===============================
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardLarge = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ],
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C6FF),
      Color(0xFF0072FF),
    ],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C853),
      Color(0xFF64DD17),
    ],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8F9FA),
    ],
  );

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE9ECEF),
    ],
  );
}