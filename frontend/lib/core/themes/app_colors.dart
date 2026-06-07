import 'package:flutter/material.dart';

class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF6366F1); 
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Cores de fundo
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Cores de status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Cores para os cards específicos
  static const Color sunlightCard = Color(0xFFFEF3C7); 
  static const Color sunlightIcon = Color(0xFFF59E0B);
  
  static const Color sleepCard = Color(0xFFE0E7FF); 
  static const Color sleepIcon = Color(0xFF4F46E5);
  
  static const Color supplementsCard = Color(0xFFD1FAE5);
  static const Color supplementsIcon = Color(0xFF10B981);
  
  static const Color fastingCard = Color(0xFFFCE7F3); 
  static const Color fastingIcon = Color(0xFFEC4899);
  
  // Cores de gradiente
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Cores de navegação
  static const Color navInactive = Color(0xFF94A3B8);
  static const Color navActive = Color(0xFF6366F1);
  static const Color navBackground = Color(0xFFFFFFFF);
  
  // Cores de borda e divisão
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  
  // Cores para o componente de "mood"
  static const Color moodBackground = Color(0xFFF1F5F9);
  static const Color moodSelectedBackground = Color(0xFF6366F1);
  static const Color moodText = Color(0xFF64748B);
  static const Color moodSelectedText = Color(0xFFFFFFFF);
}