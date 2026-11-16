import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_validators.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Direciona o usuário conforme o perfil recebido do Laravel.
      final destination = user.isAdmin
          ? RouteNames.adminDashboard
          : user.isSeller
          ? RouteNames.sellerDashboard
          : RouteNames.catalog;

      context.goNamed(destination, extra: user);
    } on AppException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.unexpectedError)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= AppSpacing.desktopBreakpoint) {
              return _buildDesktopLayout(context);
            }

            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  // Layout para computador
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildHeroPanel(context)),
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.formMaxWidth,
                  ),
                  child: _buildLoginCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Apresentação do FF Rental
  Widget _buildHeroPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBrand(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.heroEyebrow,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.heroTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: AppSpacing.heroTitleSize,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.heroDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Text(
            AppStrings.tagline,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // Logo e nome
  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          height: AppSpacing.logoSize,
          width: AppSpacing.logoSize,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: const Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
            size: AppSpacing.iconLarge,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          AppStrings.appName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Formulário de login
  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.formPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.loginTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: AppSpacing.loginTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              AppStrings.loginSubtitle,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: AppSpacing.xl),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateEmail,
              decoration: const InputDecoration(
                labelText: AppStrings.email,
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: AppValidators.validatePassword,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: AppStrings.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Botão entrar
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.login),
            ),

            const SizedBox(height: AppSpacing.md),

            // Acesso ao cadastro
            TextButton(
              onPressed: () {
                context.goNamed(RouteNames.register);
              },
              child: const Text(AppStrings.registerPrompt),
            ),
          ],
        ),
      ),
    );
  }

  // Layout para celular
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mobilePagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrand(),

          const SizedBox(height: AppSpacing.xl),

          Text(
            AppStrings.heroTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: AppSpacing.mobileHeroTitleSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            AppStrings.heroDescription,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),

          const SizedBox(height: AppSpacing.xl),

          _buildLoginCard(context),
        ],
      ),
    );
  }
}
