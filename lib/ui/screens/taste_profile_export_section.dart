import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';

class TasteProfileExportSection extends StatelessWidget {
  final bool isExporting;
  final String? exportedJson;
  final VoidCallback onExport;

  const TasteProfileExportSection({
    super.key,
    required this.isExporting,
    required this.exportedJson,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: isExporting ? null : onExport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                icon: isExporting
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
                  isExporting ? 'Exportiere...' : 'Profil exportieren',
                ),
              ),
            ),
          ],
        ),
        if (exportedJson != null) ...[
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
                        Clipboard.setData(ClipboardData(text: exportedJson!));
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
                      exportedJson!.length > 500
                          ? '${exportedJson!.substring(0, 500)}...'
                          : exportedJson!,
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
}
