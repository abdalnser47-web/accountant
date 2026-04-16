import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// عناصر مؤقتة لمنع أخطاء التجميع في المرحلة الأولى
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
class _LoginScreen extends StatelessWidget {
  const _LoginScreen();
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Screen')));
}
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home Screen')));
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const _LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const _HomeScreen()),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.path}')),
  ),
);
