import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_validators.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();

  String _selectedRole = 'seller';

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _changeRole(String newRole) {
    setState(() {
      _selectedRole = newRole;

      if (newRole == 'buyer') {
        _phoneController.clear();
        _cpfController.clear();
      }
    });
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await widget.authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmationController.text,
        role: _selectedRole,
        phone: _selectedRole == 'seller' ? _phoneController.text : null,
        cpf: _selectedRole == 'seller' ? _cpfController.text : null,
      );

      if (!mounted) return;

      final destination = user.isSeller
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

  Widget _buildRoleOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final selected = _selectedRole == value;

    return Card(
      color: selected ? AppColors.surfaceElevated : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        activeColor: AppColors.primary,
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildSellerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),

        Text(
          AppStrings.sellerContactTitle,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: AppValidators.validatePhone,
          decoration: const InputDecoration(
            labelText: AppStrings.phone,
            hintText: AppStrings.phoneHint,
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _cpfController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: AppValidators.validateCpf,
          decoration: const InputDecoration(
            labelText: AppStrings.cpf,
            hintText: AppStrings.cpfHint,
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.login,
          onPressed: () {
            context.goNamed(RouteNames.login);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(AppStrings.appName),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      size: 56,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      AppStrings.registerTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      AppStrings.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: AppValidators.validateName,
                      decoration: const InputDecoration(
                        labelText: AppStrings.name,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

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
                      textInputAction: TextInputAction.next,
                      validator: AppValidators.validatePassword,
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

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        return AppValidators.validatePasswordConfirmation(
                          value,
                          _passwordController.text,
                        );
                      },
                      decoration: InputDecoration(
                        labelText: AppStrings.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmation = !_obscureConfirmation;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmation
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      AppStrings.roleQuestion,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    RadioGroup<String>(
                      groupValue: _selectedRole,
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        _changeRole(newValue);
                      },
                      child: Column(
                        children: [
                          _buildRoleOption(
                            value: 'seller',
                            title: AppStrings.sellerOption,
                            description: AppStrings.sellerDescription,
                            icon: Icons.store_outlined,
                          ),
                          _buildRoleOption(
                            value: 'buyer',
                            title: AppStrings.buyerOption,
                            description: AppStrings.buyerDescription,
                            icon: Icons.sports_esports_outlined,
                          ),
                        ],
                      ),
                    ),

                    if (_selectedRole == 'seller') _buildSellerFields(),

                    const SizedBox(height: AppSpacing.lg),

                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.register),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextButton(
                      onPressed: () {
                        context.goNamed(RouteNames.login);
                      },
                      child: const Text(AppStrings.backToLogin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
