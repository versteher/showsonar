import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../../data/services/taste_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import 'taste_profile_stats_card.dart';
import 'taste_profile_export_section.dart';
import 'taste_profile_import_section.dart';

// ============================================================================
// Provider
// ============================================================================

final tasteProfileServiceProvider = Provider<TasteProfileService>((ref) {
  final repo = ref.watch(watchHistoryRepositoryProvider);
  return TasteProfileService(repo);
});

// ============================================================================
// Screen
// ============================================================================

/// Full-screen taste profile management screen
class TasteProfileScreen extends ConsumerStatefulWidget {
  const TasteProfileScreen({super.key});

  @override
  ConsumerState<TasteProfileScreen> createState() => _TasteProfileScreenState();
}

class _TasteProfileScreenState extends ConsumerState<TasteProfileScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _exportedJson;
  String? _importError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                ),
                onPressed: () => context.pop(),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Taste Profil'),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TasteProfileStatsCard(),
                    const SizedBox(height: AppTheme.spacingXl),
                    TasteProfileExportSection(
                      isExporting: _isExporting,
                      exportedJson: _exportedJson,
                      onExport: _doExport,
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                    TasteProfileImportSection(
                      isImporting: _isImporting,
                      importError: _importError,
                      onImport: _doImport,
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doExport() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();
      final svc = ref.read(tasteProfileServiceProvider);
      final json = await svc.export();
      setState(() {
        _exportedJson = json;
        _isExporting = false;
      });
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        AppSnackBar.showError(context, 'Export fehlgeschlagen: $e');
      }
    }
  }

  Future<void> _doImport(String json) async {
    if (json.trim().isEmpty) {
      setState(() => _importError = 'Bitte JSON einfügen');
      return;
    }

    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      final repo = ref.read(watchHistoryRepositoryProvider);
      await repo.init();
      final svc = ref.read(tasteProfileServiceProvider);

      // Preview first
      final profile = svc.preview(json);
      if (profile == null) {
        setState(() {
          _isImporting = false;
          _importError = 'Ungültiges Profil-Format';
        });
        return;
      }

      // Compute overlap before import
      final overlap = await svc.computeOverlap(profile);
      final overlapPercent = (overlap * 100).round();

      if (!mounted) return;

      // Show comparison dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Profil gefunden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profile.stats['totalWatched'] ?? 0} Titel gesehen, '
                '${profile.stats['totalRated'] ?? 0} bewertet.',
              ),
              const SizedBox(height: 16),
              // Taste overlap meter
              Row(
                children: [
                  const Text(
                    'Übereinstimmung: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$overlapPercent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: overlapPercent > 30
                          ? AppTheme.success
                          : overlapPercent > 10
                          ? AppTheme.warning
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: overlap.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.surfaceLight,
                  color: overlapPercent > 30
                      ? AppTheme.success
                      : overlapPercent > 10
                      ? AppTheme.warning
                      : AppTheme.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overlapPercent > 30
                    ? '🎉 Ihr habt sehr ähnlichen Geschmack!'
                    : overlapPercent > 10
                    ? '🤝 Einiger gemeinsamer Geschmack'
                    : '🔍 Viel Neues zu entdecken!',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              const Text(
                'Neue Titel aus diesem Profil werden zu deiner Bibliothek hinzugefügt.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Importieren'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        setState(() => _isImporting = false);
        return;
      }

      final result = await svc.import(json);
      ref.invalidate(watchHistoryEntriesProvider);

      setState(() => _isImporting = false);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          '${result.imported} neue Titel importiert, '
          '${result.skipped} übersprungen.',
          icon: Icons.download_done_rounded,
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _importError = 'Fehler: $e';
      });
    }
  }
}
