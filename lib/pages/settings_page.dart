import 'package:flutter/material.dart';
import '../app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  // ── Cores dinâmicas ─────────────────────────
  final bool _isDark = true;
  Color get _bgColor => _isDark ? AppColors.surface : const Color(0xFFF4F6FA);
  Color get _cardColor => _isDark ? AppColors.cardDark : Colors.white;
  Color get _textColor =>
      _isDark ? AppColors.textPrimary : const Color(0xFF1C1C2E);
  Color get _cardBorder =>
      _isDark ? AppColors.primary.withOpacity(0.25) : const Color(0xFFE8D8DF);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsBlock({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          if (!_isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: buildGradientAppBar(title: 'Configurações'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('PREFERÊNCIAS'),
          _buildSettingsBlock(
            children: [
              SwitchListTile(
                title:
                    Text('Notificações', style: TextStyle(color: _textColor)),
                value: _notificationsEnabled,
                activeColor: AppColors.accent,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                title: Text('Modo Escuro', style: TextStyle(color: _textColor)),
                value: _darkModeEnabled,
                activeColor: AppColors.accent,
                onChanged: (val) => setState(() => _darkModeEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('CONTA'),
          _buildSettingsBlock(
            children: [
              ListTile(
                leading: const Icon(Icons.lock, color: AppColors.primary),
                title:
                    Text('Alterar Senha', style: TextStyle(color: _textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Excluir Conta',
                    style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('SOBRE'),
          _buildSettingsBlock(
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: AppColors.primary),
                title:
                    Text('Versão do App', style: TextStyle(color: _textColor)),
                trailing:
                    const Text('1.0.0+1', style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading:
                    const Icon(Icons.description, color: AppColors.primary),
                title: Text('Termos de Serviço',
                    style: TextStyle(color: _textColor)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
