import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this.apiClient);

  final ApiClient apiClient;

  Map<String, dynamic> _parseResponse(dynamic data) {
    // O servidor pode devolver JSON como texto ou como Map.
    final decoded = data is String ? jsonDecode(data) : data;

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw const FormatException('Resposta inválida recebida do servidor.');
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return AuthResponse.fromJson(_parseResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } on FormatException catch (e) {
      throw Exception(e.message);
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

      return AuthResponse.fromJson(_parseResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } on FormatException catch (e) {
      throw Exception(e.message);
    }
  }

  String _getErrorMessage(DioException error) {
    dynamic data = error.response?.data;

    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return data;
      }
    }

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (error.response == null) {
      return 'Não foi possível conectar ao servidor.';
    }

    return 'Não foi possível realizar o login.';
  }
}

class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}
