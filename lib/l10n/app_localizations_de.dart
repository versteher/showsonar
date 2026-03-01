// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get apiKeyMissingTitle => 'API-Schlüssel fehlt';

  @override
  String get apiKeyMissingBody =>
      'Bitte füge deinen TMDB API-Schlüssel in die .env-Datei ein:\n\nTMDB_API_KEY=dein_schlüssel';

  @override
  String get apiKeyMissingFooter =>
      'Einen API-Schlüssel erhältst du kostenlos auf\nthemoviedb.org';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Suche';

  @override
  String get navAi => 'AI';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navFriends => 'Freunde';

  @override
  String get navProfile => 'Profil';

  @override
  String get navMyList => 'Meine Liste';

  @override
  String get navMore => 'Mehr';

  @override
  String get noInternetConnection => 'Keine Internetverbindung';

  @override
  String get tabWatchlist => 'Merkliste';

  @override
  String get tabHistory => 'Verlauf';

  @override
  String get sectionTrending => '🔥 Gerade im Trend';

  @override
  String get sectionUpcoming => '🆕 Bald verfügbar';

  @override
  String get sectionPopularMovies => '🎬 Beliebte Filme';

  @override
  String get sectionPopularTv => '📺 Beliebte Serien';

  @override
  String get sectionTopRated => '⭐ Top bewertet';

  @override
  String get sectionDiscover => '🎯 Entdecken';

  @override
  String get sectionContinueWatching => '▶️ Weiterschauen';

  @override
  String get sectionWeeklyRecap => '📅 Wochenrückblick';

  @override
  String get sectionMoodDiscovery => '🎭 Stimmungslage';

  @override
  String get actionAddToWatchlist => 'Zur Merkliste hinzufügen';

  @override
  String actionAddedToWatchlist(String title) {
    return '$title zur Merkliste hinzugefügt';
  }

  @override
  String get actionMarkSeen => 'Als gesehen markieren';

  @override
  String get actionFilter => 'Filtern';

  @override
  String get actionSettings => 'Einstellungen';

  @override
  String errorLoadingTitle(String title) {
    return '$title konnte nicht geladen werden';
  }

  @override
  String get errorLoadingUpcoming =>
      'Bald verfügbar konnte nicht geladen werden';

  @override
  String get recapTitle => 'Dein Wochenrückblick';

  @override
  String recapDays(int count) {
    return '$count Tage';
  }

  @override
  String get recapWatched => 'Geschaut';

  @override
  String get recapHours => 'Stunden';

  @override
  String get recapRating => 'Ø Bewertung';

  @override
  String get recapTopGenre => 'Top Genre';

  @override
  String get continueWatchingTitle => '▶️ Weiterschauen';

  @override
  String continueSeason(int number) {
    return 'Staffel $number';
  }

  @override
  String continueEpisode(int number) {
    return 'Folge $number';
  }

  @override
  String continueSeasonEpisode(int season, int episode) {
    return 'S$season E$episode';
  }

  @override
  String get continueInProgress => 'In Bearbeitung';

  @override
  String get moodTitle => '🎭 Wonach ist dir?';

  @override
  String moodNoResults(String mood) {
    return 'Keine Ergebnisse für $mood';
  }

  @override
  String get upcomingToday => 'Heute!';

  @override
  String get upcomingTomorrow => 'Morgen';

  @override
  String upcomingInDays(int days) {
    return 'In $days T.';
  }

  @override
  String get mediaWatched => 'Gesehen';

  @override
  String get filterStreaming => 'Streaming-Dienste';

  @override
  String get detailRatingUnknown => 'Bewertung ?';

  @override
  String detailAge(int age) {
    return 'AB $age';
  }

  @override
  String detailWatchlistRemoved(String title) {
    return '$title von Merkliste entfernt';
  }

  @override
  String detailWatchlistAdded(String title) {
    return '$title zur Merkliste hinzugefügt';
  }

  @override
  String get detailChangeRating => 'Bewertung ändern';

  @override
  String get detailMarkWatched => 'Als gesehen markieren';

  @override
  String get detailRemoveHistoryTitle => 'Aus Liste entfernen?';

  @override
  String detailRemoveHistoryContent(String title) {
    return '$title aus deiner Watch History entfernen?';
  }

  @override
  String get detailCancel => 'Abbrechen';

  @override
  String get detailRemove => 'Entfernen';

  @override
  String detailHistoryRemoved(String title) {
    return '$title aus Watch History entfernt';
  }

  @override
  String get detailMyRating => 'Meine Bewertung';

  @override
  String get detailRateNow => 'Jetzt bewerten';

  @override
  String get detailPlot => 'Handlung';

  @override
  String get detailGenres => 'Genres';

  @override
  String get detailSimilarMovies => 'Ähnliche Filme';

  @override
  String get detailSimilarShows => 'Ähnliche Serien';

  @override
  String get detailSimilarContent => 'Ähnliche Inhalte';

  @override
  String detailRated(String title, String rating) {
    return '$title aktualisiert: $rating ⭐';
  }

  @override
  String detailWatched(String title, String rating) {
    return '$title als gesehen markiert: $rating ⭐';
  }

  @override
  String get searchListening => 'Ich höre zu...';

  @override
  String get searchHint => 'Filme und Serien suchen...';

  @override
  String get searchEmptyTitle => 'Suche nach Filmen und Serien';

  @override
  String get searchEmptySubtitle => 'Mindestens 2 Buchstaben eingeben';

  @override
  String searchNoResultsTitle(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String get searchNoResultsSubtitle => 'Versuche einen anderen Suchbegriff';

  @override
  String get searchErrorTitle => 'Fehler bei der Suche';

  @override
  String get searchRetry => 'Erneut versuchen';

  @override
  String get streamingAvailable => 'Verfügbar auf';

  @override
  String streamingNotAvailable(String country) {
    return 'Nicht verfügbar in $country';
  }

  @override
  String get streamingError => 'Fehler beim Laden der Streaming-Daten';

  @override
  String get streamingYourServices => 'Deine Dienste';

  @override
  String get streamingRentYours => 'Leihen (Deine Dienste)';

  @override
  String get streamingBuyYours => 'Kaufen (Deine Dienste)';

  @override
  String get streamingMoreOptions => 'Weitere Optionen';

  @override
  String get streamingStreaming => 'Streaming';

  @override
  String get streamingRent => 'Leihen';

  @override
  String get streamingBuy => 'Kaufen';

  @override
  String get streamingShowLess => 'Weitere Optionen ausblenden';

  @override
  String get streamingShowMore => 'Weitere Optionen anzeigen';

  @override
  String get streamingPoweredBy => 'Powered by JustWatch';

  @override
  String get streamingNotOnYours => 'Nicht auf deinen Diensten verfügbar';

  @override
  String get streamingNoData => 'Keine Streaming-Daten verfügbar';

  @override
  String streamingOthers(int count) {
    return '$count Andere';
  }

  @override
  String get streamingDisclaimer =>
      'Die Streaming-Daten werden von TMDB bereitgestellt und sind möglicherweise nicht aktuell.';

  @override
  String get streamingSubscription => '✓ Dein Abo';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsStreamingTitle => 'Meine Streaming-Dienste';

  @override
  String get settingsStreamingSubtitle => 'Tippe zum Aktivieren/Deaktivieren';

  @override
  String get settingsCountry => 'Land';

  @override
  String get settingsReset => 'Zurücksetzen';

  @override
  String get settingsResetTitle => 'Einstellungen zurücksetzen';

  @override
  String get settingsResetSubtitle =>
      'Alle Einstellungen auf Standard zurücksetzen';

  @override
  String get settingsResetConfirm => 'Zurücksetzen?';

  @override
  String get settingsResetMessage =>
      'Alle Einstellungen werden auf die Standardwerte zurückgesetzt.';

  @override
  String get settingsApi => 'API-Konfiguration';

  @override
  String get settingsApiInfo =>
      'Filmdaten werden von The Movie Database (TMDB) bereitgestellt.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get settingsDescription =>
      'Intelligente Film- und Serienempfehlungen basierend auf deinem Geschmack.';

  @override
  String settingsRemoved(String service) {
    return '$service entfernt';
  }

  @override
  String settingsAdded(String service) {
    return '$service hinzugefügt';
  }

  @override
  String get settingsSelectCountry => 'Land auswählen';

  @override
  String get settingsChangeCountry => 'Tippen zum Ändern';

  @override
  String settingsCountryChanged(String country) {
    return 'Land geändert zu $country';
  }

  @override
  String get errorRetry => 'Erneut versuchen';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get myListTitle => 'Meine Liste';

  @override
  String get statMovies => 'Filme';

  @override
  String get statSeries => 'Serien';

  @override
  String get statAvgRating => 'Ø Bewertung';

  @override
  String get statRated => 'Bewertet';

  @override
  String get sortDate => 'Datum';

  @override
  String get sortMyRating => 'Meine Bewertung';

  @override
  String get sortImdbRating => 'IMDB Bewertung';

  @override
  String get sortTitle => 'Titel';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterMovies => 'Filme';

  @override
  String get filterSeries => 'Serien';

  @override
  String get filterRated => 'Bewertet';

  @override
  String get emptyHistory => 'Noch nichts gesehen';

  @override
  String get emptyHistorySubtitle =>
      'Markiere Filme und Serien als gesehen,\num sie hier zu sehen';

  @override
  String get emptyFilter => 'Keine Einträge mit diesen Filtern';

  @override
  String get emptyFilterSubtitle => 'Ändere die Filter, um mehr zu sehen';

  @override
  String get deleteEntry => 'Eintrag löschen?';

  @override
  String deleteEntryMessage(String title) {
    return '$title aus deiner Liste entfernen?';
  }

  @override
  String get deleteButton => 'Löschen';

  @override
  String entryRemoved(String title) {
    return '$title entfernt';
  }

  @override
  String entryRated(String title, String rating) {
    return '$title bewertet: $rating ⭐';
  }

  @override
  String get watchlistError => 'Fehler beim Laden';

  @override
  String get watchlistEmpty => 'Noch nichts gemerkt';

  @override
  String get watchlistEmptySubtitle =>
      'Tippe auf das Lesezeichen-Symbol bei einem Film oder Serie, um ihn hier zu speichern.';

  @override
  String watchlistAddedAgo(String ago) {
    return 'Gemerkt $ago';
  }

  @override
  String timeAgoYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Jahren',
      one: 'vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Monaten',
      one: 'vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoJustNow => 'gerade eben';

  @override
  String get mediaTypeMovie => 'Film';

  @override
  String get mediaTypeTv => 'Serie';

  @override
  String get priorityHigh => 'Hoch';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityLow => 'Niedrig';

  @override
  String semanticPosterOf(String title) {
    return 'Filmplakat von $title';
  }

  @override
  String semanticBackdropOf(String title) {
    return 'Hintergrundbild von $title';
  }

  @override
  String semanticMediaCard(String title, String type, String rating) {
    return '$title, $type, Bewertung $rating';
  }

  @override
  String semanticNavSelected(String label) {
    return '$label, ausgewählt';
  }

  @override
  String get semanticVoiceSearch => 'Sprachsuche';

  @override
  String get semanticVoiceSearchActive => 'Sprachsuche, aktiv';

  @override
  String get semanticFilterButton => 'Ergebnisse filtern';

  @override
  String semanticProviderLogo(String provider) {
    return '$provider Logo';
  }

  @override
  String semanticRatingBadge(String rating) {
    return 'Bewertung $rating von 10';
  }

  @override
  String semanticWatchlistAdd(String title) {
    return '$title zur Merkliste hinzufügen';
  }

  @override
  String semanticWatchlistRemove(String title) {
    return '$title von Merkliste entfernen';
  }

  @override
  String semanticMarkWatched(String title) {
    return '$title als gesehen markieren';
  }

  @override
  String semanticChangeRating(String title) {
    return 'Bewertung für $title ändern';
  }

  @override
  String semanticDeleteFromHistory(String title) {
    return '$title aus Verlauf löschen';
  }

  @override
  String semanticTrendingCard(String title) {
    return 'Trending: $title';
  }

  @override
  String semanticPageDot(int number, int total) {
    return 'Seite $number von $total';
  }

  @override
  String get semanticBackButton => 'Zurück';

  @override
  String semanticRateNow(String title) {
    return '$title bewerten';
  }

  @override
  String get detailEmptyState => 'Wähle einen Film oder eine Serie aus';

  @override
  String get detailTabAbout => 'Über';

  @override
  String get detailTabCast => 'Besetzung';

  @override
  String get detailTabStreaming => 'Wo schauen';

  @override
  String get detailTabSimilar => 'Ähnliche';

  @override
  String get settingsTheme => 'Erscheinungsbild';

  @override
  String get settingsProfiles => '👥 Profile';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsTasteProfile => '👤 Geschmacksprofil';

  @override
  String get settingsTasteProfileTitle => 'Profil teilen & vergleichen';

  @override
  String get settingsTasteProfileSubtitle =>
      'Exportiere dein Sehprofil oder importiere das eines Freundes';

  @override
  String get aiSuggestion1Label => '🎬 Was ist gerade gut?';

  @override
  String get aiSuggestion1Query =>
      'Was sind die besten Filme und Serien die gerade im Trend sind?';

  @override
  String get aiSuggestion2Label => '😂 Was Lustiges';

  @override
  String get aiSuggestion2Query =>
      'Empfiehl mir eine richtig lustige Komödie die man gesehen haben muss';

  @override
  String get aiSuggestion3Label => '🔥 Thriller wie Dark';

  @override
  String get aiSuggestion3Query =>
      'Ich suche einen spannenden Thriller oder Mystery-Serie ähnlich wie Dark';

  @override
  String get aiSuggestion4Label => '🤔 Zum Nachdenken';

  @override
  String get aiSuggestion4Query =>
      'Empfiehl mir einen Film oder eine Serie die zum Nachdenken anregt, tiefgründig und emotional';

  @override
  String get aiSuggestion5Label => '👨‍👩‍👧 Familienabend';

  @override
  String get aiSuggestion5Query =>
      'Was kann man als Familie zusammen schauen? Nicht zu kindisch aber jugendfrei';

  @override
  String get aiSuggestion6Label => '🏆 Oscar-würdig';

  @override
  String get aiSuggestion6Query =>
      'Was sind die besten preisgekrönten Filme der letzten Jahre die man gesehen haben muss?';

  @override
  String get aiChatInputHint => 'Was möchtest du sehen?';

  @override
  String get aiTriviaTitle => 'Wusstest du schon?';

  @override
  String get aiWelcomeTitle => 'Was möchtest du schauen?';

  @override
  String get aiWelcomeSubtitle =>
      'Frag mich nach Empfehlungen, Stimmungen\noder bestimmten Genres!';

  @override
  String get aiError =>
      '❌ Ein Fehler ist aufgetreten. Bitte versuche es erneut.';

  @override
  String aiSearchNoResult(String title) {
    return 'Kein Ergebnis für \"$title\"';
  }

  @override
  String get aiSearchFailed => 'Suche fehlgeschlagen';

  @override
  String get discoverRandomPick => '🎲 Zufallsfilm — Lass uns entscheiden!';

  @override
  String get aiChatSubtitle => 'Dein persönlicher Film-Berater';

  @override
  String get aiPoweredBy => '✨ Powered by Google Gemini';

  @override
  String get aiThinking => 'ShowSonar AI denkt nach...';

  @override
  String get aiInputHint => 'Frag mich was...';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionCopied => 'Text kopiert';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionCopiedForSharing =>
      'In Zwischenablage kopiert — zum Teilen einfügen';

  @override
  String get viewingContextAll => 'Alle';

  @override
  String get viewingContextKids => 'Kinder';

  @override
  String get viewingContextDateNight => 'Date Night';

  @override
  String get viewingContextSolo => 'Solo';
}
