import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../widgets/base_layout.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/device_card.dart';
import '../widgets/candidatura_card.dart';
import '../models/user_model.dart';
import '../models/aparelhos.dart';
import '../models/candidatura.dart';
import 'aparelhos_page.dart';
import 'candidatos_page.dart';
import 'candidatura_detail_page.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_dimensions.dart';
import '../../core/themes/app_text_styles.dart';
import '../core/services/device_services.dart';
import '../core/services/candidatura_services.dart';

class DashboardPage extends StatefulWidget {
  final Perfil perfil;
  final String token;
  final List<Candidatura> candidaturas;
  final List<Device> aparelhos;

  const DashboardPage({super.key, required this.perfil, required this.candidaturas, required this.aparelhos, required this.token});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _nomeController = TextEditingController();
  String? _selectedModelo;
  String? _selectedPerda;
  final _descricaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _candidaturaFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSubmittingCandidatura = false;
  int? _selectedAparelhoId;
  String? _selectedLaudoFileName;
  File? _selectedLaudoFile;
  final _candidaturaObservacaoController = TextEditingController();
  List<Candidatura> _candidaturas = [];
  List<Device> _aparelhos = [];
  
  bool _showCandidaturaForm = false;
  bool _showDoacaoForm = false;
  
  late DeviceService _deviceService;
  late CandidaturaService _candidaturaService;

  bool get isDoador => widget.perfil.tipo.toUpperCase() == 'DOADOR';
  bool get isCandidato => widget.perfil.tipo.toUpperCase() == 'CANDIDATO';
  bool get isAdmin => widget.perfil.tipo.toUpperCase() == 'EMPRESA';
  
  String get nome {
    final username = widget.perfil.userDetails.username.trim();
    if (username.isEmpty) return 'Usuário';
    return username.split(' ').first;
  }

  bool _isMyUser(int id) {
    final userIds = {widget.perfil.user, widget.perfil.id, widget.perfil.userDetails.id};
    return userIds.contains(id);
  }

  int get totalCandidaturasParticipadas => candidaturasDoUsuario.length;
  int get totalAprovadas => candidaturasDoUsuario.where((c) => c.status.toUpperCase() == 'APROVADO').length;
  int get totalRecusadas => candidaturasDoUsuario.where((c) => c.status.toUpperCase() == 'REPROVADO').length;
  int get totalAparelhosDoUsuario => _aparelhos.where((d) => _isMyUser(d.doador)).length;
  int get totalDoadosDoUsuario => _aparelhos.where((d) => _isMyUser(d.doador) && d.status.toUpperCase() == 'DOADO').length;
  int get totalAparelhosCadastrados => _aparelhos.length;
  int get totalAparelhosEmAnalise => _aparelhos.where((d) => d.status.toUpperCase() == 'AGUARDANDO').length;
  int get totalCandidatosEmAnalise => _candidaturas.where((c) => c.status.toUpperCase() == 'AGUARDANDO').length;
  int get totalCandidatosAprovados => _candidaturas.where((c) => c.status.toUpperCase() == 'APROVADO').length;
  int get totalCandidatosEscolhidos => _candidaturas.where((c) => c.status.toUpperCase() == 'ESCOLHIDO').length;

  List<Candidatura> get candidaturasDoUsuario => _candidaturas.where((c) => _isMyUser(c.candidato)).toList();

  List<Candidatura> get latestCandidaturas {
    final lista = List<Candidatura>.from(isCandidato ? candidaturasDoUsuario : _candidaturas);
    lista.sort((a, b) => b.dataCandidatura.compareTo(a.dataCandidatura));
    return lista.take(3).toList();
  }

  List<Device> get latestAparelhos {
    final lista = List<Device>.from(_aparelhos);
    lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return lista.take(3).toList();
  }

