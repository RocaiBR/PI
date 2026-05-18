import 'package:flutter/material.dart';
import '../app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _baseData = [
    "Projeto Elétrico Alpha",
    "Normas ABNT 2026",
    "Cálculo Estrutural Beta",
    "Planta Hidráulica Omega",
    "Documentação TOT v1",
    "Histórico de Interligações",
    "Relatório de Eficiência",
    "Diretrizes de Segurança"
  ];
  List<String> _filteredData = [];

  final bool _isDark = true;
  Color get _bgColor => _isDark ? AppColors.surface : const Color(0xFFF4F6FA);
  Color get _cardColor => _isDark ? AppColors.cardDark : Colors.white;

  @override
  void initState() {
    super.initState();
    _filteredData = _baseData;
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _baseData
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: buildGradientAppBar(title: 'Pesquisa na Base TOT'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterData,
              style: TextStyle(color: _isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Buscar projetos, normas...',
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.accent)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredData.isEmpty
                  ? const Center(
                      child: Text("Nenhum projeto encontrado.",
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.folder,
                                  color: AppColors.primary),
                            ),
                            title: Text(_filteredData[index],
                                style: TextStyle(
                                    color:
                                        _isDark ? Colors.white : Colors.black)),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey),
                            onTap: () =>
                                Navigator.pushNamed(context, '/details'),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
