import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_dimensions.dart';
import '../../core/themes/app_text_styles.dart';
import '../core/constants/api_constants.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  String _tipoUsuario = 'CANDIDATO';

  bool _carregando = false;
  String _erro = '';

  Future<void> _fazerCadastro() async {
    final usuario = _usuarioController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;
    final cpfCnpj = _cpfCnpjController.text.trim();

    if (usuario.isEmpty) {
      setState(() => _erro = 'Digite o nome de usuário.');
      return;
    }

    if (email.isEmpty) {
      setState(() => _erro = 'Digite o e-mail.');
      return;
    }

    if (senha.isEmpty) {
      setState(() => _erro = 'Digite a senha.');
      return;
    }

    if (senha.length < 6) {
      setState(() => _erro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    if (senha != confirmarSenha) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    if (cpfCnpj.isEmpty) {
      setState(() => _erro = 'Digite o CPF/CNPJ.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = '';
    });

    try {
      final resposta = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'username': usuario,
            'email': email,
            'password': senha,
            'tipo': _tipoUsuario,
            'cpf_cnpj': cpfCnpj,
          },
        ),
      );

      if (resposta.statusCode == 201 || resposta.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso! Faça login.'),
            backgroundColor: AppColors.success,
          ),
        );

        // Volta para a página de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      final body = jsonDecode(resposta.body);
      final mensagem = body is Map && body.isNotEmpty
          ? body.values.map((item) => item.toString()).join('\n')
          : 'Erro ao cadastrar. Verifique os dados e tente novamente.';

      setState(() {
        _carregando = false;
        _erro = mensagem;
      });
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
            padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXXL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadiusLarge),
                // boxShadow: AppShadows.cardLarge, // REMOVIDO: Sombra removida
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
                      Icons.person_add,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),
                  Text('Cadastro', style: AppTextStyle.userName),
                  const SizedBox(height: AppDimensions.spacingSM),
                  Text('Crie sua conta para acessar o app', style: AppTextStyle.titleMedium),
                  const SizedBox(height: AppDimensions.spacingXXL),
                  TextField(
                    controller: _usuarioController,
                    decoration: InputDecoration(
                      labelText: 'Usuário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  TextField(
                    controller: _confirmarSenhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  TextField(
                    controller: _cpfCnpjController,
                    decoration: InputDecoration(
                      labelText: 'CPF/CNPJ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                      prefixIcon: const Icon(Icons.receipt_long),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  DropdownButtonFormField<String>(
                    value: _tipoUsuario,
                    decoration: InputDecoration(
                      labelText: 'Tipo de usuário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EMPRESA', child: Text('Empresa')),
                      DropdownMenuItem(value: 'DOADOR', child: Text('Doador')),
                      DropdownMenuItem(value: 'CANDIDATO', child: Text('Candidato')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _tipoUsuario = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  if (_erro.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.spacingLG),
                      child: Text(
                        _erro,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                      ),
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _fazerCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                          ),
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já tem uma conta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Faça login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
