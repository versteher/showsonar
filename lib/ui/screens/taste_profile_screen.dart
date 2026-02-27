import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../../data/services/taste_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';

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
                    _buildStatsCard(),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildExportSection(),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildImportSection(),
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

  Widget _buildStatsCard() {
    final entriesAsync = ref.watch(watchHistoryEntriesProvider);
    List<WatchHistoryStats> stats = [];

    try {
      final entries = entriesAsync.valueOrNull ?? [];
      final rated = entries.where((e) => e.isRated).toList();
      final avgRating = rated.isEmpty
          ? 0.0
          : rated.map((e) => e.userRating!).reduce((a, b) => a + b) /
                rated.length;
      stats = [
        WatchHistoryStats(
          icon: '🎬',
          label: 'Gesehen',
          value: '${entries.length}',
        ),
        WatchHistoryStats(
          icon: '⭐',
          label: 'Bewertet',
          value: '${rated.length}',
        ),
        WatchHistoryStats(
          icon: '📊',
          label: 'Ø Bewertung',
          value: rated.isEmpty ? '—' : avgRating.toStringAsFixed(1),
        ),
      ];
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.15),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dein Filmprofil',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: stats
                .map(
                  (s) => Expanded(
                    child: Column(
                      children: [
                        Text(s.icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          s.value,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📤 Profil teilen',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Exportiere dein Sehprofil als JSON-Code und teile ihn mit Freunden.',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _doExport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_rounded),
                label: Text(
                  _isExporting ? 'Exportiere...' : 'Profil exportieren',
                ),
              ),
            ),
          ],
        ),
        if (_exportedJson != null) ...[
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Export bereit',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: AppTheme.success),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _exportedJson!));
                        AppSnackBar.showSuccess(
                          context,
                          'JSON in die Zwischenablage kopiert',
                          icon: Icons.copy_rounded,
                        );
                      },
                      tooltip: 'Kopieren',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      // Show first 500 chars preview
                      _exportedJson!.length > 500
                          ? '${_exportedJson!.substring(0, 500)}...'
                          : _exportedJson!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImportSection() {
    final importController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📥 Freund-Profil importieren',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Füge den JSON-Code deines Freundes ein, um Geschmack zu vergleichen und neue Ideen zu entdecken.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: importController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '{\n  "version": 1,\n  "entries": [...]\n}',
                hintStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            if (_importError != null) ...[
              const SizedBox(height: 8),
              Text(
                _importError!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton.icon(
              onPressed: _isImporting
                  ? null
                  : () => _doImport(importController.text, setLocalState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
              ),
              icon: _isImporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                _isImporting
                    ? 'Importiere...'
                    : 'Profil importieren & vergleichen',
              ),
            ),
          ],
        );
      },
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

  Future<void> _doImport(String json, StateSetter setLocalState) async {
    if (json.trim().isEmpty) {
      setLocalState(() => _importError = 'Bitte JSON einfügen');
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

class WatchHistoryStats {
  final String icon;
  final String label;
  final String value;
  WatchHistoryStats({
    required this.icon,
    required this.label,
    required this.value,
  });
}
