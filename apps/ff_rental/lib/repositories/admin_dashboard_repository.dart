import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/utils/app_exception.dart';
import '../models/admin_dashboard.dart';

class AdminDashboardRepository {
  AdminDashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AdminDashboard> getDashboard() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard');

      if (response.data is! Map) {
        throw const AppException('Resposta inválida do painel administrativo.');
      }

      return AdminDashboard.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] is String) {
        throw AppException(data['message'] as String);
      }

      if (error.response == null) {
        throw const AppException('Não foi possível conectar à API.');
      }

      throw const AppException(
        'Não foi possível carregar o painel administrativo.',
      );
    }
  }
}
