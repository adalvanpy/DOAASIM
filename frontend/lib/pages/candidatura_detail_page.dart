import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/candidatura.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_dimensions.dart';
import '../core/themes/app_text_styles.dart';
import '../utils/status_helper.dart';

class CandidaturaDetailPage extends StatefulWidget {
  final Candidatura candidatura;
  final String token;
  final Perfil? perfil; 

  const CandidaturaDetailPage({
    super.key, 
    required this.candidatura, 
    required this.token,
    this.perfil, 
  });

  @override
  State<CandidaturaDetailPage> createState() => _CandidaturaDetailPageState();
}

class _CandidaturaDetailPageState extends State<CandidaturaDetailPage> {
  late String status;
  bool carregando = false;
  String erro = '';

  
  bool get isEmpresa => widget.perfil?.tipo.toUpperCase() == 'EMPRESA';

  @override
  void initState() {
    super.initState();
    status = widget.candidatura.statusDisplay;
  }

  Future<void> _atualizarStatus(String novoStatus) async {
    setState(() {
      carregando = true;
      erro = '';
    });

    String endpoint;
    if (novoStatus == 'APROVADO') {
      endpoint = '${ApiConstants.baseUrl}${ApiConstants.candidates}${widget.candidatura.id}/aprovar/';
    } else {
      endpoint = '${ApiConstants.baseUrl}${ApiConstants.candidates}${widget.candidatura.id}/reprovar/';
    }
    
    final url = Uri.parse(endpoint);
    
    try {
      final resposta = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (resposta.statusCode == 200 || resposta.statusCode == 202) {
        setState(() {
          status = novoStatus == 'APROVADO' ? 'Aprovado' : 'Reprovado';
          carregando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidatura ${novoStatus == 'APROVADO' ? 'aprovada' : 'reprovada'} com sucesso.'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
        return;
      }

      final dados = jsonDecode(resposta.body);
      setState(() {
        carregando = false;
        erro = dados is Map && dados.isNotEmpty ? dados.values.join(' ') : 'Falha ao atualizar status.';
      });
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro de conexão: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final statusColor = StatusHelper.getCandidaturaStatusColor(widget.candidatura.status);
      print('isEmpresa: $isEmpresa');
      print('Status: ${widget.candidatura.status}');
      print('Status upper: ${widget.candidatura.status.toUpperCase()}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da candidatura'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        const Text(
                          'Informações da Candidatura',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                    const Divider(),
                    const SizedBox(height: AppDimensions.spacingLG),
                    
                    
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, size: 22, color: Colors.blue),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Candidato', style: AppTextStyle.titleMedium),
                              const SizedBox(height: AppDimensions.spacingXS),
                              Text(
                                widget.candidatura.candidatoNome,
                                style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                    
                    
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.hearing, size: 22, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Aparelho', style: AppTextStyle.titleMedium),
                              const SizedBox(height: AppDimensions.spacingXS),
                              Text(
                                widget.candidatura.aparelhoNome,
                                style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                    
                    
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.info, size: 22, color: statusColor),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status', style: AppTextStyle.titleMedium),
                              const SizedBox(height: AppDimensions.spacingXS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingSM,
                                  vertical: AppDimensions.spacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                    
                 
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.attach_file, size: 22, color: Colors.orange),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Laudo', style: AppTextStyle.titleMedium),
                              const SizedBox(height: AppDimensions.spacingXS),
                              InkWell(
                                onTap: widget.candidatura.laudoExame.isNotEmpty
                                    ? () {
                                        
                                      }
                                    : null,
                                child: Text(
                                  widget.candidatura.laudoExame.isNotEmpty 
                                      ? widget.candidatura.laudoExame 
                                      : 'Nenhum arquivo informado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.candidatura.laudoExame.isNotEmpty 
                                        ? AppColors.primary 
                                        : AppColors.textSecondary,
                                    decoration: widget.candidatura.laudoExame.isNotEmpty 
                                        ? TextDecoration.underline 
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                    
                   
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today, size: 20, color: Colors.purple),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data da candidatura', style: AppTextStyle.titleMedium),
                              const SizedBox(height: AppDimensions.spacingXS),
                              Text(
                                widget.candidatura.dataCandidatura.toLocal().toString(),
                                style: AppTextStyle.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            
            if (erro.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingLG),
                child: Text(erro, style: const TextStyle(color: AppColors.error)),
              ),
            
           
            if (isEmpresa && widget.candidatura.status == 'AGUARDANDO')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: carregando ? null : () => _atualizarStatus('APROVADO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLG),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                        ),
                      ),
                      child: carregando 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('Aprovar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingLG),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: carregando ? null : () => _atualizarStatus('REPROVADO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLG),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                        ),
                      ),
                      child: carregando 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('Recusar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            
            
            if (!isEmpresa && widget.candidatura.status == 'AGUARDANDO')
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    SizedBox(width: AppDimensions.spacingSM),
                    Text(
                      'Apenas empresas podem processar esta candidatura.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            
            if (widget.candidatura.status != 'AGUARDANDO')
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary),
                    SizedBox(width: AppDimensions.spacingSM),
                    Text(
                      'Esta candidatura já foi processada.',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
