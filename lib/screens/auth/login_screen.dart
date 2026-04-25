import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailController.text.trim(), _passwordController.text.trim());
    if (!mounted || !ok) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigationScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('Welkom terug', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Log in om je koelkast slim te redden.'),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Wachtwoord',
                  controller: _passwordController,
                  validator: Validators.password,
                  obscureText: true,
                  prefixIcon: Icons.lock_rounded,
                ),
                const SizedBox(height: 20),
                if (auth.errorMessage != null) ...[
                  Text(auth.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 12),
                ],
                AppButton(label: 'Login', onPressed: _login, isLoading: auth.isLoading, icon: Icons.login_rounded),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Nog geen account? Registreer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
