import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @apiKeyMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'API Key Missing'**
  String get apiKeyMissingTitle;

  /// No description provided for @apiKeyMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Please add your TMDB API key to the .env file:\n\nTMDB_API_KEY=your_key'**
  String get apiKeyMissingBody;

  /// No description provided for @apiKeyMissingFooter.
  ///
  /// In en, this message translates to:
  /// **'You can get a free API key at\nthemoviedb.org'**
  String get apiKeyMissingFooter;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get navFriends;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMyList.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get navMyList;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @tabWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get tabWatchlist;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @sectionTrending.
  ///
  /// In en, this message translates to:
  /// **'🔥 Trending Now'**
  String get sectionTrending;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'🆕 Coming Soon'**
  String get sectionUpcoming;

  /// No description provided for @sectionPopularMovies.
  ///
  /// In en, this message translates to:
  /// **'🎬 Popular Movies'**
  String get sectionPopularMovies;

  /// No description provided for @sectionPopularTv.
  ///
  /// In en, this message translates to:
  /// **'📺 Popular TV'**
  String get sectionPopularTv;

  /// No description provided for @sectionTopRated.
  ///
  /// In en, this message translates to:
  /// **'⭐ Top Rated'**
  String get sectionTopRated;

  /// No description provided for @sectionDiscover.
  ///
  /// In en, this message translates to:
  /// **'🎯 Discover'**
  String get sectionDiscover;

  /// No description provided for @sectionContinueWatching.
  ///
  /// In en, this message translates to:
  /// **'▶️ Continue Watching'**
  String get sectionContinueWatching;

  /// No description provided for @sectionWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'📅 Weekly Recap'**
  String get sectionWeeklyRecap;

  /// No description provided for @sectionMoodDiscovery.
  ///
  /// In en, this message translates to:
  /// **'🎭 Mood Discovery'**
  String get sectionMoodDiscovery;

  /// No description provided for @actionAddToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Watchlist'**
  String get actionAddToWatchlist;

  /// No description provided for @actionAddedToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'{title} added to watchlist'**
  String actionAddedToWatchlist(String title);

  /// No description provided for @actionMarkSeen.
  ///
  /// In en, this message translates to:
  /// **'Mark as Seen'**
  String get actionMarkSeen;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionSettings;

  /// No description provided for @errorLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load {title}'**
  String errorLoadingTitle(String title);

  /// No description provided for @errorLoadingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Could not load upcoming items'**
  String get errorLoadingUpcoming;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Recap'**
  String get recapTitle;

  /// No description provided for @recapDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String recapDays(int count);

  /// No description provided for @recapWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get recapWatched;

  /// No description provided for @recapHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get recapHours;

  /// No description provided for @recapRating.
  ///
  /// In en, this message translates to:
  /// **'Ø Rating'**
  String get recapRating;

  /// No description provided for @recapTopGenre.
  ///
  /// In en, this message translates to:
  /// **'Top Genre'**
  String get recapTopGenre;

  /// No description provided for @continueWatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'▶️ Continue Watching'**
  String get continueWatchingTitle;

  /// No description provided for @continueSeason.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String continueSeason(int number);

  /// No description provided for @continueEpisode.
  ///
  /// In en, this message translates to:
  /// **'Episode {number}'**
  String continueEpisode(int number);

  /// No description provided for @continueSeasonEpisode.
  ///
  /// In en, this message translates to:
  /// **'S{season} E{episode}'**
  String continueSeasonEpisode(int season, int episode);

  /// No description provided for @continueInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get continueInProgress;

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'🎭 What are you in the mood for?'**
  String get moodTitle;

  /// No description provided for @moodNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for {mood}'**
  String moodNoResults(String mood);

  /// No description provided for @upcomingToday.
  ///
  /// In en, this message translates to:
  /// **'Today!'**
  String get upcomingToday;

  /// No description provided for @upcomingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get upcomingTomorrow;

  /// No description provided for @upcomingInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} d'**
  String upcomingInDays(int days);

  /// No description provided for @mediaWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get mediaWatched;

  /// No description provided for @filterStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming Services'**
  String get filterStreaming;

  /// No description provided for @detailRatingUnknown.
  ///
  /// In en, this message translates to:
  /// **'Rating ?'**
  String get detailRatingUnknown;

  /// No description provided for @detailAge.
  ///
  /// In en, this message translates to:
  /// **'AGE {age}'**
  String detailAge(int age);

  /// No description provided for @detailWatchlistRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from watchlist'**
  String detailWatchlistRemoved(String title);

  /// No description provided for @detailWatchlistAdded.
  ///
  /// In en, this message translates to:
  /// **'{title} added to watchlist'**
  String detailWatchlistAdded(String title);

  /// No description provided for @detailChangeRating.
  ///
  /// In en, this message translates to:
  /// **'Change Rating'**
  String get detailChangeRating;

  /// No description provided for @detailMarkWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as Watched'**
  String get detailMarkWatched;

  /// No description provided for @detailRemoveHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from History?'**
  String get detailRemoveHistoryTitle;

  /// No description provided for @detailRemoveHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from your watch history?'**
  String detailRemoveHistoryContent(String title);

  /// No description provided for @detailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detailCancel;

  /// No description provided for @detailRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get detailRemove;

  /// No description provided for @detailHistoryRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from watch history'**
  String detailHistoryRemoved(String title);

  /// No description provided for @detailMyRating.
  ///
  /// In en, this message translates to:
  /// **'My Rating'**
  String get detailMyRating;

  /// No description provided for @detailRateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get detailRateNow;

  /// No description provided for @detailPlot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get detailPlot;

  /// No description provided for @detailGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get detailGenres;

  /// No description provided for @detailSimilarMovies.
  ///
  /// In en, this message translates to:
  /// **'Similar Movies'**
  String get detailSimilarMovies;

  /// No description provided for @detailSimilarShows.
  ///
  /// In en, this message translates to:
  /// **'Similar Shows'**
  String get detailSimilarShows;

  /// No description provided for @detailSimilarContent.
  ///
  /// In en, this message translates to:
  /// **'Similar Content'**
  String get detailSimilarContent;

  /// No description provided for @detailRated.
  ///
  /// In en, this message translates to:
  /// **'{title} rated: {rating} ⭐'**
  String detailRated(String title, String rating);

  /// No description provided for @detailWatched.
  ///
  /// In en, this message translates to:
  /// **'{title} marked as watched: {rating} ⭐'**
  String detailWatched(String title, String rating);

  /// No description provided for @searchListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get searchListening;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies and shows...'**
  String get searchHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for movies and shows'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get searchEmptySubtitle;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResultsTitle(String query);

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another search term'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Error'**
  String get searchErrorTitle;

  /// No description provided for @searchRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetry;

  /// No description provided for @streamingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available on'**
  String get streamingAvailable;

  /// No description provided for @streamingNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available in {country}'**
  String streamingNotAvailable(String country);

  /// No description provided for @streamingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading streaming data'**
  String get streamingError;

  /// No description provided for @streamingYourServices.
  ///
  /// In en, this message translates to:
  /// **'Your Services'**
  String get streamingYourServices;

  /// No description provided for @streamingRentYours.
  ///
  /// In en, this message translates to:
  /// **'Rent (Your Services)'**
  String get streamingRentYours;

  /// No description provided for @streamingBuyYours.
  ///
  /// In en, this message translates to:
  /// **'Buy (Your Services)'**
  String get streamingBuyYours;

  /// No description provided for @streamingMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get streamingMoreOptions;

  /// No description provided for @streamingStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get streamingStreaming;

  /// No description provided for @streamingRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get streamingRent;

  /// No description provided for @streamingBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get streamingBuy;

  /// No description provided for @streamingShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get streamingShowLess;

  /// No description provided for @streamingShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get streamingShowMore;

  /// No description provided for @streamingPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by JustWatch'**
  String get streamingPoweredBy;

  /// No description provided for @streamingNotOnYours.
  ///
  /// In en, this message translates to:
  /// **'Not available on your services'**
  String get streamingNotOnYours;

  /// No description provided for @streamingNoData.
  ///
  /// In en, this message translates to:
  /// **'No streaming data available'**
  String get streamingNoData;

  /// No description provided for @streamingOthers.
  ///
  /// In en, this message translates to:
  /// **'{count} others'**
  String streamingOthers(int count);

  /// No description provided for @streamingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Streaming data provided by TMDB and may not be up to date.'**
  String get streamingDisclaimer;

  /// No description provided for @streamingSubscription.
  ///
  /// In en, this message translates to:
  /// **'✓ Your Sub'**
  String get streamingSubscription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsStreamingTitle.
  ///
  /// In en, this message translates to:
  /// **'My Streaming Services'**
  String get settingsStreamingTitle;

  /// No description provided for @settingsStreamingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to toggle'**
  String get settingsStreamingSubtitle;

  /// No description provided for @settingsCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get settingsCountry;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default'**
  String get settingsResetSubtitle;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetMessage.
  ///
  /// In en, this message translates to:
  /// **'All settings will be reset to default values.'**
  String get settingsResetMessage;

  /// No description provided for @settingsApi.
  ///
  /// In en, this message translates to:
  /// **'API Configuration'**
  String get settingsApi;

  /// No description provided for @settingsApiInfo.
  ///
  /// In en, this message translates to:
  /// **'Movie data provided by TMDB.'**
  String get settingsApiInfo;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsVersion;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendations based on your taste.'**
  String get settingsDescription;

  /// No description provided for @settingsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{service} removed'**
  String settingsRemoved(String service);

  /// No description provided for @settingsAdded.
  ///
  /// In en, this message translates to:
  /// **'{service} added'**
  String settingsAdded(String service);

  /// No description provided for @settingsSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get settingsSelectCountry;

  /// No description provided for @settingsChangeCountry.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get settingsChangeCountry;

  /// No description provided for @settingsCountryChanged.
  ///
  /// In en, this message translates to:
  /// **'Country changed to {country}'**
  String settingsCountryChanged(String country);

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @myListTitle.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get myListTitle;

  /// No description provided for @statMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get statMovies;

  /// No description provided for @statSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get statSeries;

  /// No description provided for @statAvgRating.
  ///
  /// In en, this message translates to:
  /// **'Ø Rating'**
  String get statAvgRating;

  /// No description provided for @statRated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get statRated;

  /// No description provided for @sortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortDate;

  /// No description provided for @sortMyRating.
  ///
  /// In en, this message translates to:
  /// **'My Rating'**
  String get sortMyRating;

  /// No description provided for @sortImdbRating.
  ///
  /// In en, this message translates to:
  /// **'IMDB Rating'**
  String get sortImdbRating;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get filterMovies;

  /// No description provided for @filterSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get filterSeries;

  /// No description provided for @filterRated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get filterRated;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'Nothing watched yet'**
  String get emptyHistory;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark movies and shows as watched to see them here'**
  String get emptyHistorySubtitle;

  /// No description provided for @emptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No results for these filters'**
  String get emptyFilter;

  /// No description provided for @emptyFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change filters to see more'**
  String get emptyFilterSubtitle;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteEntry;

  /// No description provided for @deleteEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from your list?'**
  String deleteEntryMessage(String title);

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @entryRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed'**
  String entryRemoved(String title);

  /// No description provided for @entryRated.
  ///
  /// In en, this message translates to:
  /// **'{title} rated: {rating} ⭐'**
  String entryRated(String title, String rating);

  /// No description provided for @watchlistError.
  ///
  /// In en, this message translates to:
  /// **'Error loading watchlist'**
  String get watchlistError;

  /// No description provided for @watchlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Watchlist empty'**
  String get watchlistEmpty;

  /// No description provided for @watchlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon to save movies and shows here.'**
  String get watchlistEmptySubtitle;

  /// No description provided for @watchlistAddedAgo.
  ///
  /// In en, this message translates to:
  /// **'Added {ago}'**
  String watchlistAddedAgo(String ago);

  /// No description provided for @timeAgoYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String timeAgoYears(int count);

  /// No description provided for @timeAgoMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String timeAgoMonths(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeAgoDays(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoJustNow;

  /// No description provided for @mediaTypeMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get mediaTypeMovie;

  /// No description provided for @mediaTypeTv.
  ///
  /// In en, this message translates to:
  /// **'TV Series'**
  String get mediaTypeTv;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @semanticPosterOf.
  ///
  /// In en, this message translates to:
  /// **'Poster of {title}'**
  String semanticPosterOf(String title);

  /// No description provided for @semanticBackdropOf.
  ///
  /// In en, this message translates to:
  /// **'Backdrop image of {title}'**
  String semanticBackdropOf(String title);

  /// No description provided for @semanticMediaCard.
  ///
  /// In en, this message translates to:
  /// **'{title}, {type}, rated {rating}'**
  String semanticMediaCard(String title, String type, String rating);

  /// No description provided for @semanticNavSelected.
  ///
  /// In en, this message translates to:
  /// **'{label}, selected'**
  String semanticNavSelected(String label);

  /// No description provided for @semanticVoiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get semanticVoiceSearch;

  /// No description provided for @semanticVoiceSearchActive.
  ///
  /// In en, this message translates to:
  /// **'Voice search, listening'**
  String get semanticVoiceSearchActive;

  /// No description provided for @semanticFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter results'**
  String get semanticFilterButton;

  /// No description provided for @semanticProviderLogo.
  ///
  /// In en, this message translates to:
  /// **'{provider} logo'**
  String semanticProviderLogo(String provider);

  /// No description provided for @semanticRatingBadge.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating} out of 10'**
  String semanticRatingBadge(String rating);

  /// No description provided for @semanticWatchlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to watchlist'**
  String semanticWatchlistAdd(String title);

  /// No description provided for @semanticWatchlistRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from watchlist'**
  String semanticWatchlistRemove(String title);

  /// No description provided for @semanticMarkWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as watched'**
  String semanticMarkWatched(String title);

  /// No description provided for @semanticChangeRating.
  ///
  /// In en, this message translates to:
  /// **'Change rating for {title}'**
  String semanticChangeRating(String title);

  /// No description provided for @semanticDeleteFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete {title} from history'**
  String semanticDeleteFromHistory(String title);

  /// No description provided for @semanticTrendingCard.
  ///
  /// In en, this message translates to:
  /// **'Trending: {title}'**
  String semanticTrendingCard(String title);

  /// No description provided for @semanticPageDot.
  ///
  /// In en, this message translates to:
  /// **'Page {number} of {total}'**
  String semanticPageDot(int number, int total);

  /// No description provided for @semanticBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get semanticBackButton;

  /// No description provided for @semanticRateNow.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String semanticRateNow(String title);

  /// No description provided for @detailEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Select a movie or series to view details'**
  String get detailEmptyState;

  /// No description provided for @detailTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailTabAbout;

  /// No description provided for @detailTabCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get detailTabCast;

  /// No description provided for @detailTabStreaming.
  ///
  /// In en, this message translates to:
  /// **'Where to Watch'**
  String get detailTabStreaming;

  /// No description provided for @detailTabSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get detailTabSimilar;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsProfiles.
  ///
  /// In en, this message translates to:
  /// **'👥 Profiles'**
  String get settingsProfiles;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsTasteProfile.
  ///
  /// In en, this message translates to:
  /// **'👤 Taste Profile'**
  String get settingsTasteProfile;

  /// No description provided for @settingsTasteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Share & compare profile'**
  String get settingsTasteProfileTitle;

  /// No description provided for @settingsTasteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your watch profile or import a friend\'s'**
  String get settingsTasteProfileSubtitle;

  /// No description provided for @aiSuggestion1Label.
  ///
  /// In en, this message translates to:
  /// **'🎬 What\'s trending?'**
  String get aiSuggestion1Label;

  /// No description provided for @aiSuggestion1Query.
  ///
  /// In en, this message translates to:
  /// **'What are the best trending movies and series right now?'**
  String get aiSuggestion1Query;

  /// No description provided for @aiSuggestion2Label.
  ///
  /// In en, this message translates to:
  /// **'😂 Something funny'**
  String get aiSuggestion2Label;

  /// No description provided for @aiSuggestion2Query.
  ///
  /// In en, this message translates to:
  /// **'Recommend a hilarious comedy that\'s a must-watch'**
  String get aiSuggestion2Query;

  /// No description provided for @aiSuggestion3Label.
  ///
  /// In en, this message translates to:
  /// **'🔥 Thriller like Dark'**
  String get aiSuggestion3Label;

  /// No description provided for @aiSuggestion3Query.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for a gripping thriller or mystery series similar to Dark'**
  String get aiSuggestion3Query;

  /// No description provided for @aiSuggestion4Label.
  ///
  /// In en, this message translates to:
  /// **'🤔 Something thought-provoking'**
  String get aiSuggestion4Label;

  /// No description provided for @aiSuggestion4Query.
  ///
  /// In en, this message translates to:
  /// **'Recommend a film or series that makes you think, profound and emotional'**
  String get aiSuggestion4Query;

  /// No description provided for @aiSuggestion5Label.
  ///
  /// In en, this message translates to:
  /// **'👨‍👩‍👧 Family night'**
  String get aiSuggestion5Label;

  /// No description provided for @aiSuggestion5Query.
  ///
  /// In en, this message translates to:
  /// **'What can a family watch together? Not too childish but family-friendly'**
  String get aiSuggestion5Query;

  /// No description provided for @aiSuggestion6Label.
  ///
  /// In en, this message translates to:
  /// **'🏆 Award-worthy'**
  String get aiSuggestion6Label;

  /// No description provided for @aiSuggestion6Query.
  ///
  /// In en, this message translates to:
  /// **'What are the best award-winning films of recent years that are a must-watch?'**
  String get aiSuggestion6Query;

  /// No description provided for @aiChatInputHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to watch?'**
  String get aiChatInputHint;

  /// No description provided for @aiTriviaTitle.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get aiTriviaTitle;

  /// No description provided for @aiWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to watch?'**
  String get aiWelcomeTitle;

  /// No description provided for @aiWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me for recommendations, moods,\nor specific genres!'**
  String get aiWelcomeSubtitle;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'❌ An error occurred. Please try again.'**
  String get aiError;

  /// No description provided for @aiSearchNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result for \"{title}\"'**
  String aiSearchNoResult(String title);

  /// No description provided for @aiSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get aiSearchFailed;

  /// No description provided for @discoverRandomPick.
  ///
  /// In en, this message translates to:
  /// **'🎲 Random Pick — Let us decide!'**
  String get discoverRandomPick;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal movie advisor'**
  String get aiChatSubtitle;

  /// No description provided for @aiPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'✨ Powered by Google Gemini'**
  String get aiPoweredBy;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'ShowSonar AI is thinking...'**
  String get aiThinking;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get aiInputHint;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionCopied.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get actionCopied;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionCopiedForSharing.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard — paste to share'**
  String get actionCopiedForSharing;

  /// No description provided for @viewingContextAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get viewingContextAll;

  /// No description provided for @viewingContextKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get viewingContextKids;

  /// No description provided for @viewingContextDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date Night'**
  String get viewingContextDateNight;

  /// No description provided for @viewingContextSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get viewingContextSolo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
