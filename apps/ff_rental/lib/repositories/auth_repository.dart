import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this.apiClient);

  final ApiClient apiClient;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
    String? cpf,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      };

      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      if (cpf != null && cpf.isNotEmpty) {
        data['cpf'] = cpf;
      }

      final response = await apiClient.dio.post('/auth/register', data: data);

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return 'Não foi possível conectar ao servidor.';
  }
}

class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
