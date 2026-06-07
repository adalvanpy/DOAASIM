import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_dimensions.dart';
import '../../core/themes/app_text_styles.dart';

import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/aparelhos.dart';
import '../models/candidatura.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;
  String _erro = '';

  Future<void> _fazerLogin() async {
    if (_usuarioController.text.isEmpty) {
      setState(() => _erro = 'Digite o usuário');
      return;
    }

    if (_senhaController.text.isEmpty) {
      setState(() => _erro = 'Digite a senha');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final resposta = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.token}',
        ),
        body: {
          'username': _usuarioController.text,
          'password': _senhaController.text,
        },
      );

      if (resposta.statusCode != 200) {
        setState(() {
          _carregando = false;
          _erro = 'Usuário ou senha inválidos';
        });
        return;
      }

      final dados = jsonDecode(resposta.body);
      final token = dados['access'];

      if (token == null) {
        setState(() {
          _carregando = false;
          _erro = 'Token não recebido do servidor';
        });
        return;
      }

      final perfilResponse = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.users}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final candidaturasResponse = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.candidates}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final aparelhosResponse = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.devices}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final perfilJson = jsonDecode(perfilResponse.body);

      Perfil perfil;

      if (perfilJson is List) {
        final usuarioEncontrado = perfilJson.firstWhere(
          (item) =>
              item is Map<String, dynamic> &&
              item['user_details'] is Map<String, dynamic> &&
              (item['user_details']['username'] ?? '') ==
                  _usuarioController.text,
          orElse: () => null,
        );

        if (usuarioEncontrado == null) {
          setState(() {
            _carregando = false;
            _erro = 'Perfil não encontrado';
          });
          return;
        }

        perfil = Perfil.fromJson(usuarioEncontrado);
      } else {
        perfil = Perfil.fromJson(perfilJson);
      }

      final candidaturaJson = jsonDecode(candidaturasResponse.body);

      List<Candidatura> candidaturas = [];

      if (candidaturaJson is List) {
        candidaturas = candidaturaJson
            .map<Candidatura>(
              (item) => Candidatura.fromJson(item),
            )
            .toList();
      }

      final aparelhosJson = jsonDecode(aparelhosResponse.body);

      List<Device> aparelhos = [];

      if (aparelhosJson is List) {
        aparelhos = aparelhosJson
            .map<Device>(
              (item) => Device.fromJson(item),
            )
            .toList();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            perfil: perfil,
            token: token,
            candidaturas: candidaturas,
            aparelhos: aparelhos,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro = 'Erro de conexão: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.screenHorizontalPadding,
            ),
            child: Container(
              padding: const EdgeInsets.all(
                AppDimensions.spacingXXL,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardBorderRadiusLarge,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hearing,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXL,
                  ),
                  Text(
                    'Bem-vindo',
                    style: AppTextStyle.userName,
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingSM,
                  ),
                  Text(
                    'Faça login para continuar',
                    style: AppTextStyle.titleMedium,
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXXL,
                  ),
                  TextField(
                    controller: _usuarioController,
                    decoration: InputDecoration(
                      labelText: 'Usuário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.inputBorderRadius,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLG,
                  ),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.inputBorderRadius,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLG,
                  ),
                  if (_erro.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Text(
                        _erro,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonBorderRadius,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _carregando
                            ? null
                            : _fazerLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.buttonBorderRadius,
                            ),
                          ),
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Não tem conta? Cadastre-se',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}