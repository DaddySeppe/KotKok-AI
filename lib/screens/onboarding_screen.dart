import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_card.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Voeg toe wat je hebt', 'Stop je koelkast en kast in de app zodat KotKok AI slim kan rekenen.', Icons.kitchen_rounded),
      ('Kook wat bijna vervalt', 'Prioriteit gaat naar ingrediënten die vandaag of morgen op moeten.', Icons.timer_rounded),
      ('Bespaar geld en verspil minder', 'Je ziet meteen wat je redt, wat je bespaart en wat je nog nodig hebt.', Icons.savings_rounded),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(AppConstants.slogan, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return DashboardCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                            child: Icon(card.$3, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(card.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(card.$2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Start met redden',
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Ik heb al een account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
