import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline =
            results.isEmpty ||
            results.every((result) => result == ConnectivityResult.none);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOffline ? 32 : 0,
          width: double.infinity,
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.center,
          child: isOffline
              ? Text(
                  AppLocalizations.of(context)?.noInternetConnection ??
                      'No internet connection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