  List<Device> get aparelhosDisponiveisNaoInscritos {
    final idsInscritos = candidaturasDoUsuario.map((c) => c.aparelho).toSet();
    return _aparelhos.where((a) => a.status.toUpperCase() == 'DISPONIVEL' && !idsInscritos.contains(a.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _candidaturas = List<Candidatura>.from(widget.candidaturas);
    _aparelhos = List<Device>.from(widget.aparelhos);
    _deviceService = DeviceService(token: widget.token);
    _candidaturaService = CandidaturaService(token: widget.token);
    
  }

  Future<void> _reloadCandidaturas() async {
    if (!mounted) return;
    try {
      final data = await _candidaturaService.fetchCandidaturas();
      if (mounted && data.isNotEmpty) {
        setState(() => _candidaturas = data.map<Candidatura>((j) => Candidatura.fromJson(j)).toList());
      }
    } catch (e) {}
  }

  Future<void> _reloadAparelhos() async {
    if (!mounted) return;
    try {
      final data = await _deviceService.fetchAparelhos();
      if (mounted && data.isNotEmpty) {
        setState(() => _aparelhos = data.map<Device>((j) => Device.fromJson(j)).toList());
      }
    } catch (e) {}
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLG),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingSM),
          Text(title, style: AppTextStyle.titleMedium),
        ],
      ),
    );
  }

  Future<void> _approveDevice(int deviceId) async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final success = await _deviceService.approveDevice(deviceId);
    if (mounted) {
      if (success) {
        await _reloadAparelhos();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aparelho aprovado com sucesso!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao aprovar aparelho')));
      }
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _rejectDevice(int deviceId) async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final success = await _deviceService.rejectDevice(deviceId);
    if (mounted) {
      if (success) {
        await _reloadAparelhos();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aparelho reprovado!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao reprovar aparelho')));
      }
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _escolherCandidato(int candidaturaId) async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final success = await _candidaturaService.escolherCandidato(candidaturaId);
    if (mounted) {
      if (success) {
        await _reloadCandidaturas();
        await _reloadAparelhos();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidato escolhido com sucesso!')));
      }
      setState(() => _isSubmitting = false);
    }
  }

  void _showCandidatosDoAparelho(Device aparelho) {
    final candidatosDoAparelho = _candidaturas.where((c) => c.aparelho == aparelho.id).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Candidatos para ${aparelho.nome}'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: candidatosDoAparelho.isEmpty
              ? const Center(child: Text('Nenhum candidato para este aparelho.'))
              : ListView.separated(
                  itemCount: candidatosDoAparelho.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final candidatura = candidatosDoAparelho[index];
                    final podeEscolher = candidatura.status.toUpperCase() == 'APROVADO' && aparelho.status.toUpperCase() != 'DOADO';
                    
                    return ListTile(
                      title: Text(candidatura.candidatoNome),
                      subtitle: Text('Status: ${candidatura.statusDisplay}'),
                      trailing: podeEscolher
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _escolherCandidato(candidatura.id);
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
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar'))],
      ),
    );
  }

Widget _buildDoacaoForm() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius)),
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Doar aparelho', style: AppTextStyle.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showDoacaoForm = false;
                      _nomeController.clear();
                      _selectedModelo = null;
                      _selectedPerda = null;
                      _descricaoController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do aparelho'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o nome do aparelho' : null,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            DropdownButtonFormField<String>(
              value: _selectedModelo,
              items: const [
                DropdownMenuItem(value: 'RETRO', child: Text('Retroauricular (BTE)')),
                DropdownMenuItem(value: 'INTRA', child: Text('Intra-auricular (ITE/CIC)')),
                DropdownMenuItem(value: 'RIC', child: Text('Receptor no Canal (RIC)')),
              ],
              onChanged: (value) => setState(() => _selectedModelo = value),
              decoration: const InputDecoration(labelText: 'Modelo anatômico'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o modelo anatômico' : null,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            DropdownButtonFormField<String>(
              value: _selectedPerda,
              items: const [
                DropdownMenuItem(value: 'LEVE', child: Text('Leve')),
                DropdownMenuItem(value: 'LEVE_MODERADA', child: Text('Leve a Moderada')),
                DropdownMenuItem(value: 'MODERADA', child: Text('Moderada')),
                DropdownMenuItem(value: 'MODERADA_SEVERA', child: Text('Moderada a Severa')),
                DropdownMenuItem(value: 'SEVERA', child: Text('Severa')),
                DropdownMenuItem(value: 'SEVERA_PROFUNDA', child: Text('Severa a Profunda')),
                DropdownMenuItem(value: 'PROFUNDA', child: Text('Profunda')),
              ],
              onChanged: (value) => setState(() => _selectedPerda = value),
              decoration: const InputDecoration(labelText: 'Perda indicada'),
              validator: (value) => value == null || value.isEmpty ? 'Informe a perda indicada' : null,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Informe a descrição do aparelho' : null,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDoacao,
                child: Text(_isSubmitting ? 'Enviando...' : 'Enviar doação'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCandidaturaForm() {
  final aparelhosDisponiveis = aparelhosDisponiveisNaoInscritos;
  
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius)),
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      child: Form(
        key: _candidaturaFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nova candidatura', style: AppTextStyle.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showCandidaturaForm = false;
                      _selectedAparelhoId = null;
                      _selectedLaudoFileName = null;
                      _selectedLaudoFile = null;
                      _candidaturaObservacaoController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            if (aparelhosDisponiveis.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.spacingLG),
                child: Center(
                  child: Text(
                    'Não há aparelhos disponíveis para candidatura no momento.',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedAparelhoId,
                items: aparelhosDisponiveis.map((a) => DropdownMenuItem<int>(
                  value: a.id, 
                  child: Text('${a.nome} • ${a.modeloDisplay}')
                )).toList(),
                onChanged: (v) => setState(() => _selectedAparelhoId = v),
                decoration: const InputDecoration(labelText: 'Aparelho'),
                validator: (v) => v == null ? 'Selecione um aparelho disponível' : null,
              ),
            const SizedBox(height: AppDimensions.spacingMD),
            Row(
              children: [
                Expanded(child: Text(_selectedLaudoFileName ?? 'Nenhum laudo selecionado', style: AppTextStyle.bodyMedium)),
                TextButton(
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final pf = result.files.first;
                      setState(() {
                        _selectedLaudoFileName = pf.name;
                        _selectedLaudoFile = File(pf.path!);
                      });
                    }
                  },
                  child: const Text('Selecionar laudo'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            TextFormField(
              controller: _candidaturaObservacaoController,
              decoration: const InputDecoration(labelText: 'Observação'),
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (aparelhosDisponiveis.isEmpty || _isSubmittingCandidatura) ? null : _submitCandidatura,
                child: Text(_isSubmittingCandidatura ? 'Enviando...' : 'Enviar candidatura'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _submitDoacao() async {
  if (!_formKey.currentState!.validate()) return;
  if (!mounted) return;

  setState(() => _isSubmitting = true);

  final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.devices}');
  try {
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nome': _nomeController.text,
        'modelo_anatomico': _selectedModelo ?? '',
        'perda_indicada': _selectedPerda ?? '',
        'descricao': _descricaoController.text,
      }),
    );

    if (mounted) {
      if (response.statusCode == 201 || response.statusCode == 200) {
        await _reloadAparelhos();
        setState(() {
          _isSubmitting = false;
          _showDoacaoForm = false;
          _nomeController.clear();
          _selectedModelo = null;
          _selectedPerda = null;
          _descricaoController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação enviada com sucesso!')),
        );
      } else {
        setState(() => _isSubmitting = false);
        final body = response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar aparelho: $body')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar aparelho: $e')),
      );
    }
  }
}

Future<void> _submitCandidatura() async {
  if (!_candidaturaFormKey.currentState!.validate()) return;
  if (!mounted) return;
  
  if (_selectedLaudoFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione o laudo antes de enviar.')),
    );
    return;
  }
  
  final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.candidates}');
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer ${widget.token}';
  request.fields['aparelho'] = _selectedAparelhoId.toString();
  if (_candidaturaObservacaoController.text.isNotEmpty) {
    request.fields['observacao'] = _candidaturaObservacaoController.text;
  }
  
  final laudoFile = _selectedLaudoFile!;
  final stream = http.ByteStream(laudoFile.openRead());
  final length = await laudoFile.length();
  final multipartFile = http.MultipartFile('laudo_exame', stream, length, filename: _selectedLaudoFileName);
  request.files.add(multipartFile);
  
  setState(() => _isSubmittingCandidatura = true);
  
  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (mounted) {
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _isSubmittingCandidatura = false;
          _showCandidaturaForm = false;
          _selectedAparelhoId = null;
          _selectedLaudoFileName = null;
          _selectedLaudoFile = null;
          _candidaturaObservacaoController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidatura enviada com sucesso!')),
        );
        await _reloadCandidaturas();
      } else {
        setState(() => _isSubmittingCandidatura = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar candidatura: ${response.statusCode}')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSubmittingCandidatura = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao enviar candidatura: $e')),
      );
    }
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _candidaturaObservacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Dashboard',
      userName: nome,
      floatingActionButton: (isCandidato && !_showCandidaturaForm) || (isDoador && !_showDoacaoForm)
          ? FloatingActionButton(
              onPressed: () => setState(() => isCandidato ? _showCandidaturaForm = true : _showDoacaoForm = true),
              backgroundColor: AppColors.primary,
              child: Icon(isCandidato ? Icons.add_comment : Icons.add, color: Colors.white),
            )
          : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
              child: Text('Bem-vindo(a),', style: AppTextStyle.bodyMedium),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingXL),
              child: Text(nome, style: AppTextStyle.headlineMedium),
            ),
            
            if (isCandidato) ...[
              Row(
                children: [
                  Expanded(child: DashboardCard(title: 'Participação', value: totalCandidaturasParticipadas, icon: Icons.assignment_turned_in, color: Colors.blue)),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: DashboardCard(title: 'Aprovada', value: totalAprovadas, icon: Icons.check_circle, color: Colors.green)),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: DashboardCard(title: 'Recusada', value: totalRecusadas, icon: Icons.cancel, color: Colors.red)),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),
              if (_showCandidaturaForm) ...[_buildCandidaturaForm(), const SizedBox(height: AppDimensions.spacingLG)],
              _buildSectionHeader('Minhas últimas candidaturas', Icons.assignment),
              if (latestCandidaturas.isEmpty) const Text('Nenhuma candidatura encontrada.', style: AppTextStyle.bodyMedium)
              else Column(children: latestCandidaturas.map((c) => CandidaturaCard(candidatura: c, onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CandidaturaDetailPage(candidatura: c, token: widget.token, perfil: widget.perfil,)));
                if (mounted && result == true) await _reloadCandidaturas();
              })).toList()),
            ] else if (isDoador) ...[
              Row(
                children: [
                  Expanded(child: DashboardCard(title: 'Doados', value: totalDoadosDoUsuario, icon: Icons.favorite, color: Colors.red)),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: DashboardCard(title: 'Meus Aparelhos', value: totalAparelhosDoUsuario, icon: Icons.hearing, color: Colors.green)),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),
              if (_showDoacaoForm) ...[_buildDoacaoForm(), const SizedBox(height: AppDimensions.spacingLG)],
              _buildSectionHeader('Meus últimos aparelhos', Icons.hearing),
              if (latestAparelhos.isEmpty) const Text('Nenhum aparelho cadastrado ainda.', style: AppTextStyle.bodyMedium)
              else Column(children: latestAparelhos.map((a) => DeviceCard(
                aparelho: a,
                isAdmin: false,
                showActions: false,
              )).toList()),
            ] else if (isAdmin) ...[
              const Padding(padding: EdgeInsets.only(bottom: AppDimensions.spacingSM), child: Text('APARELHOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              Row(
                children: [
                  Expanded(child: DashboardCard(title: 'Cadastrados', value: totalAparelhosCadastrados, icon: Icons.hearing, color: Colors.blue, onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AparelhosPage(aparelhos: _aparelhos, token: widget.token, candidaturas: _candidaturas, onUpdate: () { _reloadAparelhos(); _reloadCandidaturas(); })));
                    if (mounted && result == true) await _reloadAparelhos();
                  })),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: DashboardCard(title: 'Em Análise', value: totalAparelhosEmAnalise, icon: Icons.pending, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),
              const Padding(padding: EdgeInsets.only(bottom: AppDimensions.spacingSM), child: Text('CANDIDATOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              Row(
                children: [
                  Expanded(child: DashboardCard(title: 'Em Análise', value: totalCandidatosEmAnalise, icon: Icons.person_search, color: Colors.purple, onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CandidatosPage(candidaturas: _candidaturas, token: widget.token)));
                    if (mounted && result == true) await _reloadCandidaturas();
                  })),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(child: DashboardCard(title: 'Aprovados', value: totalCandidatosAprovados, icon: Icons.check_circle, color: Colors.green)),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              Row(
                children: [
                  Expanded(child: DashboardCard(title: 'Escolhidos', value: totalCandidatosEscolhidos, icon: Icons.star, color: Colors.amber)),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLG),
              _buildSectionHeader('Últimas candidaturas', Icons.assignment),
              if (latestCandidaturas.isEmpty) const Text('Nenhuma candidatura encontrada.', style: AppTextStyle.bodyMedium)
              else Column(children: latestCandidaturas.map((c) => CandidaturaCard(candidatura: c, onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CandidaturaDetailPage(candidatura: c, token: widget.token)));
                if (mounted && result == true) await _reloadCandidaturas();
              })).toList()),
              const SizedBox(height: AppDimensions.spacingLG),
              _buildSectionHeader('Últimos aparelhos cadastrados', Icons.hearing),
              if (latestAparelhos.isEmpty) const Text('Nenhum aparelho cadastrado ainda.', style: AppTextStyle.bodyMedium)
              else Column(children: latestAparelhos.map((a) => DeviceCard(
                aparelho: a,
                isAdmin: true,
                onApprove: () => _approveDevice(a.id),
                onReject: () => _rejectDevice(a.id),
                onTap: () => _showCandidatosDoAparelho(a),
              )).toList()),
            ],
          ],
        ),
      ),
    );
  }
}