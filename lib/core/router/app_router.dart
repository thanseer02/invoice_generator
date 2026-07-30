import 'package:go_router/go_router.dart';
import '../../presentation/home_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../providers/auth_provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      if (authProvider.isLoading) return null;
      
      final bool loggedIn = authProvider.isAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
  );
}
