import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_voyager/config/providers/profile_providers.dart';
import 'package:neon_voyager/ui/theme/app_theme.dart';

/// Modal bottom sheet for creating a new family sub-profile.
class AddProfileSheet extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const AddProfileSheet({super.key, required this.onCreated});

  @override
  ConsumerState<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<AddProfileSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🎬';
  bool _saving = false;

  static const _emojis = [
    '🎬',
    '🍿',
    '👦',
    '👧',
    '🧑',
    '👩',
    '👨',
    '👴',
    '👵',
    '🦸',
    '🧙',
    '🤖',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('New Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacingMd),

          // Emoji picker
          Text(
            'Choose an avatar',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emojis.map((e) {
              final selected = e == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.primaryGradient : null,
                    color: selected ? null : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Profile name',
              hintText: 'e.g. Kids, Partner, Alex',
              prefixText: '$_selectedEmoji  ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .createProfile(name: name, avatarEmoji: _selectedEmoji);
      widget.onCreated();
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
