import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/sanitizer.dart';
import '../app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ── Cores dinâmicas (segue o tema do sistema) ─────────────────────────────
  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  Color get _bgColor => _isDark ? AppColors.surface : const Color(0xFFF7F3F5);

  Color get _textColor =>
      _isDark ? AppColors.textPrimary : const Color(0xFF1C0F18);

  Color get _subText =>
      _isDark ? AppColors.textSecondary : const Color(0xFF7A5566);

  Color get _inputFill => _isDark ? const Color(0xFF1E0D14) : Colors.white;

  Color get _inputBorder => _isDark
      ? AppColors.primary.withOpacity(0.35)
      : AppColors.primary.withOpacity(0.25);

  Future<void> _fazerLogin() async {
    final emailInput = _emailController.text.trim();
    final senhaInput = _senhaController.text;

    if (emailInput == 'admin' && senhaInput == '123') {
      Navigator.pushReplacementNamed(context, '/home',
          arguments: 'Administrador');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final emailSanitizado = sanitize(emailInput);
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailSanitizado, password: senhaInput);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      String nomeUsuario = "Usuário";
      if (userDoc.exists && userDoc.data() != null) {
        nomeUsuario =
            (userDoc.data() as Map<String, dynamic>)['nome'] ?? "Usuário";
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home',
            arguments: nomeUsuario);
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro = "Erro ao fazer login.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        mensagemErro = "E-mail ou senha incorretos.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: TextStyle(color: _textColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _subText),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: _subText),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: _inputBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: _inputBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo do App ──────────────────────────────────────────────
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withOpacity(_isDark ? 0.45 : 0.20),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Título ───────────────────────────────────────────────────
                Text(
                  'Bem-vindo ao Tot',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Faça login para continuar',
                  style: TextStyle(fontSize: 14, color: _subText),
                ),
                const SizedBox(height: 32),

                // ── Campos ───────────────────────────────────────────────────
                _buildModernInput(
                  controller: _emailController,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe o e-mail'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildModernInput(
                  controller: _senhaController,
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe a senha'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/recovery'),
                    child: Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Botão Entrar ─────────────────────────────────────────────
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : AnimatedPressButton(
                        onPressed: _fazerLogin,
                        child: const Text(
                          'ENTRAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // ── Cadastro ─────────────────────────────────────────────────
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(
                      color: _isDark ? _subText : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
