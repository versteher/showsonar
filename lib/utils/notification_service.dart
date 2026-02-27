import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Define the background handler at the top-level as required by `firebase_messaging`
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging? _messaging;
  final FirebaseFirestore? _firestore;
  String? _userId;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  }) : _messaging =
           messaging ??
           ((Firebase.apps.isNotEmpty &&
                   Firebase.app().options.projectId != 'dummy-project-id')
               ? FirebaseMessaging.instance
               : null),
       _firestore =
           firestore ??
           ((Firebase.apps.isNotEmpty &&
                   Firebase.app().options.projectId != 'dummy-project-id')
               ? FirebaseFirestore.instance
               : null) {
    if (_messaging != null) {
      // Register the background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }
  }

  /// Initialize push notifications
  Future<void> initialize() async {
    if (_messaging == null) return;

    // Request permission on iOS/MacOS, no-op mainly on Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');

      // Get the token right away
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification?.title}',
          );
        }

        // In a real app, you might show a local notification or snackbar here
      });

      // Handle notification taps when the app is in the background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message clicked!');
        _handleMessageTap(message);
      });

      // Handle notification taps when the app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Update the current User ID, triggering a token save if they are logged in.
  Future<void> updateUserId(String? userId) async {
    _userId = userId;
    if (_userId != null && _messaging != null) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    if (_userId == null || _firestore == null) return;

    try {
      final userDocRef = _firestore.collection('users').doc(_userId);
      await userDocRef.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
      debugPrint('FCM Token saved to Firestore');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    if (message.data.containsKey('mediaId')) {
      // Typically we would use our GoRouter reference here to navigate to a detail screen.
      // E.g., AppRouter.router.push('/media/${message.data['mediaId']}')
      debugPrint('Navigating to media: ${message.data['mediaId']}');
    }
  }
}
