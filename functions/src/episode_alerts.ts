import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import axios from 'axios';

// Ensure Firebase is initialized
if (!admin.apps.length) {
    admin.initializeApp();
}

/**
 * Runs daily at 9:00 AM.
 * Scans active `episode_tracking` records and notifies users if a tracked show
 * is airing a new episode today.
 */
export const episodeAiringAlerts = onSchedule('every day 09:00', async (event) => {
    const firestore = admin.firestore();
    const messaging = admin.messaging();

    // TMDB API Key from environment or hardcoded test key
    const tmdbApiKey = process.env.TMDB_API_KEY || 'dummy-tmdb-key';

    console.log('Starting episodeAiringAlerts job...');

    try {
        // Find all users who are tracking episodes
        const trackingSnapshot = await firestore.collectionGroup('episode_tracking').get();
        if (trackingSnapshot.empty) {
            console.log('No active episode tracking found.');
            return;
        }

        // Map grouped by Show ID to avoid duplicate TMDB API calls
        // Map<ShowId, Array<UserId>>
        const showsToUsers = new Map<number, string[]>();

        trackingSnapshot.docs.forEach(doc => {
            const data = doc.data();
            const userId = doc.ref.parent.parent?.id;
            const showId = data.showId;

            if (userId && showId) {
                if (!showsToUsers.has(showId)) {
                    showsToUsers.set(showId, []);
                }
                showsToUsers.get(showId)?.push(userId);
            }
        });

        // Today's date in YYYY-MM-DD format
        const todayStr = new Date().toISOString().split('T')[0];

        // Process each show
        for (const [showId, userIds] of showsToUsers.entries()) {
            try {
                // Query TMDB for the specific TV show
                const response = await axios.get(`https://api.themoviedb.org/3/tv/${showId}?api_key=${tmdbApiKey}`);
                const showData = response.data;
                const nextEpisode = showData.next_episode_to_air;

                // Check if the next episode airs today
                if (nextEpisode && nextEpisode.air_date === todayStr) {
                    const episodeName = nextEpisode.name;
                    const seasonNumber = nextEpisode.season_number;
                    const episodeNumber = nextEpisode.episode_number;
                    const title = `New Episode Airing Today!`;
                    const body = `S${seasonNumber}E${episodeNumber} of ${showData.name}: "${episodeName}" airs today.`;

                    // Collect FCM tokens for the users tracking this show
                    const tokens: string[] = [];
                    for (const userId of userIds) {
                        const userDoc = await firestore.collection('users').doc(userId).get();
                        const userData = userDoc.data();
                        if (userData && userData.fcmTokens && Array.isArray(userData.fcmTokens)) {
                            tokens.push(...userData.fcmTokens);
                        }
                    }

                    // Send Multicast message if there are tokens
                    if (tokens.length > 0) {
                        // Max 500 tokens per multicast
                        const message = {
                            notification: { title, body },
                            data: {
                                mediaId: showId.toString(),
                                mediaType: 'tv',
                                click_action: 'FLUTTER_NOTIFICATION_CLICK'
                            },
                        };

                        const response = await messaging.sendEachForMulticast({ ...message, tokens });
                        console.log(`Sent Episode Alerts for Show ${showId}: ${response.successCount} successes, ${response.failureCount} failures.`);
                    }
                }
            } catch (err) {
                console.error(`TMDB API Error for Show ${showId}:`, err);
            }
        }
    } catch (error) {
        console.error('Failed to run episodeAiringAlerts job:', error);
    }
});
