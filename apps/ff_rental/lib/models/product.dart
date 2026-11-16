import '../core/constants/api_constants.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    this.userId,
    this.categoryId,
    this.description,
    this.image,
    this.imageAccount,
    this.imageInventory,
    required this.price,
    required this.stock,
    required this.position,
    required this.enabled,
  });

  final int id;
  final int? userId;
  final int? categoryId;
  final String name;
  final String? description;
  final String? image;
  final String? imageAccount;
  final String? imageInventory;
  final double price;
  final int stock;
  final int position;
  final bool enabled;

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? get imageAccountUrl => _resolveImageUrl(imageAccount);

  String? get imageInventoryUrl => _resolveImageUrl(imageInventory);

  String? get imageUrl => _resolveImageUrl(image);

  String? _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final value = path.trim();
    final parsed = Uri.tryParse(value);

    if (parsed != null && parsed.hasScheme) {
      return value;
    }

    var relativePath = value.startsWith('/') ? value.substring(1) : value;

    if (relativePath.startsWith('storage/')) {
      relativePath = relativePath.substring('storage/'.length);
    }

    final baseUri = Uri.parse(ApiConstants.baseUrl);

    return baseUri
        .replace(path: '/storage/$relativePath', query: null, fragment: null)
        .toString();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      imageAccount: json['image_account']?.toString(),
      imageInventory: json['image_inventory']?.toString(),
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']) ?? 0,
      position: _parseInt(json['position']) ?? 0,
      enabled:
          json['enabled'] == true ||
          json['enabled'] == 1 ||
          json['enabled'] == '1' ||
          json['enabled'] == 'true',
    );
  }
}
