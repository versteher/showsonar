import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/notification_service.dart';
import '../providers.dart';

/// Provider for the NotificationService.
/// It instantiates the service and listens to the user authentication state,
/// keeping the device's FCM token matched with the currently signed-in user.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();

  // When the user logs in/out, update the ID on the NotificationService so it saving the FCM token
  ref.listen(authStateProvider, (previous, next) {
    service.updateUserId(next.value?.uid);
  });

  // Also pass the initial user (if already loaded) since the provider might
  // be instantiated after auth is resolved.
  final currentUser = ref.read(authStateProvider).value;
  service.updateUserId(currentUser?.uid);

  return service;
});
