import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/admin_dashboard_screen.dart';
import '../../screens/home/catalog_screen.dart';
import '../../screens/home/seller_dashboard_screen.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import 'route_names.dart';

class AppRouter {
  static GoRouter create({
    required AuthService authService,
    required ProductService productService,
  }) {
    return GoRouter(
      initialLocation: '/login',

      redirect: (context, state) async {
        final user = await authService.getCurrentUser();
        final path = state.matchedLocation;

        final isAuthPage = path == '/login' || path == '/register';

        if (user == null) {
          return isAuthPage ? null : '/login';
        }

        final destination = user.isAdmin
            ? '/admin'
            : user.isSeller
            ? '/seller'
            : '/catalog';

        if (isAuthPage) {
          return destination;
        }

        if (path == '/admin' && !user.isAdmin) {
          return destination;
        }

        if (path == '/seller' && !user.isSeller) {
          return destination;
        }

        if (path == '/catalog' && !user.isBuyer) {
          return destination;
        }

        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) {
            return LoginScreen(authService: authService);
          },
        ),
        GoRoute(
          path: '/register',
          name: RouteNames.register,
          builder: (context, state) {
            return RegisterScreen(authService: authService);
          },
        ),
        GoRoute(
          path: '/admin',
          name: RouteNames.adminDashboard,
          builder: (context, state) {
            return _AuthenticatedPage(
              authService: authService,
              user: state.extra is User ? state.extra as User : null,
              builder: (user) =>
                  AdminDashboardScreen(user: user, authService: authService),
            );
          },
        ),
        GoRoute(
          path: '/seller',
          name: RouteNames.sellerDashboard,
          builder: (context, state) {
            return _AuthenticatedPage(
              authService: authService,
              user: state.extra is User ? state.extra as User : null,
              builder: (user) => SellerDashboardScreen(
                user: user,
                authService: authService,
                productService: productService,
              ),
            );
          },
        ),
        GoRoute(
          path: '/catalog',
          name: RouteNames.catalog,
          builder: (context, state) {
            return _AuthenticatedPage(
              authService: authService,
              user: state.extra is User ? state.extra as User : null,
              builder: (user) => CatalogScreen(
                user: user,
                authService: authService,
                productService: productService,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AuthenticatedPage extends StatelessWidget {
  const _AuthenticatedPage({
    required this.authService,
    required this.builder,
    this.user,
  });

  final AuthService authService;
  final User? user;
  final Widget Function(User user) builder;

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return builder(user!);
    }

    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = snapshot.data;

        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Não foi possível recuperar sua sessão.')),
          );
        }

        return builder(currentUser);
      },
    );
  }
}
