import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import 'package:stream_scout/utils/app_haptics.dart';
import '../../config/providers.dart';
import '../../domain/viewing_context.dart';
import '../theme/app_theme.dart';

/// Horizontal chip bar for switching the viewing context.
/// Tapping a chip updates [viewingContextProvider], which auto-rebuilds
/// all content sections on the home screen.
class ViewingContextChipBar extends ConsumerWidget {
  const ViewingContextChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(viewingContextProvider);
    final l10n = AppLocalizations.of(context)!;

    final chips = [
      _ChipData(ViewingContext.all, l10n.viewingContextAll, Icons.apps_rounded),
      _ChipData(
        ViewingContext.kids,
        l10n.viewingContextKids,
        Icons.child_care_rounded,
      ),
      _ChipData(
        ViewingContext.dateNight,
        l10n.viewingContextDateNight,
        Icons.favorite_rounded,
      ),
      _ChipData(
        ViewingContext.solo,
        l10n.viewingContextSolo,
        Icons.person_rounded,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isActive = active == chip.context;
          return _ContextChip(
            label: chip.label,
            icon: chip.icon,
            isActive: isActive,
            onTap: () {
              AppHaptics.lightImpact();
              ref
                  .read(viewingContextProvider.notifier)
                  .updateContext(chip.context);
            },
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ChipData {
  final ViewingContext context;
  final String label;
  final IconData icon;
  const _ChipData(this.context, this.label, this.icon);
}

class _ContextChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ContextChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: isActive ? null : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppTheme.surfaceBorder,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
