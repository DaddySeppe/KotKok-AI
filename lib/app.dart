import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/fridge_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/splash_screen.dart';
import 'config/app_theme.dart';

class KotKokApp extends StatelessWidget {
  const KotKokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => FridgeProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => StatsProvider()..bootstrap()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, preferences, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'KotKok AI',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: preferences.preferences.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
