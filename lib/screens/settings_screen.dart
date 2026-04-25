import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/preferences_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/tag_chip.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final preferencesProvider = context.watch<PreferencesProvider>();
    final preferences = preferencesProvider.preferences;

    return Scaffold(
      appBar: AppBar(title: const Text('Instellingen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(auth.email ?? 'Geen e-mail beschikbaar'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget per maaltijd', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Slider(
                    value: preferences.maxBudgetPerMeal.clamp(1, 15).toDouble(),
                    min: 1,
                    max: 15,
                    divisions: 28,
                    label: preferences.maxBudgetPerMeal.toStringAsFixed(2),
                    onChanged: preferencesProvider.setBudget,
                  ),
                  Text('€${preferences.maxBudgetPerMeal.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  Text('Default cooking time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Slider(
                    value: preferences.defaultCookingTime.clamp(5, 60).toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    label: '${preferences.defaultCookingTime} min',
                    onChanged: (value) => preferencesProvider.setCookingTime(value.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dieet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: preferencesProvider.dietaryOptions.map((option) {
                      final selected = preferences.dietaryPreferences.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) {
                          if (option == 'none') {
                            preferencesProvider.setDietaryPreferences(['none']);
                            return;
                          }
                          final updated = [...preferences.dietaryPreferences.where((item) => item != 'none')];
                          if (selected) {
                            updated.remove(option);
                          } else {
                            updated.add(option);
                          }
                          preferencesProvider.setDietaryPreferences(updated.isEmpty ? ['none'] : updated);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Allergieën', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: preferencesProvider.allergyOptions.map((option) {
                      final selected = preferences.allergies.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) {
                          final updated = [...preferences.allergies];
                          if (selected) {
                            updated.remove(option);
                          } else {
                            updated.add(option);
                          }
                          preferencesProvider.setAllergies(updated);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('Notifications inschakelen'),
              subtitle: const Text('Gebruik dit vandaag, bijna vervallen en weekoverzicht'),
              value: preferences.notificationsEnabled,
              onChanged: preferencesProvider.setNotificationsEnabled,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('Dark mode'),
              value: preferences.darkMode,
              onChanged: preferencesProvider.setDarkMode,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const TagChip(label: 'profile'),
                const TagChip(label: 'budgets'),
                const TagChip(label: 'reminders'),
                const TagChip(label: 'food-saving'),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Logout',
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              },
              backgroundColor: Theme.of(context).colorScheme.error,
              icon: Icons.logout_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
