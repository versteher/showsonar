import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_voyager/ui/screens/onboarding_steps.dart';

class OnboardingTasteStep extends StatelessWidget {
  const OnboardingTasteStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const OnboardingStepHeader(
            title: 'You\'re All Set!',
            subtitle:
                'You can also import an existing taste profile if you exported one from another device.',
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.import_export, size: 32),
              title: const Text('Import Taste Profile'),
              subtitle: const Text(
                'Import your watch history and lists from a JSON file.',
              ),
              onTap: () async {
                final success = await context.push<bool>('/taste-profile');
                if (success == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile imported successfully!'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Or simply skip this step and start discovering!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
