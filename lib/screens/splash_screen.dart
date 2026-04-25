import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';
import '../widgets/loading_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (auth.isBootstrapped && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final nextPage = auth.isAuthenticated ? const MainNavigationScreen() : const OnboardingScreen();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => nextPage));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('KotKok AI', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Text('Kook slim. Verspil minder. Bespaar geld.'),
            SizedBox(height: 28),
            LoadingView(message: 'Je koelkast wordt gecheckt...'),
          ],
        ),
      ),
    );
  }
}
