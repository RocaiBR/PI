import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/sanitizer.dart';
import '../app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  // ── Cores dinâmicas baseadas no padrão estilizado ─────────────────────────
  final bool _isDark = true;
  Color get _bgColor => _isDark ? AppColors.surface : const Color(0xFFF4F6FA);
  Color get _textColor =>
      _isDark ? AppColors.textPrimary : const Color(0xFF1C1C2E);
  Color get _subText =>
      _isDark ? AppColors.textSecondary : const Color(0xFF6B7280);
  Color get _inputFill => _isDark ? const Color(0xFF1E0D14) : Colors.white;
  Color get _inputBorder =>
      _isDark ? AppColors.primary.withOpacity(0.35) : const Color(0xFFDDD0D5);

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nomeSanitizado = sanitize(_nomeController.text);
      final emailSanitizado = sanitize(_emailController.text);
      final senha = _senhaController.text;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailSanitizado, password: senha);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nomeSanitizado,
        'email': emailSanitizado,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Conta criada com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro = "Erro ao criar conta.";
      if (e.code == 'email-already-in-use') {
        mensagemErro = "Este e-mail já está em uso.";
      } else if (e.code == 'weak-password') {
        mensagemErro = "A senha é muito fraca.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget customizado para os inputs modernos
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: _textColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _subText),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: _inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: _inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: buildGradientAppBar(title: 'Criar Conta'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_alt_1,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 24),
                _buildModernInput(
                  controller: _nomeController,
                  label: 'Nome Completo',
                  icon: Icons.person,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildModernInput(
                  controller: _emailController,
                  label: 'E-mail',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe o e-mail';
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return 'Formato inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildModernInput(
                  controller: _senhaController,
                  label: 'Senha',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe a senha';
                    final senhaRegex = RegExp(
                        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{6,}$');
                    if (!senhaRegex.hasMatch(value)) {
                      return 'Mínimo 6 caracteres, 1 letra e 1 número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : AnimatedPressButton(
                        onPressed: _registrar,
                        child: const Text('CADASTRAR',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
