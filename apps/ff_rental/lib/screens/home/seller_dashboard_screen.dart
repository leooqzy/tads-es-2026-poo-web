import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import 'create_product_dialog.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.productService,
  });

  final User user;
  final AuthService authService;
  final ProductService productService;

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await widget.productService.getMyProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = AppStrings.loadProductsError;
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateProduct() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CreateProductDialog(productService: widget.productService);
      },
    );

    if (!mounted || created != true) return;

    await _loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anúncio publicado com sucesso!')),
    );
  }

  Future<void> _logout() async {
    await widget.authService.logout();

    if (!mounted) return;

    context.goNamed(RouteNames.login);
  }

  Widget _buildProductCard(Product product) {
    final price = product.price.toStringAsFixed(2).replaceAll('.', ',');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('R\$ $price'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${AppStrings.productStock}: ${product.stock}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.enabled
                        ? AppStrings.activeProduct
                        : AppStrings.inactiveProduct,
                    style: TextStyle(
                      color: product.enabled
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsContent() {
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
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.refresh),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(AppStrings.noProducts, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.refresh),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: _products.map(_buildProductCard).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _isLoading ? null : _loadProducts,
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
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Icon(Icons.store_rounded, color: AppColors.primary, size: 64),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.sellerDashboardTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${AppStrings.homeWelcome} ${widget.user.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(widget.user.email, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.myProductsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${_products.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isLoading || _errorMessage != null || _products.isEmpty)
              SizedBox(height: 240, child: _buildProductsContent())
            else
              _buildProductsContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _openCreateProduct,
        icon: const Icon(Icons.add),
        label: const Text('Novo anúncio'),
      ),
    );
  }
}
