import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aparelhos.dart';
import '../models/candidatura.dart';
import '../core/constants/api_constants.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_dimensions.dart';
import '../core/themes/app_text_styles.dart';
import '../widgets/device_card.dart';
import '../core/services/device_services.dart';
import '../core/services/candidatura_services.dart';

class AparelhosPage extends StatefulWidget {
  final List<Device> aparelhos;
  final String token;
  final List<Candidatura> candidaturas;
  final Function() onUpdate;

  const AparelhosPage({
    super.key, 
    required this.aparelhos,
    required this.token,
    required this.candidaturas,
    required this.onUpdate,
  });

  @override
  State<AparelhosPage> createState() => _AparelhosPageState();
}

class _AparelhosPageState extends State<AparelhosPage> {
  late List<Device> _aparelhos;
  late List<Candidatura> _candidaturas;
  bool _isLoading = false;
  late DeviceService _deviceService;
  late CandidaturaService _candidaturaService;

  @override
  void initState() {
    super.initState();
    _aparelhos = List<Device>.from(widget.aparelhos);
    _candidaturas = List<Candidatura>.from(widget.candidaturas);
    _deviceService = DeviceService(token: widget.token);
    _candidaturaService = CandidaturaService(token: widget.token);
  }

  Future<void> _reloadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final aparelhosData = await _deviceService.fetchAparelhos();
      final candidaturasData = await _candidaturaService.fetchCandidaturas();
      
      if (mounted) {
        setState(() {
          _aparelhos = aparelhosData.map<Device>((j) => Device.fromJson(j)).toList();
          _candidaturas = candidaturasData.map<Candidatura>((j) => Candidatura.fromJson(j)).toList();
        });
        widget.onUpdate();
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveDevice(int deviceId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final success = await _deviceService.approveDevice(deviceId);
    if (mounted) {
      if (success) {
        await _reloadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aparelho aprovado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao aprovar aparelho')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectDevice(int deviceId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final success = await _deviceService.rejectDevice(deviceId);
    if (mounted) {
      if (success) {
        await _reloadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aparelho reprovado!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao reprovar aparelho')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _showCandidatosDoAparelho(Device aparelho) {
    final candidatosDoAparelho = _candidaturas
        .where((c) => c.aparelho == aparelho.id)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Candidatos para ${aparelho.nome}'),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: candidatosDoAparelho.isEmpty
                ? const Center(child: Text('Nenhum candidato para este aparelho.'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: candidatosDoAparelho.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final candidatura = candidatosDoAparelho[index];
                      final bool podeEscolher = 
                          candidatura.status.toUpperCase() == 'APROVADO' &&
                          aparelho.status.toUpperCase() != 'DOADO';
                      
                      return ListTile(
                        title: Text(candidatura.candidatoNome),
                        subtitle: Text('Status: ${candidatura.statusDisplay}'),
                        trailing: podeEscolher
                            ? ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  setState(() => _isLoading = true);
                                  final success = await _candidaturaService.escolherCandidato(candidatura.id);
                                  if (mounted) {
                                    if (success) {
                                      await _reloadData();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Candidato escolhido com sucesso!')),
                                      );
                                    }
                                    setState(() => _isLoading = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Escolher'),
                              )
                            : candidatura.status.toUpperCase() == 'ESCOLHIDO'
                                ? const Chip(label: Text('Escolhido'), backgroundColor: Colors.green)
                                : const SizedBox.shrink(),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aparelhos Cadastrados'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
              child: _aparelhos.isEmpty
                  ? const Center(
                      child: Text('Nenhum aparelho cadastrado ainda.', style: AppTextStyle.bodyLarge),
                    )
                  : ListView(
                      children: _aparelhos.map((aparelho) {
                        final isApproved = aparelho.status.toUpperCase() == 'DISPONIVEL';
                        final isDonated = aparelho.status.toUpperCase() == 'DOADO';
                        
                        return DeviceCard(
                          aparelho: aparelho,
                          isAdmin: true,
                          onApprove: () => _approveDevice(aparelho.id),
                          onReject: () => _rejectDevice(aparelho.id),
                          onTap: () {
                            if (isApproved || isDonated) {
                              _showCandidatosDoAparelho(aparelho);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Este aparelho está aguardando aprovação.')),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
            ),
    );
  }
}
