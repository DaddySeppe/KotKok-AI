import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    this.userId,
    this.fullName,
    this.email,
    this.errorMessage,
  });

  final bool success;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? errorMessage;
}

class AuthBootstrapResult {
  const AuthBootstrapResult({
    required this.isAuthenticated,
    this.userId,
    this.fullName,
    this.email,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? fullName;
  final String? email;
}

class AuthService {
  static const _prefLoggedIn = 'kotkok_logged_in';
  static const _prefUserId = 'kotkok_user_id';
  static const _prefFullName = 'kotkok_full_name';
  static const _prefEmail = 'kotkok_email';

  Future<AuthBootstrapResult> bootstrap() async {
    if (SupabaseConfig.isConfigured) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        return AuthBootstrapResult(
          isAuthenticated: true,
          userId: user.id,
          fullName: user.userMetadata?['full_name']?.toString() ?? user.email?.split('@').first,
          email: user.email,
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_prefLoggedIn) ?? false;
    if (!loggedIn) {
      return const AuthBootstrapResult(isAuthenticated: false);
    }

    return AuthBootstrapResult(
      isAuthenticated: true,
      userId: prefs.getString(_prefUserId),
      fullName: prefs.getString(_prefFullName),
      email: prefs.getString(_prefEmail),
    );
  }

  Future<AuthResult> signIn({required String email, required String password}) async {
    try {
      if (SupabaseConfig.isConfigured) {
        final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        if (response.user == null) {
          return const AuthResult(success: false, errorMessage: 'Kon niet inloggen.');
        }
        await _persistLocalSession(response.user!.id, response.user?.userMetadata?['full_name']?.toString() ?? email.split('@').first, email);
        return AuthResult(success: true, userId: response.user!.id, fullName: response.user?.userMetadata?['full_name']?.toString(), email: response.user?.email);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefLoggedIn, true);
      await prefs.setString(_prefUserId, prefs.getString(_prefUserId) ?? const Uuid().v4());
      await prefs.setString(_prefFullName, prefs.getString(_prefFullName) ?? email.split('@').first);
      await prefs.setString(_prefEmail, email);
      return AuthResult(success: true, userId: prefs.getString(_prefUserId), fullName: prefs.getString(_prefFullName), email: email);
    } catch (error) {
      return AuthResult(success: false, errorMessage: error.toString());
    }
  }

  Future<AuthResult> signUp({required String fullName, required String email, required String password}) async {
    try {
      if (SupabaseConfig.isConfigured) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );

        if (response.user == null) {
          return const AuthResult(success: false, errorMessage: 'Registratie mislukt.');
        }

        await Supabase.instance.client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
        });

        await _persistLocalSession(response.user!.id, fullName, email);
        return AuthResult(success: true, userId: response.user!.id, fullName: fullName, email: email);
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = const Uuid().v4();
      await prefs.setBool(_prefLoggedIn, true);
      await prefs.setString(_prefUserId, userId);
      await prefs.setString(_prefFullName, fullName);
      await prefs.setString(_prefEmail, email);
      return AuthResult(success: true, userId: userId, fullName: fullName, email: email);
    } catch (error) {
      return AuthResult(success: false, errorMessage: error.toString());
    }
  }

  Future<void> signOut() async {
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLoggedIn, false);
  }

  Future<void> _persistLocalSession(String userId, String fullName, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLoggedIn, true);
    await prefs.setString(_prefUserId, userId);
    await prefs.setString(_prefFullName, fullName);
    await prefs.setString(_prefEmail, email);
  }
}
