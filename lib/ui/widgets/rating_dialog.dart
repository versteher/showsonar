import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Result from the rating dialog
class RatingResult {
  final double rating;
  final String? notes;

  const RatingResult({required this.rating, this.notes});
}

/// Beautiful rating dialog with star selection and notes
class RatingDialog extends StatefulWidget {
  final String title;
  final double? initialRating;
  final String? initialNotes;
  final String? posterUrl;

  const RatingDialog({
    super.key,
    required this.title,
    this.initialRating,
    this.initialNotes,
    this.posterUrl,
  });

  /// Show the rating dialog and return the result
  static Future<RatingResult?> show(
    BuildContext context, {
    required String title,
    double? initialRating,
    String? initialNotes,
    String? posterUrl,
  }) {
    return showDialog<RatingResult>(
      context: context,
      builder: (ctx) => RatingDialog(
        title: title,
        initialRating: initialRating,
        initialNotes: initialNotes,
        posterUrl: posterUrl,
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating;
  late TextEditingController _notesController;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _showNotes = widget.initialNotes?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with poster
            Row(
              children: [
                if (widget.posterUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Image.network(
                      widget.posterUrl!,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 90,
                        color: AppTheme.surfaceLight,
                        child: const Icon(
                          Icons.movie,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bewertung',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppTheme.spacingLg),

            // Rating display
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: _rating > 0
                    ? AppTheme.getRatingColor(_rating).withValues(alpha: 0.15)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: _rating > 0
                      ? AppTheme.getRatingColor(_rating).withValues(alpha: 0.3)
                      : AppTheme.surfaceBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _rating > 0 ? _rating.toStringAsFixed(1) : '—',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: _rating > 0
                          ? AppTheme.getRatingColor(_rating)
                          : AppTheme.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_rating > 0)
                    Text(
                      _getRatingLabel(_rating),
                      style: TextStyle(
                        color: AppTheme.getRatingColor(_rating),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Star rating row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  final starValue = index + 1;
                  final isFilled = starValue <= _rating;
                  final isHalf = starValue - 0.5 == _rating;

                  return GestureDetector(
                    onTap: () => setState(() => _rating = starValue.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        isFilled
                            ? Icons.star_rounded
                            : isHalf
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                        color: isFilled || isHalf
                            ? AppTheme.getRatingColor(_rating)
                            : AppTheme.textMuted,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Quick rating buttons
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              alignment: WrapAlignment.center,
              children: [
                _QuickRatingButton(
                  emoji: '👎',
                  label: 'Schlecht',
                  rating: 3,
                  currentRating: _rating,
                  onTap: () => setState(() => _rating = 3),
                ),
                _QuickRatingButton(
                  emoji: '😐',
                  label: 'Okay',
                  rating: 5,
                  currentRating: _rating,
                  onTap: () => setState(() => _rating = 5),
                ),
                _QuickRatingButton(
                  emoji: '👍',
                  label: 'Gut',
                  rating: 7,
                  currentRating: _rating,
                  onTap: () => setState(() => _rating = 7),
                ),
                _QuickRatingButton(
                  emoji: '❤️',
                  label: 'Super',
                  rating: 9,
                  currentRating: _rating,
                  onTap: () => setState(() => _rating = 9),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Notes toggle
            GestureDetector(
              onTap: () => setState(() => _showNotes = !_showNotes),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showNotes ? Icons.notes : Icons.add_comment_outlined,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showNotes ? 'Notizen ausblenden' : 'Notizen hinzufügen',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            // Notes field
            if (_showNotes) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Flexible(
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deine Gedanken zum Film/Serie...',
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacingLg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _rating > 0
                        ? () {
                            Navigator.of(context).pop(
                              RatingResult(
                                rating: _rating,
                                notes: _notesController.text.isNotEmpty
                                    ? _notesController.text
                                    : null,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Speichern'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 9) return 'Meisterwerk';
    if (rating >= 8) return 'Großartig';
    if (rating >= 7) return 'Sehr gut';
    if (rating >= 6) return 'Gut';
    if (rating >= 5) return 'Okay';
    if (rating >= 4) return 'Mäßig';
    if (rating >= 3) return 'Schwach';
    if (rating >= 2) return 'Schlecht';
    return 'Katastrophe';
  }
}

class _QuickRatingButton extends StatelessWidget {
  final String emoji;
  final String label;
  final double rating;
  final double currentRating;
  final VoidCallback onTap;

  const _QuickRatingButton({
    required this.emoji,
    required this.label,
    required this.rating,
    required this.currentRating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRating == rating;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getRatingColor(rating).withValues(alpha: 0.2)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppTheme.getRatingColor(rating)
                : AppTheme.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.getRatingColor(rating)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
