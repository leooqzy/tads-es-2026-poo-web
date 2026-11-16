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

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.productService,
  });

  final User user;
  final AuthService authService;
  final ProductService productService;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
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
      final products = await widget.productService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();

    if (!mounted) return;

    context.goNamed(RouteNames.login);
  }

  Widget _buildImage({
    required String? imageUrl,
    required double width,
    required double height,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined, size: 32),
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined, size: 32),
        );
      },
    );
  }

  void _showProductImages(Product product) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Imagem da conta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(
                    imageUrl: product.imageAccountUrl,
                    width: double.infinity,
                    height: 220,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Imagem do inventário',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(
                    imageUrl: product.imageInventoryUrl,
                    width: double.infinity,
                    height: 220,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final price = product.price.toStringAsFixed(2).replaceAll('.', ',');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _showProductImages(product),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImage(
                      imageUrl: product.imageAccountUrl,
                      width: 112,
                      height: 100,
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
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'R\$ $price',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Estoque: ${product.stock}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.stock > 0 ? 'Disponível' : 'Indisponível',
                          style: TextStyle(
                            color: product.stock > 0
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
              if (product.description != null &&
                  product.description!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  product.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Ver conta e inventário',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 350,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline, size: 52),
          const SizedBox(height: AppSpacing.md),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    if (_products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.inventory_2_outlined, size: 58, color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Center(child: Text('Nenhum anúncio disponível no momento.')),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          AppStrings.catalogTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bem-vindo, ${widget.user.name}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                'Contas disponíveis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text('${_products.length}'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._products.map(_buildProductCard),
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
            tooltip: 'Atualizar catálogo',
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
      body: RefreshIndicator(onRefresh: _loadProducts, child: _buildBody()),
    );
  }
}
