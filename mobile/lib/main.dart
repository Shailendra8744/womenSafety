import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WomenSecurityApp());
}

class WomenSecurityApp extends StatelessWidget {
  const WomenSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Security',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B2D5C), brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SessionStore.getToken(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final t = snap.data;
        if (t != null && t.isNotEmpty) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
