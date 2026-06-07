import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/candidatura.dart';
import '../core/constants/api_constants.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_dimensions.dart';
import '../core/themes/app_text_styles.dart';
import '../widgets/candidatura_card.dart';
import '../core/services/candidatura_services.dart';
import 'candidatura_detail_page.dart';

class CandidatosPage extends StatefulWidget {
  final List<Candidatura> candidaturas;
  final String token;

  const CandidatosPage({
    super.key, 
    required this.candidaturas,
    required this.token,
  });

  @override
  State<CandidatosPage> createState() => _CandidatosPageState();
}

class _CandidatosPageState extends State<CandidatosPage> {
  late List<Candidatura> _candidaturas;
  late CandidaturaService _candidaturaService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _candidaturas = List<Candidatura>.from(widget.candidaturas);
    _candidaturaService = CandidaturaService(token: widget.token);
  }

  Future<void> _reloadCandidaturas() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _candidaturaService.fetchCandidaturas();
      if (mounted && data.isNotEmpty) {
        setState(() {
          _candidaturas = data.map<Candidatura>((j) => Candidatura.fromJson(j)).toList();
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatos'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _candidaturas.isEmpty
              ? const Center(
                  child: Text('Nenhuma candidatura encontrada.', style: AppTextStyle.bodyLarge),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
                  child: ListView(
                    children: _candidaturas.map((candidatura) => 
                      CandidaturaCard(
                        candidatura: candidatura,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CandidaturaDetailPage(
                                candidatura: candidatura,
                                token: widget.token,
                              ),
                            ),
                          );
                          if (mounted && result == true) {
                            await _reloadCandidaturas();
                          }
                        },
                      )
                    ).toList(),
                  ),
                ),
    );
  }
}
