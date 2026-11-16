import 'dart:convert';

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

      final rawData = response.data;
      final decoded = rawData is String ? jsonDecode(rawData) : rawData;

      if (decoded is! Map) {
        throw const AppException('Resposta inválida do painel administrativo.');
      }

      return AdminDashboard.fromJson(Map<String, dynamic>.from(decoded));
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] is String) {
        throw AppException(data['message'] as String);
      }

      if (error.response == null) {
        throw const AppException('Não foi possível conectar à API.');
      }

      throw AppException(
        'Erro ao carregar painel: HTTP ${error.response?.statusCode}.',
      );
    } on FormatException {
      throw const AppException('A API retornou dados inválidos para o painel.');
    }
  }
}
