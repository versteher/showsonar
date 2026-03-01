import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/data/models/direct_recommendation.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/repositories/social_repository.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  final currentUid = ref.watch(authStateProvider).value?.uid;
  if (currentUid == null) throw Exception('User not logged in');

  final socialRepo = SocialRepository(currentUid: currentUid);

  return RecommendationRepository(
    FirebaseFirestore.instance,
    currentUid,
    socialRepo,
  );
});

class RecommendationRepository {
  final FirebaseFirestore _firestore;
  final String _currentUid;
  final SocialRepository _socialRepository;

  RecommendationRepository(
    this._firestore,
    this._currentUid,
    this._socialRepository,
  );

  /// Streams the incoming recommendations for the current user.
  /// Also fetches the sender profiles.
  Stream<List<DirectRecommendation>> getIncomingRecommendations() {
    return _firestore
        .collection('recommendations')
        .where('receiverId', isEqualTo: _currentUid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
          final recommendations = <DirectRecommendation>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;

            var recommendation = DirectRecommendation.fromJson(data);

            // Fetch sender profile
            final senderProfile = await _socialRepository.getUserProfile(
              recommendation.senderId,
            );
            if (senderProfile != null) {
              recommendation = recommendation.copyWith(
                senderProfile: senderProfile,
              );
            }

            recommendations.add(recommendation);
          }

          return recommendations;
        });
  }

  /// Sends a recommendation to a friend.
  Future<void> sendRecommendation(String receiverId, Media media) async {
    final docRef = _firestore.collection('recommendations').doc();

    final recommendation = DirectRecommendation(
      id: docRef.id,
      senderId: _currentUid,
      receiverId: receiverId,
      mediaId: media.id,
      mediaTitle: media.title,
      mediaPosterPath: media.posterPath,
      mediaType: media.type.name,
      timestamp: DateTime.now(),
    );

    await docRef.set(recommendation.toJson());
  }
}

final incomingRecommendationsProvider =
    StreamProvider.autoDispose<List<DirectRecommendation>>((ref) {
      final repo = ref.watch(recommendationRepositoryProvider);
      return repo.getIncomingRecommendations();
    });
