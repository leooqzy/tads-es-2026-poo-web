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
      builder: (context) =>
          CreateProductDialog(productService: widget.productService),
    );

    if (!mounted || created != true) return;

    await _loadProducts();

    if (!mounted) return;

    _showMessage('Anúncio publicado com sucesso!');
  }

  Future<void> _editProduct(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    final priceController = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    final formKey = GlobalKey<FormState>();

    try {
      final data = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Editar anúncio'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final price = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );

                        if (price == null || price < 0.01) {
                          return 'Preço inválido.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Estoque'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final stock = int.tryParse(value ?? '');

                        if (stock == null || stock < 0) {
                          return 'Estoque inválido.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.pop(dialogContext, {
                    'name': nameController.text.trim(),
                    'description': descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    'price': double.parse(
                      priceController.text.replaceAll(',', '.'),
                    ),
                    'stock': int.parse(stockController.text),
                  });
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );

      if (data == null || !mounted) return;

      await widget.productService.update(product.id, data);

      if (!mounted) return;

      await _loadProducts();

      if (!mounted) return;

      _showMessage('Anúncio atualizado com sucesso!');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao atualizar anúncio: $error');
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      stockController.dispose();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir anúncio'),
        content: Text('Deseja realmente excluir "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.productService.delete(product.id);

      if (!mounted) return;

      await _loadProducts();

      if (!mounted) return;

      _showMessage('Anúncio excluído com sucesso!');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao excluir anúncio: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar anúncio',
                  onPressed: () => _editProduct(product),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Excluir anúncio',
                  onPressed: () => _deleteProduct(product),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(_errorMessage!),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.refresh),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(AppStrings.noProducts),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.refresh),
            ),
          ],
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
                Text('${_products.length}'),
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
