import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  Future<void> _logout(BuildContext context) async {
    await authService.logout();

    if (!context.mounted) return;

    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: AppStrings.logout,
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: isMobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.adminPanelTitle,
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      '${AppStrings.homeWelcome} ${user.name}',
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      user.email,
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      AppStrings.adminModulesTitle,
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Wrap(
                      alignment: isMobile
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        _moduleCard(
                          context,
                          Icons.gamepad,
                          AppStrings.adminProducts,
                          isMobile ? constraints.maxWidth : 220,
                        ),
                        _moduleCard(
                          context,
                          Icons.people,
                          AppStrings.adminUsers,
                          isMobile ? constraints.maxWidth : 220,
                        ),
                        _moduleCard(
                          context,
                          Icons.category,
                          AppStrings.adminCategories,
                          isMobile ? constraints.maxWidth : 220,
                        ),
                        _moduleCard(
                          context,
                          Icons.shopping_bag,
                          AppStrings.adminOrders,
                          isMobile ? constraints.maxWidth : 220,
                        ),
                        _moduleCard(
                          context,
                          Icons.star,
                          AppStrings.adminReviews,
                          isMobile ? constraints.maxWidth : 220,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
