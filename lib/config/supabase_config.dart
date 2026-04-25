import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured {
    final url = supabaseUrl;
    final anonKey = supabaseAnonKey;
    return url.isNotEmpty &&
        anonKey.isNotEmpty &&
        !url.contains('your_supabase_url_here') &&
        !anonKey.contains('your_supabase_anon_key_here');
  }
}
