import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TasteProfileImportSection extends StatelessWidget {
  final bool isImporting;
  final String? importError;
  final void Function(String json) onImport;

  const TasteProfileImportSection({
    super.key,
    required this.isImporting,
    required this.importError,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
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
            if (importError != null) ...[
              const SizedBox(height: 8),
              Text(
                importError!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton.icon(
              onPressed: isImporting
                  ? null
                  : () => onImport(importController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
              ),
              icon: isImporting
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
                isImporting
                    ? 'Importiere...'
                    : 'Profil importieren & vergleichen',
              ),
            ),
          ],
        );
      },
    );
  }
}
