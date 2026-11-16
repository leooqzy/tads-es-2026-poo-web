import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductService {
  ProductService(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> getProducts() {
    return _repository.getProducts();
  }

  Future<List<Product>> getMyProducts() {
    return _repository.getMyProducts();
  }

  Future<Product> create({
    required Map<String, dynamic> data,
    required XFile accountImage,
    required XFile inventoryImage,
  }) {
    return _repository.create(
      data: data,
      accountImage: accountImage,
      inventoryImage: inventoryImage,
    );
  }

  Future<Product> update(int id, Map<String, dynamic> data) {
    return _repository.update(id, data);
  }

  Future<void> delete(int id) {
    return _repository.delete(id);
  }
}
