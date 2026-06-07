import 'package:flutter/material.dart';
import '../core/themes/app_colors.dart';

class StatusHelper {
  static Color getCandidaturaStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APROVADO':
        return Colors.green;
      case 'REPROVADO':
        return Colors.red;
      case 'ESCOLHIDO':
        return Colors.amber;
      default:
        return Colors.orange;
    }
  }
  
  static Color getAparelhoStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DISPONIVEL':
        return Colors.green;
      case 'DOADO':
        return Colors.blue;
      case 'AGUARDANDO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  static String getStatusDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'AGUARDANDO':
        return 'Aguardando';
      case 'APROVADO':
        return 'Aprovado';
      case 'REPROVADO':
        return 'Reprovado';
      case 'ESCOLHIDO':
        return 'Escolhido';
      case 'DISPONIVEL':
        return 'Disponível';
      case 'DOADO':
        return 'Doado';
      default:
        return status;
    }
  }
}