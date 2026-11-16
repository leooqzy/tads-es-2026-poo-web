import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/session_repository.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';

class FFRentalApp extends StatefulWidget {
  const FFRentalApp({super.key});

  @override
  State<FFRentalApp> createState() => _FFRentalAppState();
}

class _FFRentalAppState extends State<FFRentalApp> {
  late final AuthService _authService;
  late final ProductService _productService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    const storage = FlutterSecureStorage();

    final apiClient = ApiClient(storage: storage);

    _authService = AuthService(
      authRepository: AuthRepository(apiClient),
      sessionRepository: SessionRepository(storage: storage),
    );

    _productService = ProductService(ProductRepository(apiClient));

    _router = AppRouter.create(
      authService: _authService,
      productService: _productService,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
