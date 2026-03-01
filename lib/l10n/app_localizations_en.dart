// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get apiKeyMissingTitle => 'API Key Missing';

  @override
  String get apiKeyMissingBody =>
      'Please add your TMDB API key to the .env file:\n\nTMDB_API_KEY=your_key';

  @override
  String get apiKeyMissingFooter =>
      'You can get a free API key at\nthemoviedb.org';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navAi => 'AI';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMyList => 'My List';

  @override
  String get navMore => 'More';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get tabWatchlist => 'Watchlist';

  @override
  String get tabHistory => 'History';

  @override
  String get sectionTrending => '🔥 Trending Now';

  @override
  String get sectionUpcoming => '🆕 Coming Soon';

  @override
  String get sectionPopularMovies => '🎬 Popular Movies';

  @override
  String get sectionPopularTv => '📺 Popular TV';

  @override
  String get sectionTopRated => '⭐ Top Rated';

  @override
  String get sectionDiscover => '🎯 Discover';

  @override
  String get sectionContinueWatching => '▶️ Continue Watching';

  @override
  String get sectionWeeklyRecap => '📅 Weekly Recap';

  @override
  String get sectionMoodDiscovery => '🎭 Mood Discovery';

  @override
  String get actionAddToWatchlist => 'Add to Watchlist';

  @override
  String actionAddedToWatchlist(String title) {
    return '$title added to watchlist';
  }

  @override
  String get actionMarkSeen => 'Mark as Seen';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSettings => 'Settings';

  @override
  String errorLoadingTitle(String title) {
    return 'Could not load $title';
  }

  @override
  String get errorLoadingUpcoming => 'Could not load upcoming items';

  @override
  String get recapTitle => 'Weekly Recap';

  @override
  String recapDays(int count) {
    return '$count days';
  }

  @override
  String get recapWatched => 'Watched';

  @override
  String get recapHours => 'Hours';

  @override
  String get recapRating => 'Ø Rating';

  @override
  String get recapTopGenre => 'Top Genre';

  @override
  String get continueWatchingTitle => '▶️ Continue Watching';

  @override
  String continueSeason(int number) {
    return 'Season $number';
  }

  @override
  String continueEpisode(int number) {
    return 'Episode $number';
  }

  @override
  String continueSeasonEpisode(int season, int episode) {
    return 'S$season E$episode';
  }

  @override
  String get continueInProgress => 'In Progress';

  @override
  String get moodTitle => '🎭 What are you in the mood for?';

  @override
  String moodNoResults(String mood) {
    return 'No results for $mood';
  }

  @override
  String get upcomingToday => 'Today!';

  @override
  String get upcomingTomorrow => 'Tomorrow';

  @override
  String upcomingInDays(int days) {
    return 'In $days d';
  }

  @override
  String get mediaWatched => 'Watched';

  @override
  String get filterStreaming => 'Streaming Services';

  @override
  String get detailRatingUnknown => 'Rating ?';

  @override
  String detailAge(int age) {
    return 'AGE $age';
  }

  @override
  String detailWatchlistRemoved(String title) {
    return '$title removed from watchlist';
  }

  @override
  String detailWatchlistAdded(String title) {
    return '$title added to watchlist';
  }

  @override
  String get detailChangeRating => 'Change Rating';

  @override
  String get detailMarkWatched => 'Mark as Watched';

  @override
  String get detailRemoveHistoryTitle => 'Remove from History?';

  @override
  String detailRemoveHistoryContent(String title) {
    return 'Remove $title from your watch history?';
  }

  @override
  String get detailCancel => 'Cancel';

  @override
  String get detailRemove => 'Remove';

  @override
  String detailHistoryRemoved(String title) {
    return '$title removed from watch history';
  }

  @override
  String get detailMyRating => 'My Rating';

  @override
  String get detailRateNow => 'Rate Now';

  @override
  String get detailPlot => 'Plot';

  @override
  String get detailGenres => 'Genres';

  @override
  String get detailSimilarMovies => 'Similar Movies';

  @override
  String get detailSimilarShows => 'Similar Shows';

  @override
  String get detailSimilarContent => 'Similar Content';

  @override
  String detailRated(String title, String rating) {
    return '$title rated: $rating ⭐';
  }

  @override
  String detailWatched(String title, String rating) {
    return '$title marked as watched: $rating ⭐';
  }

  @override
  String get searchListening => 'Listening...';

  @override
  String get searchHint => 'Search movies and shows...';

  @override
  String get searchEmptyTitle => 'Search for movies and shows';

  @override
  String get searchEmptySubtitle => 'Type at least 2 characters';

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchNoResultsSubtitle => 'Try another search term';

  @override
  String get searchErrorTitle => 'Search Error';

  @override
  String get searchRetry => 'Retry';

  @override
  String get streamingAvailable => 'Available on';

  @override
  String streamingNotAvailable(String country) {
    return 'Not available in $country';
  }

  @override
  String get streamingError => 'Error loading streaming data';

  @override
  String get streamingYourServices => 'Your Services';

  @override
  String get streamingRentYours => 'Rent (Your Services)';

  @override
  String get streamingBuyYours => 'Buy (Your Services)';

  @override
  String get streamingMoreOptions => 'More Options';

  @override
  String get streamingStreaming => 'Streaming';

  @override
  String get streamingRent => 'Rent';

  @override
  String get streamingBuy => 'Buy';

  @override
  String get streamingShowLess => 'Show less';

  @override
  String get streamingShowMore => 'Show more';

  @override
  String get streamingPoweredBy => 'Powered by JustWatch';

  @override
  String get streamingNotOnYours => 'Not available on your services';

  @override
  String get streamingNoData => 'No streaming data available';

  @override
  String streamingOthers(int count) {
    return '$count others';
  }

  @override
  String get streamingDisclaimer =>
      'Streaming data provided by TMDB and may not be up to date.';

  @override
  String get streamingSubscription => '✓ Your Sub';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsStreamingTitle => 'My Streaming Services';

  @override
  String get settingsStreamingSubtitle => 'Tap to toggle';

  @override
  String get settingsCountry => 'Country';

  @override
  String get settingsReset => 'Reset';

  @override
  String get settingsResetTitle => 'Reset Settings';

  @override
  String get settingsResetSubtitle => 'Reset all settings to default';

  @override
  String get settingsResetConfirm => 'Reset?';

  @override
  String get settingsResetMessage =>
      'All settings will be reset to default values.';

  @override
  String get settingsApi => 'API Configuration';

  @override
  String get settingsApiInfo => 'Movie data provided by TMDB.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get settingsDescription =>
      'Smart recommendations based on your taste.';

  @override
  String settingsRemoved(String service) {
    return '$service removed';
  }

  @override
  String settingsAdded(String service) {
    return '$service added';
  }

  @override
  String get settingsSelectCountry => 'Select Country';

  @override
  String get settingsChangeCountry => 'Tap to change';

  @override
  String settingsCountryChanged(String country) {
    return 'Country changed to $country';
  }

  @override
  String get errorRetry => 'Retry';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get myListTitle => 'My List';

  @override
  String get statMovies => 'Movies';

  @override
  String get statSeries => 'Series';

  @override
  String get statAvgRating => 'Ø Rating';

  @override
  String get statRated => 'Rated';

  @override
  String get sortDate => 'Date';

  @override
  String get sortMyRating => 'My Rating';

  @override
  String get sortImdbRating => 'IMDB Rating';

  @override
  String get sortTitle => 'Title';

  @override
  String get filterAll => 'All';

  @override
  String get filterMovies => 'Movies';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterRated => 'Rated';

  @override
  String get emptyHistory => 'Nothing watched yet';

  @override
  String get emptyHistorySubtitle =>
      'Mark movies and shows as watched to see them here';

  @override
  String get emptyFilter => 'No results for these filters';

  @override
  String get emptyFilterSubtitle => 'Change filters to see more';

  @override
  String get deleteEntry => 'Delete Entry?';

  @override
  String deleteEntryMessage(String title) {
    return 'Remove $title from your list?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String entryRemoved(String title) {
    return '$title removed';
  }

  @override
  String entryRated(String title, String rating) {
    return '$title rated: $rating ⭐';
  }

  @override
  String get watchlistError => 'Error loading watchlist';

  @override
  String get watchlistEmpty => 'Watchlist empty';

  @override
  String get watchlistEmptySubtitle =>
      'Tap the bookmark icon to save movies and shows here.';

  @override
  String watchlistAddedAgo(String ago) {
    return 'Added $ago';
  }

  @override
  String timeAgoYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoJustNow => 'just now';

  @override
  String get mediaTypeMovie => 'Movie';

  @override
  String get mediaTypeTv => 'TV Series';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityLow => 'Low';

  @override
  String semanticPosterOf(String title) {
    return 'Poster of $title';
  }

  @override
  String semanticBackdropOf(String title) {
    return 'Backdrop image of $title';
  }

  @override
  String semanticMediaCard(String title, String type, String rating) {
    return '$title, $type, rated $rating';
  }

  @override
  String semanticNavSelected(String label) {
    return '$label, selected';
  }

  @override
  String get semanticVoiceSearch => 'Voice search';

  @override
  String get semanticVoiceSearchActive => 'Voice search, listening';

  @override
  String get semanticFilterButton => 'Filter results';

  @override
  String semanticProviderLogo(String provider) {
    return '$provider logo';
  }

  @override
  String semanticRatingBadge(String rating) {
    return 'Rating $rating out of 10';
  }

  @override
  String semanticWatchlistAdd(String title) {
    return 'Add $title to watchlist';
  }

  @override
  String semanticWatchlistRemove(String title) {
    return 'Remove $title from watchlist';
  }

  @override
  String semanticMarkWatched(String title) {
    return 'Mark $title as watched';
  }

  @override
  String semanticChangeRating(String title) {
    return 'Change rating for $title';
  }

  @override
  String semanticDeleteFromHistory(String title) {
    return 'Delete $title from history';
  }

  @override
  String semanticTrendingCard(String title) {
    return 'Trending: $title';
  }

  @override
  String semanticPageDot(int number, int total) {
    return 'Page $number of $total';
  }

  @override
  String get semanticBackButton => 'Go back';

  @override
  String semanticRateNow(String title) {
    return '$title';
  }

  @override
  String get detailEmptyState => 'Select a movie or series to view details';

  @override
  String get detailTabAbout => 'About';

  @override
  String get detailTabCast => 'Cast';

  @override
  String get detailTabStreaming => 'Where to Watch';

  @override
  String get detailTabSimilar => 'Similar';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsProfiles => '👥 Profiles';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsTasteProfile => '👤 Taste Profile';

  @override
  String get settingsTasteProfileTitle => 'Share & compare profile';

  @override
  String get settingsTasteProfileSubtitle =>
      "Export your watch profile or import a friend's";

  @override
  String get aiSuggestion1Label => "🎬 What's trending?";

  @override
  String get aiSuggestion1Query =>
      'What are the best trending movies and series right now?';

  @override
  String get aiSuggestion2Label => '😂 Something funny';

  @override
  String get aiSuggestion2Query =>
      "Recommend a hilarious comedy that's a must-watch";

  @override
  String get aiSuggestion3Label => '🔥 Thriller like Dark';

  @override
  String get aiSuggestion3Query =>
      "I'm looking for a gripping thriller or mystery series similar to Dark";

  @override
  String get aiSuggestion4Label => '🤔 Something thought-provoking';

  @override
  String get aiSuggestion4Query =>
      'Recommend a film or series that makes you think, profound and emotional';

  @override
  String get aiSuggestion5Label => '👨‍👩‍👧 Family night';

  @override
  String get aiSuggestion5Query =>
      "What can a family watch together? Not too childish but family-friendly";

  @override
  String get aiSuggestion6Label => '🏆 Award-worthy';

  @override
  String get aiSuggestion6Query =>
      "What are the best award-winning films of recent years that are a must-watch?";

  @override
  String get discoverRandomPick => '🎲 Random Pick — Let us decide!';

  @override
  String get aiWelcomeTitle => 'What would you like to watch?';

  @override
  String get aiWelcomeSubtitle =>
      'Ask me for recommendations, moods,\nor specific genres!';

  @override
  String get aiError => '❌ An error occurred. Please try again.';

  @override
  String aiSearchNoResult(String title) => 'No result for "$title"';

  @override
  String get aiSearchFailed => 'Search failed';

  @override
  String get aiChatSubtitle => 'Your personal movie advisor';

  @override
  String get aiPoweredBy => '✨ Powered by Google Gemini';

  @override
  String get aiThinking => 'ShowSonar AI is thinking...';

  @override
  String get aiInputHint => 'Ask me anything...';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCopied => 'Text copied';

  @override
  String get actionShare => 'Share';

  @override
  String get actionCopiedForSharing => 'Copied to clipboard — paste to share';
}
