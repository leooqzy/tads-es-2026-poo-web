import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/product_service.dart';

class CreateProductDialog extends StatefulWidget {
  const CreateProductDialog({super.key, required this.productService});

  final ProductService productService;

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  final _picker = ImagePicker();

  XFile? _accountImage;
  XFile? _inventoryImage;

  Uint8List? _accountImageBytes;
  Uint8List? _inventoryImageBytes;

  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isAccount}) async {
    if (_isPickingImage || _isSaving) return;

    setState(() => _isPickingImage = true);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        if (isAccount) {
          _accountImage = image;
          _accountImageBytes = bytes;
        } else {
          _inventoryImage = image;
          _inventoryImageBytes = bytes;
        }
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Não foi possível selecionar a imagem.');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildImagePicker({
    required String title,
    required String description,
    required Uint8List? bytes,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving || _isPickingImage ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: bytes == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 38),
                      SizedBox(height: 8),
                      Text('Selecionar imagem'),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      bytes,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_accountImage == null || _inventoryImage == null) {
      _showMessage('Selecione a imagem da conta e a imagem do inventário.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final price = double.parse(
        _priceController.text.trim().replaceAll(',', '.'),
      );

      final stock = int.parse(_stockController.text.trim());

      await widget.productService.create(
        data: {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'price': price,
          'stock': stock,
          'position': 0,
          'enabled': true,
        },
        accountImage: _accountImage!,
        inventoryImage: _inventoryImage!,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Novo anúncio',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do anúncio',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do anúncio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final price = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );

                    if (price == null || price < 0.01) {
                      return 'Informe um preço válido.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade em estoque',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final stock = int.tryParse((value ?? '').trim());

                    if (stock == null || stock < 0) {
                      return 'Informe uma quantidade válida.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildImagePicker(
                  title: 'Imagem da conta *',
                  description:
                      'Envie uma imagem mostrando a conta de Free Fire.',
                  bytes: _accountImageBytes,
                  onTap: () => _pickImage(isAccount: true),
                ),
                const SizedBox(height: 18),

                _buildImagePicker(
                  title: 'Imagem do inventário *',
                  description:
                      'Envie uma imagem mostrando o inventário da conta.',
                  bytes: _inventoryImageBytes,
                  onTap: () => _pickImage(isAccount: false),
                ),
                const SizedBox(height: 8),

                Text(
                  'As duas imagens são obrigatórias. Formatos aceitos: JPG, PNG e WEBP. Máximo de 5 MB cada.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.publish),
                        label: Text(
                          _isSaving ? 'Publicando...' : 'Publicar anúncio',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
