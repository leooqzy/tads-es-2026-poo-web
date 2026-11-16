import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

class AuthService {
  AuthService({required this.authRepository, required this.sessionRepository});

  final AuthRepository authRepository;
  final SessionRepository sessionRepository;

  Future<User> login({required String email, required String password}) async {
    final response = await authRepository.login(
      email: email,
      password: password,
    );

    await sessionRepository.saveToken(response.token);
    await sessionRepository.saveUser(response.user);

    return response.user;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
    String? cpf,
  }) async {
    final response = await authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      phone: phone,
      cpf: cpf,
    );

    await sessionRepository.saveToken(response.token);
    await sessionRepository.saveUser(response.user);

    return response.user;
  }

  Future<bool> isAuthenticated() async {
    final token = await sessionRepository.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<User?> getCurrentUser() async {
    final authenticated = await isAuthenticated();

    if (!authenticated) {
      return null;
    }

    return sessionRepository.getUser();
  }

  Future<void> logout() async {
    await sessionRepository.clearSession();
  }
}
