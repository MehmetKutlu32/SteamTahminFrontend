import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/auth/welcome_auth_screen.dart';
import 'screens/main_menu_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/update_service.dart';
import 'theme/steam_theme.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HttpOverrides.global = DevHttpOverrides();
  }
  runApp(const GameGuessApp());
}

class GameGuessApp extends StatelessWidget {
  const GameGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService()..loadSavedUser(),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (context) => GameProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<UpdateService>(
          create: (_) => UpdateService(),
        ),
      ],
      child: MaterialApp(
        title: 'İncelemelerden Oyunu Tahmin Et',
        debugShowCheckedModeBanner: false,
        theme: SteamTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initAuth();
  }

  Future<void> _initAuth() async {
    final authService = context.read<AuthService>();
    final gameProvider = context.read<GameProvider>();
    final user = await authService.loadSavedUser();
    await gameProvider.initializeForUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C121B),
            body: Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            ),
          );
        }
        final authService = context.read<AuthService>();
        if (authService.currentUser != null) {
          return const MainMenuScreen();
        }
        return const WelcomeAuthScreen();
      },
    );
  }
}
