import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _fullNameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted || !ok) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigationScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registreer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: 'Volledige naam', controller: _fullNameController, validator: (value) => Validators.requiredField(value, label: 'Naam'), prefixIcon: Icons.person_rounded),
                const SizedBox(height: 14),
                AppTextField(label: 'E-mail', controller: _emailController, validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_rounded),
                const SizedBox(height: 14),
                AppTextField(label: 'Wachtwoord', controller: _passwordController, validator: Validators.password, obscureText: true, prefixIcon: Icons.lock_rounded),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Bevestig wachtwoord',
                  controller: _confirmController,
                  validator: (value) {
                    if (value != _passwordController.text.trim()) return 'Wachtwoorden komen niet overeen.';
                    return Validators.password(value);
                  },
                  obscureText: true,
                  prefixIcon: Icons.lock_reset_rounded,
                ),
                const SizedBox(height: 20),
                if (auth.errorMessage != null) ...[
                  Text(auth.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 12),
                ],
                AppButton(label: 'Register', onPressed: _register, isLoading: auth.isLoading, icon: Icons.person_add_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
