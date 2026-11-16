import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final ApiClient _apiClient;

  Map<String, dynamic> _totals = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _loadDashboard();
  }

  int _number(String key) {
    final value = _totals[key];

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.dio.get('/admin/dashboard');

      final data = response.data;

      if (data is! Map || data['totals'] is! Map) {
        throw Exception('Resposta inválida do painel administrativo.');
      }

      if (!mounted) return;

      setState(() {
        _totals = Map<String, dynamic>.from(data['totals'] as Map);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Não foi possível carregar os dados administrativos.';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();

    if (!mounted) return;

    context.goNamed(RouteNames.login);
  }

  Widget _summaryCard({
    required String title,
    required int value,
    required IconData icon,
    String? description,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (description != null)
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _summaryCard(
          title: 'Anúncios',
          value: _number('products'),
          icon: Icons.sports_esports,
          description: 'Total cadastrado',
        ),
        _summaryCard(
          title: 'Anúncios ativos',
          value: _number('active_products'),
          icon: Icons.check_circle_outline,
          description: 'Disponíveis no catálogo',
        ),
        _summaryCard(
          title: 'Usuários',
          value: _number('users'),
          icon: Icons.people_outline,
          description: 'Contas cadastradas',
        ),
        _summaryCard(
          title: 'Categorias',
          value: _number('categories'),
          icon: Icons.category_outlined,
          description: 'Categorias registradas',
        ),
        _summaryCard(
          title: 'Pedidos',
          value: _number('orders'),
          icon: Icons.shopping_bag_outlined,
          description: 'Pedidos registrados',
        ),
        _summaryCard(
          title: 'Avaliações',
          value: _number('reviews'),
          icon: Icons.star_outline,
          description: 'Avaliações registradas',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: 'Atualizar painel',
            onPressed: _isLoading ? null : _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: AppStrings.logout,
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.adminPanelTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${AppStrings.homeWelcome} ${widget.user.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(widget.user.email),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Visão geral do sistema',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDashboard(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        AppStrings.adminModulesTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Os dados acima são carregados diretamente da API administrativa.',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
