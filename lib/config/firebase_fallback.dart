import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final Object _fallbackFirestore = FakeFirebaseFirestore();

/// Returns the native FirebaseFirestore.instance if Firebase is initialized,
/// otherwise returns a shared FakeFirebaseFirestore instance for offline/dummy ops.
FirebaseFirestore get firestoreInstance => Firebase.apps.isNotEmpty
    ? FirebaseFirestore.instance
    : _fallbackFirestore as FirebaseFirestore;
