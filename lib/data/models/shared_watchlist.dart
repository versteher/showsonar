import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_watchlist.freezed.dart';
part 'shared_watchlist.g.dart';

@freezed
class SharedWatchlist with _$SharedWatchlist {
  const factory SharedWatchlist({
    required String id,
    required String ownerId,
    required String name,
    @Default([]) List<String> sharedWithUids,
    @Default([]) List<String> mediaIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SharedWatchlist;

  factory SharedWatchlist.fromJson(Map<String, dynamic> json) =>
      _$SharedWatchlistFromJson(json);
}
