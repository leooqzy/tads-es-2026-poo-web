import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/app_exception.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._apiClient);

  final ApiClient _apiClient;

  // Converte a resposta mesmo quando o servidor envia JSON como texto.
  dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  List<dynamic> _extractProducts(dynamic data) {
    final decoded = _decodeResponse(data);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      final products = decoded['data'];

      if (products is List) {
        return products;
      }
    }

    throw const AppException('Formato inválido ao carregar anúncios.');
  }

  Future<List<Product>> getProducts() {
    return _getProducts(ApiConstants.productsEndpoint);
  }

  Future<List<Product>> getMyProducts() {
    return _getProducts(ApiConstants.myProductsEndpoint);
  }

  Future<List<Product>> _getProducts(String endpoint) async {
    try {
      final response = await _apiClient.dio.get(endpoint);

      final products = _extractProducts(response.data);

      return products
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (error) {
      throw _handleError(error);
    } on FormatException {
      throw const AppException('A API retornou dados inválidos.');
    }
  }

  Future<Product> create({
    required Map<String, dynamic> data,
    required XFile accountImage,
    required XFile inventoryImage,
  }) async {
    try {
      final fields = Map<String, dynamic>.from(data);

      if (fields['enabled'] != null) {
        fields['enabled'] = fields['enabled'] == true || fields['enabled'] == 1
            ? '1'
            : '0';
      }

      final formData = FormData.fromMap({
        ...fields,
        'image_account': MultipartFile.fromBytes(
          await accountImage.readAsBytes(),
          filename: accountImage.name,
        ),
        'image_inventory': MultipartFile.fromBytes(
          await inventoryImage.readAsBytes(),
          filename: inventoryImage.name,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.productsEndpoint,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      final decoded = _decodeResponse(response.data);

      return Product.fromJson(Map<String, dynamic>.from(decoded as Map));
    } on DioException catch (error) {
      throw _handleError(error);
    } on FormatException {
      throw const AppException(
        'A API retornou uma resposta inválida ao cadastrar o anúncio.',
      );
    }
  }

  Future<Product> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.productsEndpoint}/$id',
        data: data,
      );

      final decoded = _decodeResponse(response.data);

      return Product.fromJson(Map<String, dynamic>.from(decoded as Map));
    } on DioException catch (error) {
      throw _handleError(error);
    } on FormatException {
      throw const AppException(
        'A API retornou uma resposta inválida ao atualizar o anúncio.',
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.productsEndpoint}/$id');
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  AppException _handleError(DioException error) {
    dynamic data = error.response?.data;

    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return AppException(data);
      }
    }

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return AppException(firstError.first.toString());
        }
      }

      if (data['message'] is String) {
        return AppException(data['message'] as String);
      }
    }

    if (error.response == null) {
      return const AppException('Não foi possível conectar à API.');
    }

    return AppException(
      'Erro na API: HTTP ${error.response?.statusCode ?? "desconhecido"}.',
    );
  }
}
