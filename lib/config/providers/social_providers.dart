import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/social_repository.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/activity_feed_item.dart';
import '../providers.dart';
import '../firebase_fallback.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return SocialRepository(
    currentUid: user?.uid ?? 'guest',
    firestore: firestoreInstance,
  );
});

final userSearchQueryProvider = StateProvider<String>((ref) => '');

final userSearchResultsProvider = FutureProvider<List<UserProfile>>((
  ref,
) async {
  final query = ref.watch(userSearchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(socialRepositoryProvider);
  return repo.searchUsers(query);
});

final followingListProvider = FutureProvider<List<UserProfile>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getFollowing();
});

final activityFeedProvider = StreamProvider<List<ActivityFeedItem>>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getActivityFeed();
});

final isFollowingProvider = StreamProvider.family<bool, String>((
  ref,
  targetUid,
) {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.isFollowing(targetUid);
});

final userProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  uid,
) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getUserProfile(uid);
});
